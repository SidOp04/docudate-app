import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:practice/auth/login_page.dart';
import 'doctor/model/booking.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance.ref().child('Requests');

  Map<String, dynamic>? userDetails;
  List<Booking> _bookings = [];
  String userType = '';
  bool _isLoading = true;

  final Color primaryColor = const Color(0xff006AFA);

  @override
  void initState() {
    super.initState();
    _fetchUserDetailsAndBookings();
  }

  Future<void> _fetchUserDetailsAndBookings() async {
    String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      try {
        final doctorRef = _database.ref().child('Doctors').child(uid);
        final doctorSnapshot = await doctorRef.get();

        if (doctorSnapshot.exists) {
          userDetails = Map<String, dynamic>.from(doctorSnapshot.value as Map);
          userType = 'Doctor';
        } else {
          final patientRef = _database.ref().child('Patients').child(uid);
          final patientSnapshot = await patientRef.get();

          if (patientSnapshot.exists) {
            userDetails = Map<String, dynamic>.from(patientSnapshot.value as Map);
            userType = 'Patient';
          } else {
            userType = 'Unknown';
          }
        }

        await _requestDatabase
            .orderByChild('sender')
            .equalTo(uid)
            .once()
            .then((DatabaseEvent event) {
          if (event.snapshot.value != null) {
            final Map<dynamic, dynamic> bookingMap =
                event.snapshot.value as Map<dynamic, dynamic>;
            _bookings = bookingMap.entries
                .map((e) => Booking.fromMap(Map<String, dynamic>.from(e.value)))
                .toList();
          }
        });
      } catch (e) {
        debugPrint('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false);
  }

  void _showEditDialog() {
    final firstNameController = TextEditingController(text: userDetails?['firstName'] ?? '');
    final lastNameController = TextEditingController(text: userDetails?['lastName'] ?? '');
    final phoneController = TextEditingController(text: userDetails?['phoneNumber'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
            TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                final uid = _auth.currentUser?.uid;
                if (uid != null) {
                  final updates = {
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'phoneNumber': phoneController.text,
                  };
                  await _database.ref().child('Patients').child(uid).update(updates);
                  Navigator.pop(context);
                  _fetchUserDetailsAndBookings();
                }
              },
              child: const Text('Save'))
        ],
      ),
    );
  }

  Widget _buildUserDetails() {
    if (userDetails == null) return const SizedBox.shrink();

    final fullName = '${userDetails!['firstName'] ?? ''} ${userDetails!['lastName'] ?? ''}'.trim();
    final avatarUrl = userDetails!['imageUrl'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile image
              CircleAvatar(
                radius: 45,
                backgroundColor: primaryColor.withOpacity(0.1),
                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                fullName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(userDetails!['email'] ?? '', style: const TextStyle(color: Colors.grey)),
              const Divider(height: 30, thickness: 1),

              // Info rows
              _infoRow(Icons.phone, 'Phone', userDetails!['phoneNumber']),
              if (userType == 'Doctor') ...[
                _infoRow(Icons.school, 'Qualification', userDetails!['qualification']),
                _infoRow(Icons.business, 'City', userDetails!['city']),
                _infoRow(Icons.calendar_today, 'Experience', userDetails!['yearsOfExperience']),
                _infoRow(Icons.category, 'Specialization', userDetails!['category']),
              ],

              // Edit button (Patients only)
              if (userType == 'Patient') ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _showEditDialog,
                  icon: const Icon(Icons.edit,color: Colors.white),
                  label: const Text('Edit',style: TextStyle(color: Colors.white),),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not available',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList() {
  if (_bookings.isEmpty) {
    return const Center(child: Text('No booking available'));
  }

  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: _bookings.length,
    itemBuilder: (context, index) {
      final booking = _bookings[index];
      Color statusColor;

      // Determine the color based on booking status
      switch (booking.status.toLowerCase()) {
        case 'accepted':
          statusColor = Colors.green;
          break;
        case 'rejected':
          statusColor = Colors.red;
          break;
        default:
          statusColor = Colors.grey;
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          title: Text(booking.description),
          subtitle: Text('Date: ${booking.date} Time: ${booking.time}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              border: Border.all(color: statusColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              booking.status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserDetails(),
                  const Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Your Bookings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _buildBookingList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
