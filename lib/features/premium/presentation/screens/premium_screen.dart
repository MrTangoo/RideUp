import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RideUp Premium'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Icon(
            Icons.workspace_premium,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Passez à Premium',
            style: theme.textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Débloquez toutes les fonctionnalités',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Features
          _FeatureItem(
            icon: Icons.favorite,
            title: 'Chevaux illimités',
            description: 'Ajoutez autant de chevaux que vous le souhaitez',
          ),
          _FeatureItem(
            icon: Icons.bar_chart,
            title: 'Statistiques avancées',
            description: 'Analyses détaillées et graphiques personnalisés',
          ),
          _FeatureItem(
            icon: Icons.picture_as_pdf,
            title: 'Export PDF',
            description: 'Exportez vos activités en PDF',
          ),
          _FeatureItem(
            icon: Icons.cloud_upload,
            title: 'Stockage illimité',
            description: 'Documents et photos sans limite',
          ),
          _FeatureItem(
            icon: Icons.medical_services,
            title: 'Analyses santé',
            description: 'Recommandations personnalisées',
          ),
          _FeatureItem(
            icon: Icons.hotel,
            title: 'Recommandations repos',
            description: 'Calcul automatique du temps de récupération',
          ),
          const SizedBox(height: 40),

          // Pricing
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '9,99 € / mois',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ou 89,99 € / an (économisez 25%)',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _showSubscriptionOptions(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text('S\'abonner'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Terms
          Text(
            '• Annulez à tout moment\n'
            '• Essai gratuit de 7 jours\n'
            '• Paiement sécurisé',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // TODO: Show terms and conditions
            },
            child: const Text('Conditions générales'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choisir un abonnement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _SubscriptionOption(
              title: 'Mensuel',
              price: '9,99 €',
              period: 'par mois',
              onTap: () {
                Navigator.pop(context);
                _processPurchase(context, 'monthly');
              },
            ),
            const SizedBox(height: 16),
            _SubscriptionOption(
              title: 'Annuel',
              price: '89,99 €',
              period: 'par an',
              badge: 'Économisez 25%',
              onTap: () {
                Navigator.pop(context);
                _processPurchase(context, 'yearly');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processPurchase(BuildContext context, String plan) {
    // TODO: Implement in-app purchase
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Achat en cours'),
        content: const Text(
          'L\'achat in-app sera implémenté avec RevenueCat ou le SDK natif.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionOption extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? badge;
  final VoidCallback onTap;

  const _SubscriptionOption({
    required this.title,
    required this.price,
    required this.period,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge,
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$price $period',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
