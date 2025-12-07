import 'package:flutter/material.dart';
import 'package:medmeet/visit_model.dart';
import 'database_helper.dart';

class EditVisitScreen extends StatefulWidget {
  final Visit visit;

  const EditVisitScreen({Key? key, required this.visit}) : super(key: key);

  @override
  State<EditVisitScreen> createState() => _EditVisitScreenState();
}

class _EditVisitScreenState extends State<EditVisitScreen> {
  late TextEditingController _doctorController;
  late TextEditingController _specialtyController;
  late TextEditingController _notesController;
  late TextEditingController _tagsController;
  late TextEditingController _priceController;

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Planned';

  @override
  void initState() {
    super.initState();

    _doctorController =
        TextEditingController(text: widget.visit.doctorName);
    _specialtyController =
        TextEditingController(text: widget.visit.specialty);
    _notesController =
        TextEditingController(text: widget.visit.notes ?? '');
    _tagsController =
        TextEditingController(text: widget.visit.tags ?? '');
    _priceController =
        TextEditingController(text: widget.visit.price.toString());

    _selectedDate = widget.visit.date;
    _selectedCategory = widget.visit.category ?? 'Planned';
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _specialtyController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final updated = widget.visit.copyWith(
      doctorName: _doctorController.text.trim(),
      specialty: _specialtyController.text.trim(),
      notes: _notesController.text.trim(),
      tags: _tagsController.text.trim(),
      category: _selectedCategory,
      price: double.tryParse(_priceController.text) ?? 0,
      date: _selectedDate,
    );

    await DatabaseHelper.instance.updateVisit(updated);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Редагувати візит'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            
            _textField(
              controller: _doctorController,
              label: 'Ім\`я лікаря',
              icon: Icons.person,
            ),

            
            _textField(
              controller: _specialtyController,
              label: 'Посада/спеціальність',
              icon: Icons.local_hospital,
            ),

            
            _datePicker(theme),

            
            _categoryDropdown(theme),

            
            _textField(
              controller: _tagsController,
              label: 'Теги (через кому)',
              icon: Icons.sell,
            ),

            
            _textField(
              controller: _priceController,
              label: 'Вартість',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),

            
            _notesField(),

            const SizedBox(height: 30),

            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Зберегти зміни'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _save,
              ),
            )
          ],
        ),
      ),
    );
  }

  

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _notesField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Діагноз/нотатки',
          alignLabelWithHint: true,
          prefixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _datePicker(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: _selectDateTime,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Дата & час',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Text(
                _formatDate(_selectedDate),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Категорія',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: ['Planned', 'Urgent', 'Follow-up']
            .map((e) =>
            DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _selectedCategory = val;
            });
          }
        },
      ),
    );
  }

  

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
