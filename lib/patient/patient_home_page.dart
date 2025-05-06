import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practice/doctor/doctor_list_page.dart';
import 'package:practice/patient/chat_list_page.dart';
import 'package:practice/profile_page.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _children = [
    const DoctorListPage(),
    const ChatListPage(),
    const ProfilePage(),
  ];

  void _onItmTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
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
                )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default back behavior
      onPopInvoked: (didPop) async {
        if (didPop) return;

        bool exitApp = await _onWillPop();
        if (exitApp) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: _children.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xff0064FA),
          unselectedItemColor: const Color(0xffBEBEBE),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_filled,
                ),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.chat,
                ),
                label: 'Chat'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                ),
                label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItmTapped,
        ),
      ),
    );
  }
}
