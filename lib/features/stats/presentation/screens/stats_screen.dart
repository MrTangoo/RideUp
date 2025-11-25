import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/tracking_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  String _selectedPeriod = 'week';

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesListProvider());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'week', child: Text('Cette semaine')),
              const PopupMenuItem(value: 'month', child: Text('Ce mois')),
              const PopupMenuItem(value: 'year', child: Text('Cette année')),
              const PopupMenuItem(value: 'all', child: Text('Tout')),
            ],
          ),
        ],
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80),
                  SizedBox(height: 16),
                  Text('Aucune activité'),
                  SizedBox(height: 8),
                  Text('Commencez à enregistrer vos balades'),
                ],
              ),
            );
          }

          // Calculate stats
          final totalDistance = activities.fold<double>(
            0,
            (sum, activity) => sum + activity.distance,
          );
          final totalDuration = activities.fold<int>(
            0,
            (sum, activity) => sum + activity.durationSeconds,
          );
          final maxSpeed = activities.fold<double>(
            0,
            (max, activity) => activity.maxSpeed > max ? activity.maxSpeed : max,
          );
          final totalCalories = activities.fold<double>(
            0,
            (sum, activity) => sum + activity.calories,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.route,
                      label: 'Distance',
                      value: Formatters.formatDistance(totalDistance),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer,
                      label: 'Temps',
                      value: Formatters.formatDuration(
                        Duration(seconds: totalDuration),
                      ),
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.speed,
                      label: 'Vitesse max',
                      value: Formatters.formatSpeed(maxSpeed),
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      label: 'Calories',
                      value: Formatters.formatCalories(totalCalories),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Distance Chart
              Text(
                'Distance par activité',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: activities
                            .map((a) => a.distanceKm)
                            .reduce((a, b) => a > b ? a : b) * 1.2,
                        barGroups: activities.take(10).toList().asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.distanceKm,
                                color: theme.colorScheme.primary,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()} km');
                              },
                            ),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Activities List
              Text(
                'Activités récentes',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...activities.take(5).map((activity) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.directions_run,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    Formatters.formatDistance(activity.distance),
                  ),
                  subtitle: Text(
                    Formatters.formatDateTime(activity.startTime),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatDuration(activity.duration),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        activity.workloadLevel,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
