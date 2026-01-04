import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/finance_note.dart'; // Import FinanceNote model

/// Widget untuk menampilkan chart pengeluaran mingguan
class WeeklyExpenseChart extends StatefulWidget {
  const WeeklyExpenseChart({super.key});

  @override
  State<WeeklyExpenseChart> createState() => _WeeklyExpenseChartState();
}

class _WeeklyExpenseChartState extends State<WeeklyExpenseChart> {
  final _db = DatabaseHelper.instance;
  List<FinanceNote> _transactions = []; // Ganti Expense jadi FinanceNote
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load refresh jika widget di-rebuild karena parent setState
  @override
  void didUpdateWidget(WeeklyExpenseChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  Future<void> _loadData() async {
    // Jangan set loading true agar tidak kerdip berlebihan saat refresh
    final data = await _db.getAllFinanceNotes();
    if (mounted) {
      setState(() {
        _transactions = data.where((item) => item.type == 'expense').toList();
        _loading = false;
      });
    }
  }

  // Hitung total pengeluaran per hari untuk 7 hari terakhir
  Map<int, double> _getWeeklyData() {
    final now = DateTime.now();
    final weekData = <int, double>{};

    // Inisialisasi 7 hari terakhir dengan nilai 0
    for (int i = 6; i >= 0; i--) {
      weekData[i] = 0;
    }

    // Hitung total per hari
    for (var note in _transactions) {
      final daysDiff = now.difference(note.timestamp).inDays;

      if (daysDiff >= 0 && daysDiff < 7) {
        weekData[6 - daysDiff] = (weekData[6 - daysDiff] ?? 0) + note.amount;
      }
    }

    return weekData;
  }

  // Format label hari (Sen, Sel, Rab, dst)
  String _getDayLabel(int index) {
    final now = DateTime.now();
    final date = now.subtract(Duration(days: 6 - index));
    final days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final weekData = _getWeeklyData();
    final maxY = weekData.values.isEmpty
        ? 100000.0
        : weekData.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pengeluaran 7 Hari Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.bar_chart, color: Colors.blue[700]),
              ],
            ),
            const SizedBox(height: 24),

            // Bar Chart
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY > 0 ? maxY * 1.2 : 100000,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blueGrey,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(rod.toY)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _getDayLabel(value.toInt()),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text(
                            '${(value / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 4 : 25000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: weekData.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: entry.value > 0
                              ? Colors.blue[400]
                              : Colors.grey[300],
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
