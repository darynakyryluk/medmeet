import 'package:flutter/material.dart';
import 'package:medmeet/user_model.dart';
import '../session_service.dart';
import 'database_helper.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  final User user;
  SettingsScreen({required this.user});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<User> _otherAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadOtherAccounts();
  }

  void _loadOtherAccounts() async {
    final allIds = await SessionService.getSavedAccountIds();
    final db = DatabaseHelper.instance;
    List<User> loaded = [];

    for (int id in allIds) {
      if (id != widget.user.id) {
        final userList = await db.database.then((d) => d.query('users', where: 'id = ?', whereArgs: [id]));
        if (userList.isNotEmpty) {
          loaded.add(User.fromMap(userList.first));
        }
      }
    }
    setState(() {
      _otherAccounts = loaded;
    });
  }

  void _switchAccount(User targetUser) async {
    await SessionService.switchAccount(targetUser.id!);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen(user: targetUser)), (route) => false);
  }

  void _addNewAccount() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  void _logout() async {
    await SessionService.removeAccount(widget.user.id!);
    final ids = await SessionService.getSavedAccountIds();
    if (ids.isNotEmpty) {
      final db = DatabaseHelper.instance;
      final userList = await db.database.then((d) => d.query('users', where: 'id = ?', whereArgs: [ids.first]));
      if (userList.isNotEmpty) {
        _switchAccount(User.fromMap(userList.first));
        return;
      }
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252830),
        title: const Text('Видалити акаунт?', style: TextStyle(color: Colors.white)),
        content: const Text('Ця дія незворотна.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Скасувати', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteAccount(widget.user.id!);
              await SessionService.removeAccount(widget.user.id!);
              Navigator.of(ctx).pop();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Видалити', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A1F), 
      appBar: AppBar(
        title: const Text('Налаштування'),
        backgroundColor: const Color(0xFF181A1F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Поточний акаунт", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),

          
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF252830), 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2EB872), width: 1.5), 
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2EB872),
                child: Text(
                  widget.user.username.isNotEmpty ? widget.user.username[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                  widget.user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white) 
              ),
              subtitle: const Text('Активний зараз', style: TextStyle(color: Color(0xFF2EB872))),
              trailing: IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: _logout,
                tooltip: "Вийти",
              ),
            ),
          ),

          const SizedBox(height: 30),

          if (_otherAccounts.isNotEmpty) ...[
            const Text("Інші акаунти", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            ..._otherAccounts.map((u) => Card(
              color: const Color(0xFF252830),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () => _switchAccount(u),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[700],
                  child: Text(u.username[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(u.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.swap_horiz, color: Colors.grey),
              ),
            )).toList(),
          ],

          Card(
            color: const Color(0xFF252830),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              onTap: _addNewAccount,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF2EB872).withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Color(0xFF2EB872), size: 20),
              ),
              title: const Text("Додати акаунт", style: TextStyle(color: Color(0xFF2EB872), fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 40),

          Card(
            color: Colors.red.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.red.withOpacity(0.2))),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Видалити акаунт', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () => _confirmDelete(context),
            ),
          ),
        ],
      ),
    );
  }
}