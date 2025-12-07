import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../visit_model.dart';
import 'visit_form_screen.dart';
import '../time.dart';

class VisitDetailsScreen extends StatelessWidget {
  final Visit visit;

  const VisitDetailsScreen({Key? key, required this.visit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Деталі візиту'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            
            _infoCard(
              context,
              icon: Icons.person,
              title: 'Лікар',
              value: visit.doctorName,
            ),

            
            _infoCard(
              context,
              icon: Icons.local_hospital,
              title: 'Спеціальність',
              value: visit.specialty,
            ),

            
            _infoCard(
              context,
              icon: Icons.calendar_month,
              title: 'Дата та Час',
              value: '${_formatDate(visit.date)} о ${_formatTime(visit.date)}',
            ),

            
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 8, bottom: 14),
              child: Text(
                timeAgo(visit.date),
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),

            
            if (visit.category.isNotEmpty)
              _infoCard(
                context,
                icon: Icons.category,
                title: 'Категорія',
                value: visit.category,
              ),

            
            if (visit.price > 0)
              _infoCard(
                context,
                icon: Icons.attach_money,
                title: 'Вартість',
                value: '${visit.price.toInt()} ₴',
              ),

            
            if (visit.tags.isNotEmpty)
              _tagsBlock(context, visit.tags),

            
            if (visit.notes.isNotEmpty)
              _bigTextBlock(
                context,
                icon: Icons.description,
                title: 'Нотатки',
                text: visit.notes,
              ),

            
            if (visit.diagnosis.isNotEmpty && visit.diagnosis != visit.notes)
              _bigTextBlock(
                context,
                icon: Icons.medical_information,
                title: 'Діагноз',
                text: visit.diagnosis,
              ),

            const SizedBox(height: 30),

            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Редагувати', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EB872),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: const Color(0xFF2EB872).withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VisitFormScreen(
                            userId: visit.userId,
                            visit: visit,
                          ),
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  

  Widget _infoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
      }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), 
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigTextBlock(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String text,
      }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              height: 1.4,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagsBlock(BuildContext context, String tags) {
    final tagList = tags
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tagList.map((tag) {
          return Chip(
            label: Text(tag),
            backgroundColor: Colors.white.withOpacity(0.1), 
            labelStyle: const TextStyle(color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}