import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../widgets/error_widget.dart' as custom;
import '../providers/horses_provider.dart';

class HorseDetailScreen extends ConsumerWidget {
  final String horseId;

  const HorseDetailScreen({
    super.key,
    required this.horseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horseAsync = ref.watch(horseProvider(horseId));
    final theme = Theme.of(context);

    return horseAsync.when(
      data: (horse) => Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar with photo
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(horse.name),
                background: horse.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: horse.photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.favorite,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.favorite,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.push('/horses/edit/$horseId'),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteDialog(context, ref, horseId);
                    }
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Section
                    _SectionTitle(title: 'Informations'),
                    const SizedBox(height: 16),
                    _InfoCard(
                      items: [
                        _InfoItem(
                          icon: Icons.pets,
                          label: 'Race',
                          value: horse.breedDisplay,
                        ),
                        _InfoItem(
                          icon: Icons.wc,
                          label: 'Sexe',
                          value: horse.sexDisplay,
                        ),
                        _InfoItem(
                          icon: Icons.cake,
                          label: 'Âge',
                          value: horse.ageDisplay,
                        ),
                        _InfoItem(
                          icon: Icons.scale,
                          label: 'Poids',
                          value: horse.weightDisplay,
                        ),
                        _InfoItem(
                          icon: Icons.height,
                          label: 'Taille',
                          value: horse.heightDisplay,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Health Info
                    if (horse.healthInfo != null) ...[
                      _SectionTitle(title: 'Informations Santé'),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(horse.healthInfo!),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Particularities
                    if (horse.particularities != null) ...[
                      _SectionTitle(title: 'Particularités'),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(horse.particularities!),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Notes
                    if (horse.notes != null) ...[
                      _SectionTitle(title: 'Notes'),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(horse.notes!),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Quick Actions
                    _SectionTitle(title: 'Actions Rapides'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Start tracking with this horse
                              context.push('/tracking/start?horseId=$horseId');
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Démarrer'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: View health history
                              context.push('/horses/$horseId/health');
                            },
                            icon: const Icon(Icons.medical_services_outlined),
                            label: const Text('Santé'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: custom.ErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(horseProvider(horseId)),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String horseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le cheval'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce cheval ? '
          'Cette action est irréversible et supprimera également toutes les activités associées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final error = await ref
                  .read(horsesControllerProvider.notifier)
                  .deleteHorse(horseId);

              if (context.mounted) {
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                } else {
                  context.pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: item,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
