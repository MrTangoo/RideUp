import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_widget.dart' as custom;
import '../providers/horses_provider.dart';

class HorsesListScreen extends ConsumerWidget {
  const HorsesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horsesAsync = ref.watch(horsesListProvider);
    final canAddAsync = ref.watch(canAddHorseProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Chevaux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: horsesAsync.when(
        data: (horses) {
          if (horses.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_outline,
              title: 'Aucun cheval',
              message: 'Ajoutez votre premier cheval pour commencer à suivre vos activités',
              actionText: 'Ajouter un cheval',
              onAction: () => context.push('/horses/add'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(horsesListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: horses.length,
              itemBuilder: (context, index) {
                final horse = horses[index];
                return _HorseCard(
                  horse: horse,
                  onTap: () => context.push('/horses/${horse.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => custom.ErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(horsesListProvider),
        ),
      ),
      floatingActionButton: canAddAsync.when(
        data: (canAdd) {
          if (!canAdd) {
            return FloatingActionButton.extended(
              onPressed: () {
                // TODO: Show premium dialog
                _showPremiumDialog(context);
              },
              icon: const Icon(Icons.lock),
              label: const Text('Premium'),
              backgroundColor: theme.colorScheme.secondary,
            );
          }

          return FloatingActionButton.extended(
            onPressed: () => context.push('/horses/add'),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limite atteinte'),
        content: const Text(
          'Vous avez atteint la limite de chevaux pour le plan gratuit. '
          'Passez à Premium pour ajouter un nombre illimité de chevaux.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/premium');
            },
            child: const Text('Voir Premium'),
          ),
        ],
      ),
    );
  }
}

class _HorseCard extends StatelessWidget {
  final dynamic horse;
  final VoidCallback onTap;

  const _HorseCard({
    required this.horse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Horse photo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: horse.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: horse.photoUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.favorite,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Horse info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      horse.name,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      horse.breedDisplay,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          horse.ageDisplay,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.scale_outlined,
                          size: 16,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          horse.weightDisplay,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
