import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice/auth/signup_screen.dart';
import 'package:practice/doctor/doctor_home_page.dart';
import 'package:practice/patient/patient_home_page.dart';
import 'package:practice/admin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;
  bool _isNavigation = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 48,
                          ),
                          Image.asset('assets/images/plus.png'),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Welcome!',
                            style: GoogleFonts.poppins(
                                fontSize: 32, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Login first',
                            style: GoogleFonts.poppins(
                                fontSize: 24, fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          SizedBox(
                            height: 44,
                            child: TextFormField(
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF0EFFF),
                                contentPadding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                labelText: 'Email',
                                labelStyle: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Rounded corners
                                  borderSide: const BorderSide(
                                    color:
                                        Color(0xff006AFA), // Blue border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Color(
                                        0xff006AFA), // Blue border color when focused
                                    width: 1.0, // Border width
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Color(
                                        0xff006AFA), // Blue border color when not focused
                                    width: 1.0, // Border width
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (val) => email = val,
                              validator: (val) =>
                                  val!.isEmpty ? 'Enter an email' : null,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 44,
                            child: TextFormField(
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xffF0EFFF),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                labelText: 'Password',
                                labelStyle: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Color(0xff006AFA),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Color(0xff006AFA),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: Color(0xff006AFA),
                                    width: 1.0,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey.shade400,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscureText,
                              keyboardType: TextInputType.text,
                              onChanged: (val) => password = val,
                              validator: (val) => val!.length < 6
                                  ? 'Password must be at least 6 characters'
                                  : null,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xff006AFA), // Blue background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Rounded corners
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical:
                                        12), // Optional: Padding inside the button
                              ),
                              child: Text(
                                'Login',
                                style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4), // Text color
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const RegisterPage()));
                              },
                              child: const Text(
                                'Don’t have an account? Register',
                                style: TextStyle(color: Color(0xff006AFA)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          DatabaseReference userRef = _database.child('Admin').child(user.uid);
          DataSnapshot snapshot = await userRef.get();
          if (snapshot.exists) {
            _navigateToAdmin();
          } else {
            userRef = _database.child('Doctors').child(user.uid);
            snapshot = await userRef.get();

            if (snapshot.exists) {
              _navigateToDoctorHome();
            } else {
              userRef = _database.child('Patients').child(user.uid);
              snapshot = await userRef.get();
              if (snapshot.exists) {
                _navigateToPatientHome();
              } else {
                _showErrorDialog('User not found');
              }
            }
          }
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDoctorHome() {
    if (!_isNavigation) {
      _isNavigation = true;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const DoctorHomePage()));
    }
  }

  void _navigateToPatientHome() {
    if (!_isNavigation) {
      _isNavigation = true;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const PatientHomePage()));
    }
  }

  void _navigateToAdmin() {
    if (!_isNavigation) {
      _isNavigation = true;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AdminPage()));
    }
  }
}
