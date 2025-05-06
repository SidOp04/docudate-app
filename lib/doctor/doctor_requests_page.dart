// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'model/booking.dart';

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});

  @override
  State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase =
      FirebaseDatabase.instance.ref().child('Requests');

  List<Booking> _bookings = [];
  Map<String, String> _senderNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final event = await _requestDatabase
        .orderByChild('receiver')
        .equalTo(currentUserId)
        .once();

    if (event.snapshot.value != null) {
      final bookingMap = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      _bookings.clear();
      _senderNames.clear();

      for (var entry in bookingMap.entries) {
        final booking = Booking.fromMap(Map<String, dynamic>.from(entry.value));
        _bookings.add(booking);

        final senderId = booking.sender;
        if (!_senderNames.containsKey(senderId)) {
          final userSnap = await FirebaseDatabase.instance
              .ref()
              .child('Patients')
              .child(senderId)
              .get();
          if (userSnap.exists) {
            final data = Map<String, dynamic>.from(userSnap.value as Map);
            final fullName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
            _senderNames[senderId] = fullName;
          } else {
            _senderNames[senderId] = 'Unknown';
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade600;
      case 'completed':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Requests',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No booking available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    final senderName = _senderNames[booking.sender] ?? 'Loading...';
                    final statusColor = _getStatusColor(booking.status);

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showStatusDialog(booking.id, booking.status),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      senderName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      booking.status,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Description: ${booking.description}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    booking.date,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    booking.time,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showStatusDialog(String requestId, String currentStatus) {
    List<String> statuses = ['Accepted', 'Rejected', 'Completed'];
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Request Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: statuses.map((status) {
                  return RadioListTile<String>(
                    title: Text(status),
                    value: status,
                    groupValue: selectedStatus,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      setState(() => selectedStatus = value!);
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () async {
                    await _updateRequestStatus(requestId, selectedStatus);
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await _requestDatabase.child(requestId).update({'status': status});
    await _fetchBookings();
  }
}
