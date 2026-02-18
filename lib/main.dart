import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logbook_app_068/features/onboarding/onboarding_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LogBook App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF6E5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF8C8DC)),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(), 
      ),
      home: const OnboardingView(), 
    );
  }
}