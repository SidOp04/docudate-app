import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice/chat_screen.dart';
import '../doctor/model/doctor.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatListDatabase =
      FirebaseDatabase.instance.ref().child('ChatList');
  final DatabaseReference _doctorDatabase =
      FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _chatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatList();
  }

  Future<void> _fetchChatList() async {
    String? userId = _auth.currentUser?.uid;
    try {
      final DatabaseEvent event = await _chatListDatabase.once();
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tempChatList = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        for (var doctorId in values.keys) {
          Map<dynamic, dynamic> userChats = values[doctorId];
          if (userChats.containsKey(userId)) {
            final DatabaseEvent doctorEvent =
                await _doctorDatabase.child(doctorId).once();
            DataSnapshot doctorSnapshot = doctorEvent.snapshot;
            if (doctorSnapshot.value != null) {
              Doctor doctor = Doctor.fromMap(
                  doctorSnapshot.value as Map<dynamic, dynamic>, doctorId);
              tempChatList.add(doctor);
            }
          }
        }
      }
      setState(() {
        _chatList = tempChatList;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle errors appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Doctors',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xff0064FA),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatList.isEmpty
              ? Center(
                  child: Text(
                    'No chats available',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _chatList.length,
                  itemBuilder: (context, index) {
                    Doctor doctor = _chatList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                  doctorId: doctor.uid,
                                  doctorName:
                                      '${doctor.firstName} ${doctor.lastName}',
                                  patientId: _auth.currentUser!.uid,
                                )));
                      },
                      child: Card(
                        elevation: 4,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: doctor.profileImageUrl != null &&
                                    doctor.profileImageUrl!.isNotEmpty
                                ? NetworkImage(doctor.profileImageUrl!)
                                    as ImageProvider
                                : const AssetImage('assets/images/default_profile.png'),
                          ),
                          title: Text(
                            '${doctor.firstName} ${doctor.lastName}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            doctor.category,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          trailing: const Icon(Icons.chat_bubble_outline,
                              color: Color(0xff0064FA)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
