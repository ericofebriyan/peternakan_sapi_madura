import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../models/cattle.dart';
import '../data/mock_data.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keuangan & HPP Kandang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight, size: 26),
            onPressed: () => _showAddTransactionDialog(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: db,
        builder: (context, _) {
          final breakdown = db.categoryBreakdown;
          final totalExpense = db.totalFarmExpense;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Overview Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceCardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Investasi & Operasional',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currencyFormatter.format(totalExpense),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.surfaceCardBorder),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem(
                            'Rata-rata HPP/Ekor',
                            currencyFormatter.format(db.averageHpp),
                            AppColors.primaryLight,
                          ),
                          _buildSummaryItem(
                            'Total Transaksi',
                            '${db.transactions.length} Item',
                            AppColors.secondary,
                          ),
                          _buildSummaryItem(
                            'Populasi',
                            '${db.totalCattle} Ekor',
                            AppColors.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Unit Costing & Proyeksi Laba Bersih Card (Fase 4 Development Plan)
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF064E3B), Color(0xFF0F2F24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.trending_up_rounded, color: AppColors.primaryLight, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Valuasi Pasar & Laba Bersih',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Benchmark: Rp 52rb/kg',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Valuasi Pasar Aset',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormatter.format(db.totalFarmMarketValue),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 36, width: 1, color: Colors.white.withOpacity(0.2)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Proyeksi Laba Bersih',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currencyFormatter.format(db.totalFarmNetProfit),
                                  style: const TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rata-rata Margin Laba: +${db.averageProfitMargin.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Model: Unit Costing',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Donut Chart: Komposisi HPP
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceCardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Komposisi Pengeluaran (HPP)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: Row(
                          children: [
                            // Donut Pie Chart
                            Expanded(
                              flex: 5,
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection == null) {
                                          _touchedIndex = -1;
                                          return;
                                        }
                                        _touchedIndex = pieTouchResponse
                                            .touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 42,
                                  sections: _buildPieSections(breakdown, totalExpense),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Legend
                            Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLegendItem('Bakalan', AppColors.primary, breakdown[ExpenseCategory.pembelianBakalan] ?? 0, totalExpense),
                                  const SizedBox(height: 6),
                                  _buildLegendItem('Pakan', AppColors.secondary, breakdown[ExpenseCategory.konsentratPakan] ?? 0, totalExpense),
                                  const SizedBox(height: 6),
                                  _buildLegendItem('Medis', AppColors.accent, breakdown[ExpenseCategory.vitaminMedis] ?? 0, totalExpense),
                                  const SizedBox(height: 6),
                                  _buildLegendItem('Insidental', AppColors.purple, breakdown[ExpenseCategory.insidental] ?? 0, totalExpense),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Transactions List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Riwayat Transaksi Pengeluaran',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Geser untuk hapus',
                      style: TextStyle(
                        color: AppColors.textMuted.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...db.transactions.map((tx) {
                  return Dismissible(
                    key: Key(tx.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      db.deleteTransaction(tx.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Transaksi ${tx.catatan} dihapus'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceCardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(tx.kategori).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(tx.kategori),
                              color: _getCategoryColor(tx.kategori),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      tx.eartagId,
                                      style: const TextStyle(
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${tx.kategori.displayName}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${tx.catatan} • ${dateFormatter.format(tx.tanggal)}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormatter.format(tx.nominal),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double amount, double total) {
    final pct = total > 0 ? (amount / total * 100).toStringAsFixed(1) : '0';
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$pct%',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<ExpenseCategory, double> breakdown, double total) {
    if (total == 0) return [];
    final categories = [
      ExpenseCategory.pembelianBakalan,
      ExpenseCategory.konsentratPakan,
      ExpenseCategory.vitaminMedis,
      ExpenseCategory.insidental,
    ];

    return List.generate(categories.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 14.0 : 10.0;
      final radius = isTouched ? 38.0 : 32.0;

      final cat = categories[i];
      final val = breakdown[cat] ?? 0;
      final pct = (val / total * 100);

      return PieChartSectionData(
        color: _getCategoryColor(cat),
        value: val,
        title: '${pct.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Color _getCategoryColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.pembelianBakalan:
        return AppColors.primary;
      case ExpenseCategory.konsentratPakan:
        return AppColors.secondary;
      case ExpenseCategory.vitaminMedis:
        return AppColors.accent;
      case ExpenseCategory.insidental:
        return AppColors.purple;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.pembelianBakalan:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.konsentratPakan:
        return Icons.grass_rounded;
      case ExpenseCategory.vitaminMedis:
        return Icons.medical_services_rounded;
      case ExpenseCategory.insidental:
        return Icons.build_rounded;
    }
  }

  void _showAddTransactionDialog(BuildContext context) {
    final db = MockDatabase();
    String selectedEartag = db.cattleList.first.eartagId;
    ExpenseCategory selectedCategory = ExpenseCategory.konsentratPakan;
    final nominalCtrl = TextEditingController(text: '350000');
    final notesCtrl = TextEditingController(text: 'Pakan konsentrat tambahan');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catat Transaksi Pengeluaran',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dropdown Eartag
                  DropdownButtonFormField<String>(
                    initialValue: selectedEartag,
                    dropdownColor: AppColors.surfaceCard,
                    decoration: const InputDecoration(labelText: 'Pilih Eartag Ternak'),
                    items: db.cattleList.map((c) {
                      return DropdownMenuItem(
                        value: c.eartagId,
                        child: Text('${c.eartagId} (${c.ras})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedEartag = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Category Dropdown
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: selectedCategory,
                    dropdownColor: AppColors.surfaceCard,
                    decoration: const InputDecoration(labelText: 'Kategori Biaya'),
                    items: ExpenseCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nominalCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Nominal Biaya (Rp)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Catatan Pengeluaran'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final nominal = double.tryParse(nominalCtrl.text) ?? 0;
                        if (nominal > 0) {
                          db.addTransaction(
                            FinancialTransaction(
                              id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                              eartagId: selectedEartag,
                              kategori: selectedCategory,
                              nominal: nominal,
                              tanggal: DateTime.now(),
                              catatan: notesCtrl.text,
                            ),
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Transaksi untuk $selectedEartag berhasil dicatat!'),
                              backgroundColor: AppColors.primaryDark,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Simpan Transaksi',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
