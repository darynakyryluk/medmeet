import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'visit_model.dart';
import 'user_model.dart';
import 'database_helper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class StatsScreen extends StatefulWidget {
  final User user;
  StatsScreen({required this.user});
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<List<Visit>> _visitsFuture;

  @override
  void initState() {
    super.initState();
    _visitsFuture = DatabaseHelper.instance.getVisits(widget.user.id!);
  }

  List<BarChartGroupData> _getChartData(List<Visit> visits) {
    
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final dt = DateTime(now.year, now.month - (5 - i), 1);
      return DateTime(dt.year, dt.month);
    });

    Map<String, double> monthly = { for (var m in months) DateFormat('yyyy-MM').format(m): 0.0 };

    for (var v in visits) {
      final key = DateFormat('yyyy-MM').format(DateTime(v.date.year, v.date.month));
      if (monthly.containsKey(key)) monthly[key] = monthly[key]! + v.price;
    }

    int idx = 0;
    return monthly.entries.map((e) {
      final val = e.value;
      return BarChartGroupData(x: idx++, barRods: [BarChartRodData(toY: val, width: 18, borderRadius: BorderRadius.circular(6))], showingTooltipIndicators: [0]);
    }).toList();
  }

  Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Color(0xFF053621), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [Text(title, style: TextStyle(color: Colors.white54)), SizedBox(height: 6), Text(value, style: TextStyle(color: Color(0xFF00E676), fontSize: 20, fontWeight: FontWeight.bold))]),
      ),
    );
  }
  Future<void> _generatePdf(List<Visit> visits) async {
    final doc = pw.Document();

    
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    double totalCost = visits.fold(0, (sum, v) => sum + v.price);

    doc.addPage(
        pw.Page(
          
            theme: pw.ThemeData.withFont(
              base: font,
              bold: fontBold,
            ),
            build: (pw.Context ctx) {
              return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                        'Звіт історії візитів: ${widget.user.username}',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                        'Дата формування: ${DateFormat('dd.MM.yyyy').format(DateTime.now())}'
                    ),
                    pw.SizedBox(height: 20),

                    
                    pw.Table.fromTextArray(
                      headers: ['Дата', 'Лікар', 'Спеціалізація', 'Ціна'],
                      data: visits.map((v) => [
                        DateFormat('dd.MM.yyyy').format(v.date),
                        v.doctorName,
                        v.specialty,
                        '${v.price.toStringAsFixed(0)} грн'
                      ]).toList(),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                      cellAlignments: {
                        0: pw.Alignment.centerLeft,
                        1: pw.Alignment.centerLeft,
                        2: pw.Alignment.centerLeft,
                        3: pw.Alignment.centerRight,
                      },
                    ),

                    pw.Divider(),

                    pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                            'Всього: ${totalCost.toStringAsFixed(2)} грн',
                            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)
                        )
                    ),
                  ]
              );
            }
        )
    );

    await Printing.layoutPdf(
        onLayout: (format) async => doc.save()
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Статистика')),
      body: FutureBuilder<List<Visit>>(
        future: _visitsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final visits = snapshot.data!;
          final totalCost = visits.fold(0.0, (sum, item) => sum + item.price);
          final average = visits.isEmpty ? 0 : (totalCost / visits.length);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [ _statCard('Візитів', '${visits.length}'), SizedBox(width: 10), _statCard('Середня ціна', '${average.toStringAsFixed(0)} грн') ]),
              SizedBox(height: 20),
              Text('Загальні витрати', style: TextStyle(color: Colors.white54)),
              SizedBox(height: 6),
              Card(color: Color(0xFF053621), child: Padding(padding: EdgeInsets.all(16), child: Column(children: [ Text('${totalCost.toStringAsFixed(0)} грн', style: TextStyle(color: Color(0xFF00E676), fontSize: 28, fontWeight: FontWeight.bold)) ]))),
              SizedBox(height: 20),
              Text('Динаміка витрат (ост. 6 міс.)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              AspectRatio(aspectRatio: 1.7, child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF053621), borderRadius: BorderRadius.circular(16)), child: BarChart(BarChartData(gridData: FlGridData(show: false), titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                final now = DateTime.now();
                final month = DateTime(now.year, now.month - (5 - idx), 1);
                return Text(DateFormat('MMM').format(month), style: TextStyle(color: Colors.white54, fontSize: 10));
              }))), borderData: FlBorderData(show: false), barGroups: _getChartData(visits))))),
              Spacer(),
              ElevatedButton.icon(onPressed: () => _generatePdf(visits), icon: Icon(Icons.picture_as_pdf), label: Text('ЕКСПОРТУВАТИ ЗВІТ (PDF)'), style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16))),
            ]),
          );
        },
      ),
    );
  }
}
