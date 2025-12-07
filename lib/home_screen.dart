import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medmeet/session_service.dart';
import 'package:medmeet/symptom_analytics_screen.dart';
import 'user_model.dart';
import 'visit_model.dart';
import 'database_helper.dart';
import 'visit_form_screen.dart';
import 'visit_details_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Visit>> _visitsFuture;
  String _searchQuery = '';
  String _filter = 'Всі'; 

  @override
  void initState() {
    super.initState();
    _refreshVisits();
  }

  void _refreshVisits() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _visitsFuture = DatabaseHelper.instance.getVisits(widget.user.id!);
      } else {
        _visitsFuture = DatabaseHelper.instance.searchVisits(widget.user.id!, _searchQuery);
      }
    });
  }

  String _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    final difference = dateOnly.difference(nowOnly).inDays;

    if (difference == 0) return 'Сьогодні';
    if (difference == 1) return 'Завтра';
    if (difference < 0) return 'Минуло';
    return 'Через $difference дн.';
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      decoration: BoxDecoration(color: Color(0xFF252830), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, size: 20, color: isDestructive ? Colors.redAccent : Colors.white70), onPressed: onTap, constraints: BoxConstraints(minWidth: 40, minHeight: 40)),
    );
  }

  Widget _filterChip(String text) {
    final active = _filter == text;
    return GestureDetector(
      onTap: () => setState(() {
        _filter = text;
        _refreshVisits();
      }),
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Color(0xFF2EB872) : Color(0xFF252830),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  List<Visit> _applyFilter(List<Visit> visits) {
    if (_filter == 'Майбутні') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return visits.where((v) => !v.isCompleted && (v.date.isAtSameMomentAs(today) || v.date.isAfter(today))).toList();
    } else if (_filter == 'Завершені') {
      return visits.where((v) => v.isCompleted).toList();
    }
    return visits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Visit>>(
        future: _visitsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Color(0xFF2EB872)));
          final visitsAll = snapshot.data!;
          final visits = _applyFilter(visitsAll);
          Visit? nextVisit;
          try {
            final now = DateTime.now();
            final todayStart = DateTime(now.year, now.month, now.day);
            final futureVisits = visits.where((v) => !v.isCompleted && (v.date.isAfter(todayStart) || v.date.isAtSameMomentAs(todayStart))).toList();
            futureVisits.sort((a, b) => a.date.compareTo(b.date));
            if (futureVisits.isNotEmpty) nextVisit = futureVisits.first;
          } catch (e) {}

          
          final filtered = visits.where((v) {
            final q = _searchQuery.toLowerCase();
            return v.doctorName.toLowerCase().contains(q) ||
                v.specialty.toLowerCase().contains(q) ||
                v.tags.toLowerCase().contains(q) ||
                v.diagnosis.toLowerCase().contains(q);
          }).toList();

          return CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: true,
                backgroundColor: Color(0xFF181A1F),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                  title: Text('Моє здоров\'я', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                ),
                actions: [
                  _buildIconBtn(Icons.analytics_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => SymptomAnalyticsScreen(user: widget.user))).then((_) => _refreshVisits())),
                  _buildIconBtn(Icons.calendar_month, () => Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarScreen(userId: widget.user.id!))).then((_) => _refreshVisits())),
                  _buildIconBtn(Icons.bar_chart_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => StatsScreen(user: widget.user))).then((_) => _refreshVisits())),
                  _buildIconBtn(Icons.settings_rounded, () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(user: widget.user))).then((_) => _refreshVisits())),
                  _buildIconBtn(Icons.logout_rounded, ()
                  async {
                    await SessionService. removeAccount(widget.user.id!); Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen())
                    );
                  },
                      isDestructive: true),
                  SizedBox(width: 10),
                ],
              ),

              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 22, backgroundColor: Color(0xFF2EB872).withOpacity(0.2), child: Icon(Icons.person, color: Color(0xFF2EB872))),
                      SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Вітаю', style: TextStyle(color: Colors.white54)),
                        Text(widget.user.username, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                      Spacer(),
                      
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarScreen(userId: widget.user.id!))).then((_) => _refreshVisits()),
                        icon: Icon(Icons.event),
                        label: Text('Календар'),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF252830)),
                      )
                    ],
                  ),
                ),
              ),

              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Знайти запис...',
                      prefixIcon: Icon(Icons.search_rounded),
                      fillColor: Color(0xFF252830),
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Color(0xFF2EB872))),
                    ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _refreshVisits();
                    },
                  ),
                ),
              ),

              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _filterChip('Всі'),
                        _filterChip('Майбутні'),
                        _filterChip('Завершені'),
                      ],
                    ),
                  ),
                ),
              ),

              
              if (nextVisit != null && _searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VisitDetailsScreen(visit: nextVisit!))).then((val) { if (val == true) _refreshVisits(); }),
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF2EB872), Color(0xFF009688)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Color(0xFF2EB872).withOpacity(0.3), blurRadius: 20, offset: Offset(0, 10))],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: Row(children: [Icon(Icons.access_time_filled, size: 14, color: Colors.white), SizedBox(width: 6), Text(_getDaysUntil(nextVisit.date), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]),
                            ),
                            Icon(Icons.arrow_outward_rounded, color: Colors.white70),
                          ]),
                          SizedBox(height: 20),
                          Text(nextVisit.doctorName, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(nextVisit.specialty, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                          SizedBox(height: 15),
                          Divider(color: Colors.white24),
                          SizedBox(height: 5),
                          Row(children: [Icon(Icons.calendar_month_rounded, size: 18, color: Colors.white), SizedBox(width: 8), Text(DateFormat('d MMMM, HH:mm').format(nextVisit.date), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))]),
                        ]),
                      ),
                    ),
                  ),
                ),

              
              SliverToBoxAdapter(
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), child: Text("Всі записи", style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1))),
              ),

              
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: filtered.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final visit = filtered[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VisitDetailsScreen(visit: visit))).then((val) { if (val == true) _refreshVisits(); }),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFF252830),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: visit.isCompleted ? Colors.transparent : Colors.white.withOpacity(0.05)),
                            ),
                            child: Row(children: [
                              Container(
                                height: 50, width: 50,
                                decoration: BoxDecoration(color: visit.isCompleted ? Color(0xFF1E2025) : Color(0xFF2EB872).withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
                                child: Icon(visit.isCompleted ? Icons.check_rounded : Icons.medical_services_rounded, color: visit.isCompleted ? Colors.grey : Color(0xFF2EB872)),
                              ),
                              SizedBox(width: 16),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(visit.doctorName, style: TextStyle(color: visit.isCompleted ? Colors.grey : Colors.white, fontWeight: FontWeight.bold, fontSize: 16, decoration: visit.isCompleted ? TextDecoration.lineThrough : null)),
                                SizedBox(height: 4),
                                Text('${visit.specialty} • ${DateFormat('d MMM').format(visit.date)} • ${visit.category}', style: TextStyle(color: Colors.white38, fontSize: 13)),
                                if (visit.tags.isNotEmpty) SizedBox(height: 6),
                                if (visit.tags.isNotEmpty) Text(visit.tags.split(',').map((t) => t.trim()).where((t)=>t.isNotEmpty).join(' • '), style: TextStyle(color: Colors.white24, fontSize: 12)),
                              ])),
                              if (visit.price > 0)
                                Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Color(0xFF181A1F), borderRadius: BorderRadius.circular(10)), child: Text('${visit.price.toInt()} ₴', style: TextStyle(color: Color(0xFF2EB872), fontWeight: FontWeight.bold, fontSize: 12)))
                              else
                                Icon(Icons.chevron_right_rounded, color: Colors.white24),
                            ]),
                          ),
                        ),
                      ),
                    );
                  }, childCount: filtered.length),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Color(0xFF2EB872).withOpacity(0.4), blurRadius: 20)]),
        child: FloatingActionButton.extended(
          backgroundColor: Color(0xFF2EB872),
          elevation: 10,
          icon: Icon(Icons.add_rounded, color: Colors.white),
          label: Text("Запис", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => VisitFormScreen(userId: widget.user.id!))).then((val) { if (val == true) _refreshVisits(); });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Column(children: [Icon(Icons.note_alt_outlined, size: 80, color: Colors.white10), SizedBox(height: 16), Text('Ще немає записів', style: TextStyle(color: Colors.white38, fontSize: 16))]),
      ),
    );
  }
}
