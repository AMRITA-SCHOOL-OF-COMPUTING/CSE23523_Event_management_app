import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cse23523/models/event.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _venueController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the fields with existing event data
    _nameController = TextEditingController(text: widget.event.name);
    _venueController = TextEditingController(text: widget.event.venue);
    _selectedDate = widget.event.dateTime;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;

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

  // 2. Update: Edit existing event details
  void _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      // Create a map of the data to update
      final updatedData = {
        'name': _nameController.text,
        'venue': _venueController.text,
        'dateTime': Timestamp.fromDate(_selectedDate),
      };

      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.event.id)
            .update(updatedData);

        if (mounted) {
          // Pop twice to go back to the main list
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event: $e')),
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
        title: const Text('Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save_as),
                      onPressed: _updateEvent,
                      label: const Text('UPDATE EVENT'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}