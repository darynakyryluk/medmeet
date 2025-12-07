import 'package:flutter/material.dart';
import 'database_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Введіть Email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Невірний формат Email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введіть новий пароль';
    int digitCount = value.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (digitCount < 5) return 'Пароль має містити мінімум 5 цифр';
    return null;
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      bool exists = await DatabaseHelper.instance.checkUserExists(email);
      if (exists) {
        await DatabaseHelper.instance.updatePassword(email, _newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пароль успішно змінено!'), backgroundColor: Color(0xFF00C853)));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Користувача з таким Email не знайдено'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Скидання паролю')),
      body: Padding(padding: const EdgeInsets.all(24.0), child: Form(key: _formKey, child: Column(children: [
        Text('Введіть ваш Email та новий пароль', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
        SizedBox(height: 30),
        TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'Ваш Email', prefixIcon: Icon(Icons.email, color: Color(0xFF00C853))), validator: _validateEmail),
        SizedBox(height: 20),
        TextFormField(controller: _newPasswordController, decoration: InputDecoration(labelText: 'Новий пароль', prefixIcon: Icon(Icons.lock_reset, color: Color(0xFF00C853))), validator: _validatePassword),
        SizedBox(height: 30),
        ElevatedButton(onPressed: _resetPassword, style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)), child: Text('Змінити пароль', style: TextStyle(fontWeight: FontWeight.bold))),
      ]))),
    );
  }
}
