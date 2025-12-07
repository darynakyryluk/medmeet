import 'package:flutter/material.dart';
import 'package:medmeet/session_service.dart';
import 'database_helper.dart';
import 'user_model.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введіть Email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Невалідний Email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введіть пароль';
    if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 5) return 'Пароль має містити мінімум 5 цифр';
    return null;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isLogin) {
      final user = await DatabaseHelper.instance.loginUser(email, password);
      if (user != null) {
        await SessionService.addAccount(user.id!);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка входу'), backgroundColor: Colors.redAccent));
      }
    } else {
      final newUser = User(username: email, password: password);
      final result = await DatabaseHelper.instance.registerUser(newUser);
      if (result != -1) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Успішна реєстрація')));
        setState(() => _isLogin = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Користувач існує'), backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF181A1F), Color(0xFF0F3D2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF2EB872).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.health_and_safety_rounded, size: 60, color: Color(0xFF2EB872)),
                  ),
                  SizedBox(height: 30),
                  Text(_isLogin ? 'З поверненням!' : 'Створити акаунт', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 10),
                  Text('Плануй, слідкуй, будь здоровим.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  if (_isLogin)
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen())), child: Text('Забули пароль?', style: TextStyle(color: Color(0xFF2EB872))))),
                  SizedBox(height: 10),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(onPressed: _submit, child: Text(_isLogin ? 'Увійти' : 'Зареєструватися', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _formKey.currentState?.reset();
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin ? 'Немає акаунту? ' : 'Вже є акаунт? ',
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(text: _isLogin ? 'Реєстрація' : 'Вхід', style: TextStyle(color: Color(0xFF2EB872), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
