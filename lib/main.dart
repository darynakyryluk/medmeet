import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medmeet/splash_screen.dart';

import 'login_screen.dart';

void main() {
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediLog',
      debugShowCheckedModeBanner: false,

      
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2EB872),
        scaffoldBackgroundColor: const Color(0xFF181A1F), 

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2EB872),
          secondary: Color(0xFF66F0B4),
          surface: Color(0xFF252830), 
          onSurface: Colors.white,
          background: Color(0xFF181A1F),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181A1F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF252830),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252830),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2EB872), width: 1.5)),
          prefixIconColor: const Color(0xFF8E99A6),
          labelStyle: const TextStyle(color: Color(0xFF8E99A6)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2EB872),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFF2EB872).withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),

      home:SplashScreen(),
    );
  }
}