import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';

/// Widget untuk menampilkan ringkasan pengeluaran bulan ini
class ExpenseSummaryCards extends StatefulWidget {
  const ExpenseSummaryCards({super.key});

  @override
  State<ExpenseSummaryCards> createState() => _ExpenseSummaryCardsState();
}

class _ExpenseSummaryCardsState extends State<ExpenseSummaryCards> {
  final _db = DatabaseHelper.instance;
  double _monthlyTotal = 0;
  String _topCategory = '-';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);

    final expenses = await _db.getAllExpenses();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Filter pengeluaran bulan ini
    final monthlyExpenses = expenses.where((e) {
      final date = DateTime.parse(e.date);
      return date.year == now.year && date.month == now.month;
    }).toList();

    // Hitung total
    double total = 0;
    final categoryTotals = <String, double>{};

    for (var expense in monthlyExpenses) {
      total += expense.amount;
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    // Cari kategori dengan pengeluaran terbanyak
    String topCat = '-';
    double maxAmount = 0;
    categoryTotals.forEach((category, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        topCat = category;
      }
    });

    setState(() {
      _monthlyTotal = total;
      _topCategory = topCat;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Row(
      children: [
        // Card 1: Total Pengeluaran Bulan Ini
        Expanded(
          child: Card(
            elevation: 2,
            color: Colors.red[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Bulan Ini',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(_monthlyTotal)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Pengeluaran',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Card 2: Kategori Terbanyak
        Expanded(
          child: Card(
            elevation: 2,
            color: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Terbanyak',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _topCategory,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kategori Utama',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
