// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../chat_screen.dart';
import 'patient.dart';

class PatientDetailPage extends StatefulWidget {
  final Patient patient;

  const PatientDetailPage({super.key, required this.patient});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance
      .ref('Requests'); //  it will store appointments requests

  TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section (Same as before)
              Row(
                children: [
                  Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      color: const Color(0xffF0EFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.patient.profileImageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.patient.profileImageUrl,
                              fit: BoxFit.fitWidth,
                            ),
                          )
                        : const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.patient.firstName} ${widget.patient.lastName}',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'From: ${widget.patient.city}',
                        // Example location; replace with actual data if available
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xffFA9600),
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Image.asset(
                              'assets/images/phone_call.png',
                              width: 30,
                              height: 30,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // Add phone call functionality
                              _makePhoneCall(widget.patient.phoneNumber);
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/images/chat_icon.png',
                              width: 30,
                              height: 30,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // Add chat functionality

                              String docName =
                                  '${widget.patient.firstName.toString()} ${widget.patient.lastName.toString()}';

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    patientId: widget.patient.uid,
                                    patientName: docName,
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFB342),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Add map location functionality
                  },
                  child: Text(
                    'VIEW LOCATION ON MAP',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'Select Date & Time',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xffF0EFFF),
                  border: Border.all(
                    color: const Color(0xffC8C4FF),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0064FA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _selectDate(context),
                            child: Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : DateFormat('MM/dd/yyyy')
                                      .format(_selectedDate!),
                              style: GoogleFonts.poppins(
                                  fontSize: 15, letterSpacing: 0.6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0064FA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _selectTime(context),
                            child: Text(
                              _selectedTime == null
                                  ? 'Select Time'
                                  : _selectedTime!.format(context),
                              style: GoogleFonts.poppins(
                                  fontSize: 15, letterSpacing: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.black),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xffF0EFFF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0064FA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Add appointment booking functionality
                    _bookAppointment();
                  },
                  child: Text(
                    'BOOK APPOINTMENT',
                    style: GoogleFonts.poppins(fontSize: 16, letterSpacing: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //select Date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  //select time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // phone call
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not make a call on $phoneNumber this number';
    }
  }

  // appointment

  void _bookAppointment() {
    if (_selectedDate != null &&
        _selectedTime != null &&
        _descriptionController.text.isNotEmpty) {
      // date, time, des, requestId, receiverId, senderId, status
      String date = DateFormat('MM/dd/yyyy').format(_selectedDate!);
      String time = _selectedTime!.format(context);
      String description = _descriptionController.text;
      String requestId = _requestDatabase.push().key!;
      String currentUserId = _auth.currentUser!.uid;
      String receiverId = widget.patient.uid;
      String status = 'pending';

      //save appointment
      _requestDatabase.child(requestId).set({
        'date': date,
        'time': time,
        'description': description,
        'id': requestId,
        'receiver': receiverId,
        'sender': currentUserId,
        'status': status,
      }).then((_) {
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _descriptionController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment booked successfully')));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Failed to book your appointment, Try Again later!!')));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Select a date and time also add a description for appointment')));
    }
  }
}
