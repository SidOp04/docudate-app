import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice/doctor/model/doctor.dart';
import 'package:practice/doctor/widget/doctor_card.dart';
import 'package:practice/patient/patient_card.dart';
import 'package:practice/patient/patient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice/auth/login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _doctors = [];
  final DatabaseReference _databasePatients =
      FirebaseDatabase.instance.ref().child('Patients');
  List<Patient> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchDoctors();
    _fetchPatients();
  }

  Future<void> _fetchDoctors() async {
    await _database.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tmpDoctors.add(doctor);
        });
      }
      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    });
  }

  Future<bool> _onWilPop() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      SystemNavigator.pop();
                    },
                    child: const Text('Yes')),
              ],
            ));
  }

  Future<void> _fetchPatients() async {
    await _databasePatients.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Patient> tmpPatients = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Patient patient = Patient.fromMap(value, key);
          tmpPatients.add(patient);
        });
      }
      setState(() {
        _patients = tmpPatients;
        _isLoading = false;
      });
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWilPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Admin Page',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white,),
              )
            ],
            backgroundColor: const Color(0xff006AFA),
            elevation: 0,
            automaticallyImplyLeading: false, // Removes the back icon
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _doctors.length + 1 + _patients.length,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Text(
                                    'Doctors',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }
                              if (index < _doctors.length) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text('Doctor Details'),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit,
                                                            color: Colors.blue),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              TextEditingController
                                                                  nameController =
                                                                  TextEditingController(
                                                                      text: _doctors[
                                                                              index]
                                                                          .firstName);
                                                              TextEditingController
                                                                  categoryController =
                                                                  TextEditingController(
                                                                      text: _doctors[
                                                                              index]
                                                                          .category);

                                                              TextEditingController
                                                                  experienceController =
                                                                  TextEditingController(
                                                                      text: _doctors[
                                                                              index]
                                                                          .yearsOfExperience
                                                                          .toString());
                                                              TextEditingController
                                                                  phoneController =
                                                                  TextEditingController(
                                                                      text: _doctors[
                                                                              index]
                                                                          .phoneNumber);

                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Edit Doctor Details'),
                                                                content: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    TextField(
                                                                      controller:
                                                                          nameController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              labelText: 'Name'),
                                                                    ),
                                                                    TextField(
                                                                      controller:
                                                                          categoryController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              labelText: 'Specialization'),
                                                                    ),
                                                                    TextField(
                                                                      controller:
                                                                          experienceController,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              labelText: 'Experience (years)'),
                                                                    ),
                                                                    TextField(
                                                                      controller:
                                                                          phoneController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              labelText: 'Contact'),
                                                                    ),
                                                                  ],
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: const Text(
                                                                        'Cancel'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await _database
                                                                          .child(
                                                                              _doctors[index].uid)
                                                                          .update({
                                                                        'firstName':
                                                                            nameController.text,
                                                                        'category':
                                                                            categoryController.text,
                                                                        'yearsOfExperience':
                                                                            int.parse(experienceController.text),
                                                                        'phoneNumber':
                                                                            phoneController.text,
                                                                      });
                                                                      setState(
                                                                          () {
                                                                        _doctors[index].firstName =
                                                                            nameController.text;
                                                                        _doctors[index].category =
                                                                            categoryController.text;
                                                                        _doctors[index].yearsOfExperience =
                                                                            experienceController.text;
                                                                        _doctors[index].phoneNumber =
                                                                            phoneController.text;
                                                                      });
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: const Text(
                                                                        'Save'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () async {
                                                          await _database
                                                              .child(_doctors[
                                                                      index]
                                                                  .uid)
                                                              .remove();
                                                          setState(() {
                                                            _doctors.removeAt(
                                                                index);
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Name: ${_doctors[index].firstName}'),
                                                  Text(
                                                      'Specialization: ${_doctors[index].category}'),
                                                  Text(
                                                      'Experience: ${_doctors[index].yearsOfExperience} years'),
                                                  Text(
                                                      'Contact: ${_doctors[index].phoneNumber}'),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child:
                                          DoctorCard(doctor: _doctors[index]),
                                    ),
                                    const SizedBox(
                                      height: 10, // Add spacing between items
                                    ),
                                  ],
                                );
                              } else if (index == _doctors.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Text(
                                    'Patients',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              } else {
                                int patientIndex = index - _doctors.length - 1;
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text('Patient Details'),
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit,
                                                            color: Colors.blue),
                                                        onPressed: () {
                                                          // Navigate to edit page or show edit form
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              TextEditingController
                                                                  nameController =
                                                                  TextEditingController(
                                                                      text: _patients[
                                                                              patientIndex]
                                                                          .firstName);
                                                              TextEditingController
                                                                  cityController =
                                                                  TextEditingController(
                                                                      text: _patients[
                                                                              patientIndex]
                                                                          .city);
                                                              TextEditingController
                                                                  emailController =
                                                                  TextEditingController(
                                                                      text: _patients[
                                                                              patientIndex]
                                                                          .email);
                                                              TextEditingController
                                                                  phoneController =
                                                                  TextEditingController(
                                                                      text: _patients[
                                                                              patientIndex]
                                                                          .phoneNumber);

                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Edit Patient Details'),
                                                                content: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    TextField(
                                                                      controller:
                                                                          nameController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              labelText: 'Name'),
                                                                    ),
                                                                    TextField(
                                                                      controller:
                                                                          cityController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              labelText: 'City'),
                                                                    ),
                                                                    TextField(
                                                                      controller:
                                                                          emailController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              labelText: 'Email'),
                                                                    ),
                                                                    TextField(
                                                                      controller:
                                                                          phoneController,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                              labelText: 'Contact'),
                                                                    ),
                                                                  ],
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: const Text(
                                                                        'Cancel'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await _databasePatients
                                                                          .child(
                                                                              _patients[patientIndex].uid)
                                                                          .update({
                                                                        'firstName':
                                                                            nameController.text,
                                                                        'city':
                                                                            cityController.text,
                                                                        'email':
                                                                            emailController.text,
                                                                        'phoneNumber':
                                                                            phoneController.text,
                                                                      });
                                                                      setState(
                                                                          () {
                                                                        _patients[patientIndex].firstName =
                                                                            nameController.text;
                                                                        _patients[patientIndex].city =
                                                                            cityController.text;
                                                                        _patients[patientIndex].email =
                                                                            emailController.text;
                                                                        _patients[patientIndex].phoneNumber =
                                                                            phoneController.text;
                                                                      });
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: const Text(
                                                                        'Save'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () async {
                                                          await _databasePatients
                                                              .child(_patients[
                                                                      patientIndex]
                                                                  .uid)
                                                              .remove();
                                                          setState(() {
                                                            _patients.removeAt(
                                                                patientIndex);
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Name: ${_patients[patientIndex].firstName}'),
                                                  Text(
                                                      'City: ${_patients[patientIndex].city}'),
                                                  Text(
                                                      'Email: ${_patients[patientIndex].email}'),
                                                  Text(
                                                      'Contact: ${_patients[patientIndex].phoneNumber}'),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: PatientCard(
                                          patient: _patients[patientIndex]),
                                    ),
                                    const SizedBox(
                                      height: 10, // Add spacing between items
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }
}
