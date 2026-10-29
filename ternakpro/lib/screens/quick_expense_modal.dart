import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../data/mock_data.dart';

class QuickExpenseModal extends StatefulWidget {
  const QuickExpenseModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QuickExpenseModal(),
    );
  }

  @override
  State<QuickExpenseModal> createState() => _QuickExpenseModalState();
}

class _QuickExpenseModalState extends State<QuickExpenseModal> {
  final List<String> _quickCategories = [
    'Salep Kuku',
    'Pakan Tambahan',
    'Obat / Vitamin',
    'Lainnya',
  ];

  late String _selectedCategory;
  late String _selectedEartag;
  String _nominalText = '50000';
  final TextEditingController _noteController = TextEditingController(text: 'Pengeluaran insidental kandang');

  @override
  void initState() {
    super.initState();
    _selectedCategory = _quickCategories.first;
    final db = MockDatabase();
    _selectedEartag = db.cattleList.isNotEmpty ? db.cattleList.first.eartagId : '#012';
  }

  void _onKeypadTap(String value) {
    setState(() {
      if (value == 'DEL') {
        if (_nominalText.isNotEmpty) {
          _nominalText = _nominalText.substring(0, _nominalText.length - 1);
        }
      } else if (value == 'CLR') {
        _nominalText = '';
      } else {
        if (_nominalText == '0') {
          _nominalText = value;
        } else if (_nominalText.length < 9) {
          _nominalText += value;
        }
      }
    });
  }

  void _submitQuickExpense() {
    final amount = double.tryParse(_nominalText) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal biaya yang valid'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final db = MockDatabase();
    db.addQuickExpense(
      eartagId: _selectedEartag,
      categoryName: _selectedCategory,
      amount: amount,
      note: _noteController.text.isNotEmpty ? _noteController.text : _selectedCategory,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.flash_on_rounded, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text('Biaya Rp ${NumberFormat('#,###', 'id_ID').format(amount)} ($_selectedEartag) tercatat kilat! ⚡'),
          ],
        ),
        backgroundColor: AppColors.surfaceCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();
    final double amount = double.tryParse(_nominalText) ?? 0;
    final formattedNominal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceCardBorder, width: 1.5),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Drag Handle & Title
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.flash_on_rounded, color: AppColors.accent, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Input Kilat Pengeluaran',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Langkah 1: Chip Kategori
          const Text(
            '1. Pilih Kategori Biaya:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickCategories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: isSelected ? AppColors.accent : AppColors.surfaceCardBorder,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Langkah 2: Pilih Eartag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. Target Eartag:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceCardBorder),
                ),
                child: DropdownButton<String>(
                  value: _selectedEartag,
                  dropdownColor: AppColors.surfaceCard,
                  underline: const SizedBox(),
                  isDense: true,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  items: db.cattleList.map((c) {
                    return DropdownMenuItem(
                      value: c.eartagId,
                      child: Text('${c.eartagId} (${c.ras})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedEartag = val);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Langkah 3: Nominal Display & Quick Keypad
          const Text(
            '3. Nominal Biaya:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withOpacity(0.4)),
            ),
            alignment: Alignment.centerRight,
            child: Text(
              formattedNominal,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Quick Preset Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['25000', '50000', '100000', '250000'].map((val) {
              return InkWell(
                onTap: () => setState(() => _nominalText = val),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.surfaceCardBorder),
                  ),
                  child: Text(
                    '+${int.parse(val) ~/ 1000}k',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Numeric Keypad Grid (Plan 2.6: Keypad Nominal)
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.6,
            children: [
              '1', '2', '3', '4', '5', '6',
              '7', '8', '9', '0', '000', 'DEL'
            ].map((k) {
              final isDel = k == 'DEL';
              return InkWell(
                onTap: () {
                  if (k == '000') {
                    if (_nominalText.isNotEmpty && _nominalText != '0') {
                      setState(() => _nominalText += '000');
                    }
                  } else {
                    _onKeypadTap(k);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDel ? AppColors.danger.withOpacity(0.15) : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDel ? AppColors.danger.withOpacity(0.3) : AppColors.surfaceCardBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isDel
                      ? const Icon(Icons.backspace_outlined, size: 16, color: AppColors.danger)
                      : Text(
                          k,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Langkah 4: Tombol Simpan Kilat
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.flash_on_rounded, color: Colors.black, size: 22),
              label: const Text(
                'Simpan Kilat ⚡',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              onPressed: _submitQuickExpense,
            ),
          ),
        ],
      ),
    );
  }
}
