import 'package:flutter/material.dart';
import 'package:medmeet/visit_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'visit_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  final int userId;
  CalendarScreen({required this.userId});
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Visit>> _events = {};

  
  final Color primaryGreen = const Color(0xFF2EB872);
  final Color cardColor = const Color(0xFF252830);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    final visits = await DatabaseHelper.instance.getVisits(widget.userId);
    setState(() {
      _events = {};
      for (var v in visits) {
        
        final day = DateTime(v.date.year, v.date.month, v.date.day);
        _events.putIfAbsent(day, () => []).add(v);
      }
    });
  }

  List<Visit> _getEvents(DateTime day) {
    
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Календар візитів'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(children: [
        
        TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2100),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEvents,
          startingDayOfWeek: StartingDayOfWeek.monday, 

          
          headerStyle: const HeaderStyle(
            formatButtonVisible: false, 
            titleCentered: true,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey),
          ),

          
          calendarStyle: CalendarStyle(
            
            selectedDecoration: BoxDecoration(
              color: primaryGreen,
              shape: BoxShape.circle,
            ),
            
            todayDecoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            
            markerDecoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            
            defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
            weekendTextStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),

          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
          },
        ),

        const SizedBox(height: 20),

        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Події на ${DateFormat('dd.MM.yyyy').format(_selectedDay!)}",
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _getEvents(_selectedDay ?? _focusedDay).map((v) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor, 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      v.isCompleted ? Icons.check : Icons.medical_services_rounded,
                      color: v.isCompleted ? Colors.grey : primaryGreen,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    v.doctorName,
                    style: TextStyle(
                      color: v.isCompleted ? Colors.grey : Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: v.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    '${v.specialty} • ${v.category}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('HH:mm').format(v.date),
                      style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                      ),
                    ),
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VisitDetailsScreen(visit: v))
                  ).then((_) => _loadVisits()),
                ),
              );
            }).toList(),
          ),
        )
      ]),
    );
  }
}