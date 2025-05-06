import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() async {
  // Ensures that widget binding is initialized before Firebase setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes Firebase services for the app
  await Firebase.initializeApp();

  // Runs the root widget of the application
  runApp(MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hides the debug banner in the top-right corner of the app
      debugShowCheckedModeBanner: false,

      // Sets SplashScreen as the initial screen of the app
      home: SplashScreen(),
    );
  }
}

//Visual Studio Build Tools 2019 - 16.11.44
//Visual Studio Community 2022 - 17.13.5
//Android Studio Giraffe - 2022.3.1 Patch 2
//Flutter - 3.27.2