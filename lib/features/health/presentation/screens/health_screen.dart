import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatters.dart';

class HealthScreen extends ConsumerWidget {
  final String horseId;

  const HealthScreen({
    super.key,
    required this.horseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Fetch health events from provider
    final mockEvents = [
      {
        'type': 'vaccination',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'notes': 'Vaccination annuelle - Grippe et tétanos',
        'nextDue': DateTime.now().add(const Duration(days: 335)),
      },
      {
        'type': 'farrier',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'notes': 'Parage des pieds',
        'nextDue': DateTime.now().add(const Duration(days: 30)),
      },
      {
        'type': 'veterinary',
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'notes': 'Contrôle dentaire',
        'nextDue': DateTime.now().add(const Duration(days: 305)),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Santé'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Upcoming reminders
          Text(
            'Prochains rappels',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...mockEvents
              .where((e) => e['nextDue'] != null)
              .map((event) => _ReminderCard(
                    type: event['type'] as String,
                    nextDue: event['nextDue'] as DateTime,
                  )),
          const SizedBox(height: 32),

          // Health timeline
          Text(
            'Historique',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...mockEvents.map((event) => _HealthEventCard(
                type: event['type'] as String,
                date: event['date'] as DateTime,
                notes: event['notes'] as String,
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddEventDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    String? selectedType;
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un événement santé'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type d\'événement',
                ),
                items: const [
                  DropdownMenuItem(value: 'vaccination', child: Text('Vaccination')),
                  DropdownMenuItem(value: 'farrier', child: Text('Maréchal-ferrant')),
                  DropdownMenuItem(value: 'veterinary', child: Text('Vétérinaire')),
                  DropdownMenuItem(value: 'deworming', child: Text('Vermifuge')),
                  DropdownMenuItem(value: 'dental', child: Text('Dentiste')),
                  DropdownMenuItem(value: 'other', child: Text('Autre')),
                ],
                onChanged: (value) {
                  selectedType = value;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(Formatters.formatDate(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save health event
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final String type;
  final DateTime nextDue;

  const _ReminderCard({
    required this.type,
    required this.nextDue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysUntil = nextDue.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 7;

    return Card(
      color: isUrgent ? theme.colorScheme.errorContainer : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUrgent
              ? theme.colorScheme.error
              : _getEventColor(type),
          child: Icon(
            _getEventIcon(type),
            color: Colors.white,
          ),
        ),
        title: Text(_getEventTitle(type)),
        subtitle: Text(
          daysUntil > 0
              ? 'Dans $daysUntil jours'
              : daysUntil == 0
                  ? 'Aujourd\'hui'
                  : 'En retard de ${-daysUntil} jours',
        ),
        trailing: Icon(
          isUrgent ? Icons.warning : Icons.chevron_right,
          color: isUrgent ? theme.colorScheme.error : null,
        ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'vaccination':
        return Icons.vaccines;
      case 'farrier':
        return Icons.construction;
      case 'veterinary':
        return Icons.medical_services;
      case 'deworming':
        return Icons.medication;
      case 'dental':
        return Icons.dental_services;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'vaccination':
        return Colors.blue;
      case 'farrier':
        return Colors.brown;
      case 'veterinary':
        return Colors.red;
      case 'deworming':
        return Colors.purple;
      case 'dental':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getEventTitle(String type) {
    switch (type) {
      case 'vaccination':
        return 'Vaccination';
      case 'farrier':
        return 'Maréchal-ferrant';
      case 'veterinary':
        return 'Vétérinaire';
      case 'deworming':
        return 'Vermifuge';
      case 'dental':
        return 'Dentiste';
      default:
        return 'Événement';
    }
  }
}

class _HealthEventCard extends StatelessWidget {
  final String type;
  final DateTime date;
  final String notes;

  const _HealthEventCard({
    required this.type,
    required this.date,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getEventColor(type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getEventIcon(type),
                color: _getEventColor(type),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getEventTitle(type),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatDate(date),
                    style: theme.textTheme.bodySmall,
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      notes,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'vaccination':
        return Icons.vaccines;
      case 'farrier':
        return Icons.construction;
      case 'veterinary':
        return Icons.medical_services;
      case 'deworming':
        return Icons.medication;
      case 'dental':
        return Icons.dental_services;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'vaccination':
        return Colors.blue;
      case 'farrier':
        return Colors.brown;
      case 'veterinary':
        return Colors.red;
      case 'deworming':
        return Colors.purple;
      case 'dental':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getEventTitle(String type) {
    switch (type) {
      case 'vaccination':
        return 'Vaccination';
      case 'farrier':
        return 'Maréchal-ferrant';
      case 'veterinary':
        return 'Vétérinaire';
      case 'deworming':
        return 'Vermifuge';
      case 'dental':
        return 'Dentiste';
      default:
        return 'Événement';
    }
  }
}
