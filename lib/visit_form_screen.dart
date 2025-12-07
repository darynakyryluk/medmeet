import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../visit_model.dart';
import 'database_helper.dart';

class VisitFormScreen extends StatefulWidget {
  final int userId;
  final Visit? visit;

  VisitFormScreen({required this.userId, this.visit});

  @override
  _VisitFormScreenState createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _doctorController;
  late TextEditingController _specialtyController;
  late TextEditingController _diagnosisController;
  late TextEditingController _notesController;
  late TextEditingController _priceController;
  late TextEditingController _tagsController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isCompleted = false;
  String _selectedCategory = 'Плановий';

  @override
  void initState() {
    super.initState();
    _doctorController = TextEditingController(text: widget.visit?.doctorName ?? '');
    _specialtyController = TextEditingController(text: widget.visit?.specialty ?? '');
    _diagnosisController = TextEditingController(text: widget.visit?.diagnosis ?? '');
    _notesController = TextEditingController(text: widget.visit?.notes ?? '');
    _priceController = TextEditingController(text: widget.visit?.price.toString() ?? '');
    _tagsController = TextEditingController(text: widget.visit?.tags ?? '');
    if (widget.visit != null) {
      _selectedDate = widget.visit!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.visit!.date);
      _isCompleted = widget.visit!.isCompleted;
      _selectedCategory = widget.visit!.category;
    }
  }

  _pickDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      
      builder: (context, child) => Theme(data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF252830),
          onSurface: Colors.white,
        ),
      ), child: child!),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF252830),
          onSurface: Colors.white,
        ),
      ), child: child!),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _selectedTime = time;
    });
  }

  void _saveVisit() async {
    if (_formKey.currentState!.validate()) {
      final visit = Visit(
        id: widget.visit?.id,
        userId: widget.userId,
        doctorName: _doctorController.text,
        specialty: _specialtyController.text,
        date: _selectedDate,
        diagnosis: _diagnosisController.text,
        notes: _notesController.text,
        price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
        isCompleted: _isCompleted,
        tags: _tagsController.text,
        category: _selectedCategory,
      );

      if (widget.visit == null) {
        await DatabaseHelper.instance.createVisit(visit);
      } else {
        await DatabaseHelper.instance.updateVisit(visit);
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.visit == null ? 'Новий візит' : 'Редагувати')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            InkWell(
              onTap: () => _pickDateTime(context),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: const Color(0xFF252830), 
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3))
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF00E676)),
                  const SizedBox(width: 10),
                  Text(DateFormat('dd MMMM yyyy, HH:mm').format(_selectedDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(controller: _doctorController, decoration: const InputDecoration(labelText: 'Лікар (ПІБ)', prefixIcon: Icon(Icons.person)), validator: (val) => val!.isEmpty ? 'Обов\'язкове поле' : null, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 15),
            TextFormField(controller: _specialtyController, decoration: const InputDecoration(labelText: 'Спеціальність/посада', prefixIcon: Icon(Icons.work)), validator: (val) => val!.isEmpty ? 'Обов\'язкове поле' : null, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 15),
            TextFormField(controller: _diagnosisController, decoration: const InputDecoration(labelText: 'Діагноз / Мета візиту', prefixIcon: Icon(Icons.notes)), maxLines: 2, validator: (val) => val!.isEmpty ? 'Обов\'язкове поле' : null, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 15),
            TextFormField(controller: _tagsController, decoration: const InputDecoration(labelText: 'Теги (через кому)', prefixIcon: Icon(Icons.sell)), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 15),
            TextFormField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Вартість візиту (грн)', prefixIcon: Icon(Icons.attach_money)), style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['Плановий', 'Терміновий', 'Контрольний'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
              dropdownColor: const Color(0xFF252830),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: 'Категорія візиту', prefixIcon: Icon(Icons.category)),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Візит вже відбувся?', style: TextStyle(color: Colors.white)),
              value: _isCompleted,
              activeColor: const Color(0xFF00E676),
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _isCompleted = val),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveVisit,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), shadowColor: const Color(0xFF00E676).withOpacity(0.5), elevation: 8),
              child: const Text('ЗБЕРЕГТИ ЗАПИС', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ]),
        ),
      ),
    );
  }
}