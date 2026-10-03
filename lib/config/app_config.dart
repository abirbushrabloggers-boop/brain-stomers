import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';

class BrainStomersApp extends StatelessWidget {
  const BrainStomersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Stomers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B5CE6),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.hindSiliguriTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF4F7FF),
      ),
      home: const HomeScreen(),
    );
  }
}
