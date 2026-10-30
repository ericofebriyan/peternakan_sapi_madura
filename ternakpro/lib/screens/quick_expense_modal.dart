import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cattle.dart';
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
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Salep Kuku / Medis', 'icon': null},
    {'name': 'Konsentrat', 'icon': Icons.grass_rounded},
    {'name': 'Vitamin', 'icon': Icons.medication_rounded},
    {'name': 'Insidental', 'icon': Icons.receipt_long_rounded},
  ];

  late String _selectedCategory;
  late String _selectedEartag;
  String _nominalText = '50000';
  String? _activePreset = '50k';
  bool _splitAcrossPen = false;
  final TextEditingController _noteController =
      TextEditingController(text: 'Kaki kiri belakang luka');

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'Salep Kuku / Medis';
    final db = MockDatabase();
    _selectedEartag = db.cattleList.isNotEmpty ? db.cattleList.first.eartagId : '#012';
  }

  void _onKeypadTap(String value) {
    setState(() {
      _activePreset = null;
      if (value == 'DEL') {
        if (_nominalText.isNotEmpty) {
          _nominalText = _nominalText.substring(0, _nominalText.length - 1);
        }
      } else if (value == '000') {
        if (_nominalText.isNotEmpty && _nominalText != '0' && _nominalText.length < 8) {
          _nominalText += '000';
        }
      } else {
        if (_nominalText == '0') {
          _nominalText = value;
        } else if (_nominalText.length < 9) {
          _nominalText += value;
        }
      }
    });
  }

  void _applyPreset(int amount, String label) {
    setState(() {
      _nominalText = amount.toString();
      _activePreset = label;
    });
  }

  void _submitQuickExpense() {
    final amount = double.tryParse(_nominalText) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nominal biaya yang valid'),
          backgroundColor: Color(0xFFEF4444),
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
            const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Biaya Rp ${NumberFormat('#,###', 'id_ID').format(amount)} ($_selectedEartag) tercatat kilat ke HPP! ⚡',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F1824),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCattlePicker() {
    final db = MockDatabase();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1624),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Pilih Target Sapi / Eartag',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: db.cattleList.length,
                  itemBuilder: (context, idx) {
                    final c = db.cattleList[idx];
                    final isSel = c.eartagId == _selectedEartag;
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.eartagId,
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        c.ras,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${c.kandangPen} • Bobot: ${c.beratTerakhir.toStringAsFixed(0)} kg',
                        style: const TextStyle(color: Color(0xFF7A8B9E), fontSize: 12),
                      ),
                      trailing: isSel
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFFF59E0B))
                          : null,
                      onTap: () {
                        setState(() => _selectedEartag = c.eartagId);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = MockDatabase();
    final cattle = db.cattleList.firstWhere(
      (c) => c.eartagId == _selectedEartag,
      orElse: () => db.cattleList.isNotEmpty
          ? db.cattleList.first
          : Cattle(
              eartagId: '#012',
              ras: 'Sapi Madura Asli',
              kelompokUmur: 'Kereman',
              tanggalMasuk: DateTime.now(),
              beratAwal: 210,
              beratTerakhir: 418,
              statusKesehatan: 'Dalam Pemulihan',
              weightHistory: [210, 418],
              kandangPen: 'Kandang Pen A-04',
            ),
    );

    // Formatted nominal
    final int amount = int.tryParse(_nominalText) ?? 0;
    final formattedNumber = NumberFormat('#,###', 'id_ID').format(amount);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF070D16),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF1E2D3D), width: 1.5),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF263547),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Top Header: Icon + Title + Badge + Close Button
            Row(
              children: [
                // Lightning circle icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                  ),
                  child: const Center(
                    child: Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Input Kilat Pengeluaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35)),
                            ),
                            child: const Text(
                              'Offline-Ready',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Pencatatan HPP Otomatis Terkait Eartag',
                        style: TextStyle(
                          color: Color(0xFF7A8B9E),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF142030),
                      border: Border.all(color: const Color(0xFF1E2F44)),
                    ),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF8B9CB2), size: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // SECTION 1: KATEGORI BIAYA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildStepNumber('1'),
                    const SizedBox(width: 8),
                    const Text(
                      'KATEGORI BIAYA',
                      style: TextStyle(
                        color: Color(0xFF8B9CB2),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Wajib dipilih',
                  style: TextStyle(color: Color(0xFF5A6678), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final name = cat['name'] as String;
                  final icon = cat['icon'] as IconData?;
                  final isSelected = _selectedCategory == name;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCategory = name),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF0F1B2A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF1B293C),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check_rounded, size: 14, color: Colors.black),
                              const SizedBox(width: 6),
                            ] else if (icon != null) ...[
                              Icon(icon, size: 14, color: const Color(0xFF8B9CB2)),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              name,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // SECTION 2: TARGET TERNAK / BEBAN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildStepNumber('2'),
                    const SizedBox(width: 8),
                    const Text(
                      'TARGET TERNAK / BEBAN',
                      style: TextStyle(
                        color: Color(0xFF8B9CB2),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _showCattlePicker,
                  child: Row(
                    children: const [
                      Text(
                        'Cari Eartag',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFF59E0B), size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Target Cattle Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1420),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1B283A)),
              ),
              child: Row(
                children: [
                  // Avatar Box
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF451A03).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Icon(Icons.pets_rounded, color: Color(0xFFF59E0B), size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                cattle.eartagId,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cattle.ras,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${cattle.kandangPen} • Bobot: ${cattle.beratTerakhir.toStringAsFixed(0)} kg',
                              style: const TextStyle(
                                color: Color(0xFF7A8B9E),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Ganti button
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF22344A)),
                      backgroundColor: const Color(0xFF0F1824),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _showCattlePicker,
                    child: const Text(
                      'Ganti',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Checkbox Bagi rata biaya
            InkWell(
              onTap: () => setState(() => _splitAcrossPen = !_splitAcrossPen),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _splitAcrossPen,
                      activeColor: const Color(0xFFF59E0B),
                      checkColor: Colors.black,
                      side: const BorderSide(color: Color(0xFF2E3F54)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) => setState(() => _splitAcrossPen = val ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Bagi rata biaya ke Seluruh Kandang A (48 Ekor)',
                    style: TextStyle(
                      color: Color(0xFF8B9CB2),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // SECTION 3: NOMINAL BIAYA
            Row(
              children: [
                _buildStepNumber('3'),
                const SizedBox(width: 8),
                const Text(
                  'NOMINAL BIAYA',
                  style: TextStyle(
                    color: Color(0xFF8B9CB2),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nominal Display Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF070D16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.85),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'Rp ',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        _nominalText.isEmpty ? '0' : formattedNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 20,
                        margin: const EdgeInsets.only(left: 3),
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => setState(() {
                      _nominalText = '';
                      _activePreset = null;
                    }),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142030),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF1F2F44)),
                      ),
                      child: const Text(
                        'RESET',
                        style: TextStyle(
                          color: Color(0xFF7A8B9E),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Quick Preset Row (+10k, +25k, +50k, +100k)
            Row(
              children: [
                _buildPresetButton(10000, '+10k'),
                const SizedBox(width: 8),
                _buildPresetButton(25000, '+25k'),
                const SizedBox(width: 8),
                _buildPresetButton(50000, '+50k'),
                const SizedBox(width: 8),
                _buildPresetButton(100000, '+100k'),
              ],
            ),
            const SizedBox(height: 10),

            // Keypad Grid 3x4
            Column(
              children: [
                Row(
                  children: [
                    _buildKeypadButton('1'),
                    const SizedBox(width: 6),
                    _buildKeypadButton('2'),
                    const SizedBox(width: 6),
                    _buildKeypadButton('3'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildKeypadButton('4'),
                    const SizedBox(width: 6),
                    _buildKeypadButton('5'),
                    const SizedBox(width: 6),
                    _buildKeypadButton('6'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildKeypadButton('7'),
                    const SizedBox(width: 6),
                    _buildKeypadButton('8'),
                    const SizedBox(width: 6),
                    _buildKeypadButton('9'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildKeypadButton('000'),
                    const SizedBox(width: 6),
                    _buildKeypadButton('0'),
                    const SizedBox(width: 6),
                    _buildKeypadButton('DEL'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Catatan Singkat + Camera Button
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1420),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1B283A)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _noteController,
                      style: const TextStyle(color: Colors.white, fontSize: 12.5),
                      decoration: const InputDecoration(
                        hintText: 'Catatan singkat (contoh: Kaki kiri belakang luka)',
                        hintStyle: TextStyle(color: Color(0xFF5A6678), fontSize: 12),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1420),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1B283A)),
                  ),
                  child: const Center(
                    child: Icon(Icons.camera_alt_outlined, color: Color(0xFFF59E0B), size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // SUBMIT BUTTON: ⚡ Simpan Kilat ke HPP Sapi
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitQuickExpense,
                icon: const Icon(Icons.flash_on_rounded, color: Colors.black, size: 20),
                label: const Text(
                  'Simpan Kilat ke HPP Sapi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Footer info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.circle, color: Color(0xFF10B981), size: 6),
                SizedBox(width: 5),
                Text(
                  'Tersimpan lokal di HP • Auto-sync saat ada sinyal internet',
                  style: TextStyle(
                    color: Color(0xFF7A8B9E),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNumber(String number) {
    return Container(
      width: 17,
      height: 17,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF59E0B),
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(int amount, String label) {
    final isSelected = _activePreset == label.replaceAll('+', '');
    return Expanded(
      child: InkWell(
        onTap: () => _applyPreset(amount, label.replaceAll('+', '')),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF59E0B).withOpacity(0.18)
                : const Color(0xFF0C1420),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF1B283A),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF8B9CB2),
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String key) {
    final isDel = key == 'DEL';
    return Expanded(
      child: InkWell(
        onTap: () => _onKeypadTap(key),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isDel ? const Color(0xFF38121A) : const Color(0xFF0C1420),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDel
                  ? const Color(0xFF7F1D1D).withOpacity(0.5)
                  : const Color(0xFF1B283A),
            ),
          ),
          alignment: Alignment.center,
          child: isDel
              ? const Icon(Icons.backspace_outlined, size: 17, color: Color(0xFFF87171))
              : Text(
                  key,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
