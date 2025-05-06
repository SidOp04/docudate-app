// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:practice/auth/login_page.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Map<String, dynamic>? userDetails;
  bool _isLoading = true;
  final Color primaryColor = const Color(0xff006AFA);

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        final doctorRef = _database.ref().child('Doctors').child(user.uid);
        final snapshot = await doctorRef.get();

        if (snapshot.exists) {
          setState(() {
            userDetails = Map<String, dynamic>.from(snapshot.value as Map);
          });
        }
      } catch (e) {
        debugPrint('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile(Map<String, String> updates) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _database.ref().child('Doctors').child(uid).update(updates);
      await _fetchUserDetails();
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showEditDialog() {
    final firstNameController = TextEditingController(text: userDetails?['firstName'] ?? '');
    final lastNameController = TextEditingController(text: userDetails?['lastName'] ?? '');
    final cityController = TextEditingController(text: userDetails?['city'] ?? '');
    final qualificationController = TextEditingController(text: userDetails?['qualification'] ?? '');
    final phoneController = TextEditingController(text: userDetails?['phoneNumber'] ?? '');
    final experienceController = TextEditingController(text: userDetails?['yearsOfExperience'] ?? '');
    final categoryController = TextEditingController(text: userDetails?['category'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
              TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
              TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
              TextField(controller: qualificationController, decoration: const InputDecoration(labelText: 'Qualification')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: experienceController, decoration: const InputDecoration(labelText: 'Experience')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Specialization')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final updates = {
                'firstName': firstNameController.text,
                'lastName': lastNameController.text,
                'city': cityController.text,
                'qualification': qualificationController.text,
                'phoneNumber': phoneController.text,
                'yearsOfExperience': experienceController.text,
                'category': categoryController.text,
              };
              _updateProfile(updates);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildDetailRow(String label, String? value, IconData icon) {
    Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: const Color(0xff006AFA)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value ?? 'Not available'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? fullName;
    if (userDetails != null) {
      final first = userDetails!['firstName'] ?? '';
      final last = userDetails!['lastName'] ?? '';
      fullName = '$first $last'.trim();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: userDetails != null
          ? FloatingActionButton(
              onPressed: _showEditDialog,
              backgroundColor: const Color(0xff006AFA),
              child: const Icon(Icons.edit,color: Colors.white,),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userDetails == null
              ? const Center(child: Text('No user data found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            child: const Icon(Icons.person, size: 45, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Text(fullName ?? '', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text("Doctor", style: theme.textTheme.bodySmall),
                          const Divider(height: 30),
                          _buildDetailRow('City', userDetails!['city'], Icons.location_city),
                          _buildDetailRow('Qualification', userDetails!['qualification'], Icons.school,),
                          _buildDetailRow('Phone Number', userDetails!['phoneNumber'], Icons.phone),
                          _buildDetailRow('Email', userDetails!['email'], Icons.email),
                          _buildDetailRow('Experience', userDetails!['yearsOfExperience'], Icons.work),
                          _buildDetailRow('Specialization', userDetails!['category'], Icons.category),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
