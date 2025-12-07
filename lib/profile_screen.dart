import 'package:flutter/material.dart';
import 'package:medmeet/session_service.dart';
import 'package:medmeet/user_model.dart';
import 'database_helper.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.username);
    _passwordController = TextEditingController(text: widget.user.password);
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = User(
        id: widget.user.id,
        username: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await DatabaseHelper.instance.updateUser(updatedUser);
      
      await SessionService.addAccount(updatedUser.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Профіль оновлено'), backgroundColor: Color(0xFF2EB872)),
      );
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Мій профіль'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF2EB872),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              SizedBox(height: 30),

              TextFormField(
                controller: _emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Email / Логін', prefixIcon: Icon(Icons.email)),
                validator: (val) => val!.isEmpty ? 'Введіть email' : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: 'Новий пароль', prefixIcon: Icon(Icons.lock)),
                validator: (val) => val!.length < 5 ? 'Мін. 5 символів' : null,
              ),

              SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('Зберегти зміни', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}