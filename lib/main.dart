import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banksample/screens/onboarding_screen.dart';
import 'package:banksample/screens/home_screen.dart';
// import 'package:banksample/services/notification_service.dart'; // Import the notification service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notification service early
  // await NotificationService().initNotifications();

  // Check if onboarding is complete
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;

  const MyApp({Key? key, required this.onboardingComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quit Weed App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Navigate based on onboarding status
      home: onboardingComplete ? HomeScreen() : OnboardingScreen(),
    );
  }
}
