import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medmeet/user_model.dart';
import 'database_helper.dart';

class SymptomAnalyticsScreen extends StatefulWidget {
  final User user;

  const SymptomAnalyticsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SymptomAnalyticsScreenState createState() => _SymptomAnalyticsScreenState();
}

class _SymptomAnalyticsScreenState extends State<SymptomAnalyticsScreen> {
  late Future<Map<String, int>> _symptomsFuture;

  @override
  void initState() {
    super.initState();
    _symptomsFuture = _loadAndProcessSymptoms();
  }

  
  Future<Map<String, int>> _loadAndProcessSymptoms() async {
    final visits = await DatabaseHelper.instance.getVisits(widget.user.id!);
    final Map<String, int> tagCounts = {};

    for (var visit in visits) {
      if (visit.tags.isNotEmpty) {
        
        final tags = visit.tags.split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty);

        for (var tag in tags) {
          
          final formattedTag = tag[0].toUpperCase() + tag.substring(1);
          tagCounts[formattedTag] = (tagCounts[formattedTag] ?? 0) + 1;
        }
      }
    }

    
    final sortedEntries = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  
  List<BarChartGroupData> _getChartGroups(Map<String, int> data) {
    final top5 = data.entries.take(5).toList();

    return List.generate(top5.length, (index) {
      final entry = top5[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: const Color(0xFF2EB872),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: (data.values.firstOrNull ?? 0).toDouble() + 1, 
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Аналітика симптомів'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _symptomsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2EB872)));
          }

          final data = snapshot.data!;

          if (data.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                const Text('Найпоширеніші звернення', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  height: 250,
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252830),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (data.values.first.toDouble()) + 1,
                      barTouchData: BarTouchData(
                        enabled: false,
                        touchTooltipData: BarTouchTooltipData(
                          
                          getTooltipColor: (_) => Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toInt().toString(),
                              const TextStyle(color: Color(0xFF2EB872), fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < data.length && index < 5) {
                                final label = data.keys.elementAt(index);
                                
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    label.length > 6 ? '${label.substring(0, 5)}..' : label,
                                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _getChartGroups(data),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                
                const Text('Всі симптоми', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: data.entries.map((entry) {
                    final isTop = entry.value == data.values.first; 
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isTop ? const Color(0xFF2EB872).withOpacity(0.2) : const Color(0xFF252830),
                        borderRadius: BorderRadius.circular(12),
                        border: isTop ? Border.all(color: const Color(0xFF2EB872), width: 1) : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              color: isTop ? const Color(0xFF2EB872) : Colors.white70,
                              fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isTop ? const Color(0xFF2EB872) : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: isTop ? Colors.black : Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Недостатньо даних',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Додайте теги до своїх візитів,\nщоб побачити статистику.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          ),
        ],
      ),
    );
  }
}