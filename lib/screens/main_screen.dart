import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cse23523/models/event.dart';
import 'add_event_screen.dart';
import 'event_details_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final CollectionReference _eventsCollection =
      FirebaseFirestore.instance.collection('events');
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // i. AppBar
      appBar: AppBar(
        title: const Text('Event Manager'),
        // v. Search feature
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name or venue...',
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      // 2. Read: Retrieve and display events dynamically
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventsCollection.orderBy('dateTime', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Convert docs to Event objects
          final allEvents = snapshot.data!.docs
              .map((doc) => Event.fromFirestore(doc))
              .toList();

          // Apply search filter
          final filteredEvents = allEvents.where((event) {
            final nameLower = event.name.toLowerCase();
            final venueLower = event.venue.toLowerCase();
            return nameLower.contains(_searchQuery) ||
                   venueLower.contains(_searchQuery);
          }).toList();
          
          if (filteredEvents.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          // i. Display the list of events
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
              // i. Card or ListTile
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.calendar_today, color: Colors.white),
                  ),
                  title: Text(event.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${event.venue} - ${DateFormat.yMd().add_jm().format(event.dateTime)}'),
                  trailing: const Icon(Icons.chevron_right),
                  // iv. GestureDetector or InkWell
                  onTap: () {
                    // v. Animation or transition effect (default slide)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(event: event),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // i. Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // v. Animation or transition effect (default slide)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventScreen()),
          );
        },
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}