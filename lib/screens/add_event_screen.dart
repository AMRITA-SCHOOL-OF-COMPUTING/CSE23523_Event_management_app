import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:cse23523/models/event.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // ii. DatePicker / TimePicker
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (date == null) return; // User canceled DatePicker

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return; // User canceled TimePicker

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // 2. Create: Add new events
  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      // Use Uuid to generate a unique ID
      String eventId = const Uuid().v4();

      final newEvent = Event(
        id: eventId,
        name: _nameController.text,
        venue: _venueController.text,
        dateTime: _selectedDate,
      );

      try {
        // Set the document with our custom ID
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .set(newEvent.toJson());

        if (mounted) {
          // ii. Save button adds new event and returns
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ii. TextFields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  icon: Icon(Icons.event),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  icon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a venue' : null,
              ),
              const SizedBox(height: 20),
              // Date/Time Picker Trigger
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Event Date & Time'),
                subtitle: Text(DateFormat.yMd().add_jm().format(_selectedDate)),
                trailing: TextButton(
                  onPressed: () => _selectDateTime(context),
                  child: const Text('SELECT'),
                ),
              ),
              const SizedBox(height: 30),
              // ii. Save button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: _saveEvent,
                      label: const Text('SAVE EVENT'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}