import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
          ),

          // Events for selected day
          Expanded(
            child: _selectedDay != null
                ? _buildEventsList(_selectedDay!)
                : const Center(
                    child: Text('Sélectionnez un jour'),
                  ),
          ),
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

  Widget _buildEventsList(DateTime day) {
    // TODO: Fetch events from provider
    final mockEvents = [
      {
        'type': 'Training',
        'description': 'Entraînement dressage',
        'time': '10:00',
      },
      {
        'type': 'Veterinary Appointment',
        'description': 'Visite vétérinaire',
        'time': '14:30',
      },
    ];

    if (mockEvents.isEmpty) {
      return const Center(
        child: Text('Aucun événement ce jour'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockEvents.length,
      itemBuilder: (context, index) {
        final event = mockEvents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getEventColor(event['type']!),
              child: Icon(
                _getEventIcon(event['type']!),
                color: Colors.white,
              ),
            ),
            title: Text(event['description']!),
            subtitle: Text(event['time']!),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'Training':
        return Icons.fitness_center;
      case 'Rest Day':
        return Icons.hotel;
      case 'Competition':
        return Icons.emoji_events;
      case 'Veterinary Appointment':
        return Icons.medical_services;
      case 'Farrier Appointment':
        return Icons.construction;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'Training':
        return Colors.blue;
      case 'Rest Day':
        return Colors.green;
      case 'Competition':
        return Colors.orange;
      case 'Veterinary Appointment':
        return Colors.red;
      case 'Farrier Appointment':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _showAddEventDialog(BuildContext context) {
    final theme = Theme.of(context);
    String? selectedType;
    final descriptionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un événement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type d\'événement',
                ),
                items: const [
                  DropdownMenuItem(value: 'Training', child: Text('Entraînement')),
                  DropdownMenuItem(value: 'Rest Day', child: Text('Repos')),
                  DropdownMenuItem(value: 'Competition', child: Text('Compétition')),
                  DropdownMenuItem(value: 'Veterinary Appointment', child: Text('Vétérinaire')),
                  DropdownMenuItem(value: 'Farrier Appointment', child: Text('Maréchal-ferrant')),
                  DropdownMenuItem(value: 'Other', child: Text('Autre')),
                ],
                onChanged: (value) {
                  selectedType = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Heure'),
                subtitle: Text(selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    selectedTime = time;
                  }
                },
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
              // TODO: Save event
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
