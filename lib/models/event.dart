import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String name;
  String venue;
  DateTime dateTime;

  Event({
    required this.id,
    required this.name,
    required this.venue,
    required this.dateTime,
  });

  // Convert an Event object into a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'venue': venue,
      'dateTime': Timestamp.fromDate(dateTime), // Use Timestamp for better querying
    };
  }

  // Create an Event object from a Firestore DocumentSnapshot
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      venue: data['venue'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
    );
  }
}