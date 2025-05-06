import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String? doctorId;
  final String? doctorName;
  final String? patientId;
  final String? patientName;

  ChatScreen({
    this.doctorId,
    this.doctorName,
    this.patientId,
    this.patientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _chatListDatabase =
      FirebaseDatabase.instance.ref().child('ChatList');
  final DatabaseReference _chatDatabase =
      FirebaseDatabase.instance.ref().child('Chat');
  final TextEditingController _messageController = TextEditingController();
  String? _currentUserId;

  bool get isDoctor => _currentUserId == widget.doctorId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      String message = _messageController.text.trim();
      String chatId = _chatDatabase.push().key!;
      String timeStamp = DateTime.now().toIso8601String();

      String senderUid = _currentUserId!;
      String receiverUid = isDoctor ? widget.patientId! : widget.doctorId!;

      _chatDatabase.child(chatId).set({
        'message': message,
        'receiver': receiverUid,
        'sender': senderUid,
        'timestamp': timeStamp,
      });

      _chatListDatabase.child(senderUid).child(receiverUid).set({
        'id': receiverUid,
      });
      _chatListDatabase.child(receiverUid).child(senderUid).set({
        'id': senderUid,
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    String? chatPartnerName = isDoctor ? widget.patientName : widget.doctorName;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xffF7F7FB),
        appBar: AppBar(
          title: Text(
            chatPartnerName ?? '',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white
            ),
          ),
          backgroundColor: const Color(0xff006AFA),
          elevation: 1,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _chatDatabase.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data?.snapshot.value == null) {
                    return Center(
                      child: Text(
                        'No messages yet.',
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }

                  Map<dynamic, dynamic> messagesMap =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<String, dynamic>> messagesList = [];

                  messagesMap.forEach((key, value) {
                    if ((value['sender'] == _currentUserId &&
                            value['receiver'] == widget.doctorId) ||
                        (value['sender'] == widget.doctorId &&
                            value['receiver'] == _currentUserId) ||
                        (value['sender'] == _currentUserId &&
                            value['receiver'] == widget.patientId) ||
                        (value['sender'] == widget.patientId &&
                            value['receiver'] == _currentUserId)) {
                      messagesList.add({
                        'message': value['message'],
                        'sender': value['sender'],
                        'timestamp': value['timestamp'],
                      });
                    }
                  });

                  messagesList.sort(
                      (a, b) => a['timestamp'].compareTo(b['timestamp']));

                  return ListView.builder(
  padding: const EdgeInsets.symmetric(vertical: 10),
  itemCount: messagesList.length,
  itemBuilder: (context, index) {
    bool isMe = messagesList[index]['sender'] == _currentUserId;

    // Parse and format timestamp
    DateTime messageTime = DateTime.parse(messagesList[index]['timestamp']);
    String formattedTime = DateFormat('hh:mm a').format(messageTime);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? const Color.fromARGB(255, 228, 228, 228) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              messagesList[index]['message'],
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  },
);

                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                    color: Colors.black.withOpacity(0.05),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xffF0EFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xff006AFA),
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
