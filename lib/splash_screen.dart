import 'package:flutter/material.dart';
import 'package:medmeet/session_service.dart';
import 'package:medmeet/user_model.dart';
import 'database_helper.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    
    await Future.delayed(Duration(seconds: 2));

    final userId = await SessionService.getCurrentUserId();

    if (userId != null) {
      
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (maps.isNotEmpty) {
        final user = User.fromMap(maps.first);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
        return;
      }
    }

    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181A1F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety_rounded, size: 80, color: Color(0xFF2EB872)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Color(0xFF2EB872)),
          ],
        ),
      ),
    );
  }
}