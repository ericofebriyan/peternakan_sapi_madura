import 'package:flutter/material.dart';
import '../models/cattle.dart';
import '../data/mock_data.dart';

class AddMedicalRecordModal extends StatefulWidget {
  final String? initialEartag;

  const AddMedicalRecordModal({super.key, this.initialEartag});

  static Future<void> show(BuildContext context, {String? initialEartag}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddMedicalRecordModal(initialEartag: initialEartag),
    );
  }

  @override
  State<AddMedicalRecordModal> createState() => _AddMedicalRecordModalState();
}

class _AddMedicalRecordModalState extends State<AddMedicalRecordModal> {
  late String _selectedEartag;
  MedicalHandlingType _selectedType = MedicalHandlingType.resepMantri;

  final TextEditingController _symptomController = TextEditingController(
    text: 'Nafsu makan berkurang, lesu, pembengkakan kuku',
  );
  final TextEditingController _actionController = TextEditingController(
    text: 'Pembersihan kuku dengan antiseptik povidone, pemberian suntikan antipiretik dan vitamin pendukung stamina',
  );
  final TextEditingController _medicineController = TextEditingController(
    text: 'Biosan TP 10ml, Oxytetracycline 20ml, Salep Iodin',
  );

  final List<String> _quickSymptoms = [
    'Nafsu makan turun',
    'Kembung / Bloat',
    'Kuku retak / bengkak',
    'Diare / Feses Cair',
  ];
  final Set<String> _selectedSymptoms = {'Kuku retak / bengkak'};

  @override
  void initState() {
    super.initState();
    final db = MockDatabase();
    _selectedEartag = widget.initialEartag ??
        (db.cattleList.isNotEmpty ? db.cattleList.first.eartagId : '#012');
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
        if (_symptomController.text.isNotEmpty &&
            !_symptomController.text.contains(symptom)) {
          _symptomController.text += ', $symptom';
        } else if (_symptomController.text.isEmpty) {
          _symptomController.text = symptom;
        }
      }
    });
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
                  'Pilih Target Sapi Pasien',
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
                          color: const Color(0xFF06B6D4).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.eartagId,
                          style: const TextStyle(
                            color: Color(0xFF22D3EE),
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
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
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

  void _submitMedicalRecord() {
    if (_symptomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gejala & keluhan klinis wajib diisi!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final db = MockDatabase();
    final isMantri = _selectedType == MedicalHandlingType.resepMantri;

    db.addMedicalRecord(
      MedicalRecord(
        id: 'med_${DateTime.now().millisecondsSinceEpoch}',
        eartagId: _selectedEartag,
        tanggal: DateTime.now(),
        diagnosis: _symptomController.text.trim(),
        tindakan: _actionController.text.trim().isNotEmpty
            ? _actionController.text.trim()
            : 'Penanganan klinis rutin',
        obat: _medicineController.text.trim().isNotEmpty
            ? _medicineController.text.trim()
            : (isMantri ? 'Injeksi Medis' : 'Herbal Tradisional'),
        petugas: isMantri ? 'Mantri Agus Setiawan' : 'Pekerja Kandang (Mandiri)',
        jenisPenanganan: _selectedType,
        lokasiKandang: 'Kandang Pen A-04',
        statusTindakLanjut: isMantri ? 'Kontrol Ulang Terjadwal' : 'Membaik / Selesai',
        catatanKhusus: isMantri
            ? 'Nomor Resep: RM/2026/04/${_selectedEartag.replaceAll('#', '')}-A'
            : 'Evaluasi: Pantau perkembangan nafsu makan dalam 24 jam.',
        jenisCatatanKhusus: isMantri ? 'resep' : 'evaluasi',
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Rekam medis untuk $_selectedEartag berhasil disimpan! 🩺',
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
              beratTerakhir: 340,
              statusKesehatan: 'Dalam Pemulihan',
              weightHistory: [210, 340],
              kandangPen: 'Kandang Pen A-04',
            ),
    );

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

            // Top Header: Title + Auto-Sync + Subtitle + Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Catat Penanganan Medis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Auto-Sync',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TernakPro Health Records • ${cattle.eartagId}',
                      style: const TextStyle(
                        color: Color(0xFF7A8B9E),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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

            // Cattle Target Card
            InkWell(
              onTap: _showCattlePicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1420),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1A283A)),
                ),
                child: Row(
                  children: [
                    // Avatar Box
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF451A03).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Icon(Icons.density_medium_rounded, color: Color(0xFFF59E0B), size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Cattle Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                cattle.eartagId,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
                                ),
                                child: Text(
                                  cattle.ras,
                                  style: const TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.home_work_outlined, size: 13, color: Color(0xFF7A8B9E)),
                              const SizedBox(width: 4),
                              Text(
                                cattle.kandangPen,
                                style: const TextStyle(
                                  color: Color(0xFF7A8B9E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• Jantan (${cattle.beratTerakhir.toStringAsFixed(0)} kg)',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.unfold_more_rounded, color: Color(0xFF7A8B9E), size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // SECTION: JENIS PENANGANAN
            const Text(
              'JENIS PENANGANAN',
              style: TextStyle(
                color: Color(0xFF8B9CB2),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // 2 Handling Cards Side by Side
            Row(
              children: [
                // Card 1: Resep Mantri / drh.
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = MedicalHandlingType.resepMantri),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedType == MedicalHandlingType.resepMantri
                            ? const Color(0xFF0C1929)
                            : const Color(0xFF0C1420),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == MedicalHandlingType.resepMantri
                              ? const Color(0xFF06B6D4)
                              : const Color(0xFF1A283A),
                          width: _selectedType == MedicalHandlingType.resepMantri ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF06B6D4).withOpacity(0.18),
                                ),
                                child: const Center(
                                  child: Icon(Icons.health_and_safety_rounded, color: Color(0xFF06B6D4), size: 16),
                                ),
                              ),
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedType == MedicalHandlingType.resepMantri
                                      ? const Color(0xFF06B6D4)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedType == MedicalHandlingType.resepMantri
                                        ? const Color(0xFF06B6D4)
                                        : const Color(0xFF2E3F54),
                                    width: 1.5,
                                  ),
                                ),
                                child: _selectedType == MedicalHandlingType.resepMantri
                                    ? const Center(
                                        child: Icon(Icons.circle, size: 6, color: Colors.black),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Resep Mantri / drh.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Prosedur Medis Klinis',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Card 2: Terapi Tradisional
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = MedicalHandlingType.mandiri),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedType == MedicalHandlingType.mandiri
                            ? const Color(0xFF062217)
                            : const Color(0xFF0C1420),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == MedicalHandlingType.mandiri
                              ? const Color(0xFF10B981)
                              : const Color(0xFF1A283A),
                          width: _selectedType == MedicalHandlingType.mandiri ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF10B981).withOpacity(0.18),
                                ),
                                child: const Center(
                                  child: Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 16),
                                ),
                              ),
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedType == MedicalHandlingType.mandiri
                                      ? const Color(0xFF10B981)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedType == MedicalHandlingType.mandiri
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF2E3F54),
                                    width: 1.5,
                                  ),
                                ),
                                child: _selectedType == MedicalHandlingType.mandiri
                                    ? const Center(
                                        child: Icon(Icons.circle, size: 6, color: Colors.black),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Terapi Tradisional',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Jamu / Mandiri Kandang',
                            style: TextStyle(
                              color: Color(0xFF7A8B9E),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // SECTION: GEJALA & KELUHAN KLINIS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'GEJALA & KELUHAN KLINIS',
                  style: TextStyle(
                    color: Color(0xFF8B9CB2),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '*WAJIB DIISI',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Symptoms text field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C1420),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1B283A)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _symptomController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Quick Symptom Tag Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickSymptoms.map((sym) {
                  final isSelected = _selectedSymptoms.contains(sym);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => _toggleSymptom(sym),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF06B6D4).withOpacity(0.12)
                              : const Color(0xFF0C1420),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF1B283A),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check_rounded : Icons.add_rounded,
                              size: 13,
                              color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF8B9CB2),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sym,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF8B9CB2),
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

            // SECTION: TINDAKAN DILAKUKAN
            const Text(
              'TINDAKAN DILAKUKAN',
              style: TextStyle(
                color: Color(0xFF8B9CB2),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Action multiline text field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C1420),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1B283A)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: TextField(
                controller: _actionController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 12.5),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // SECTION: OBAT / TERAPI DIBERIKAN
            const Text(
              'OBAT / TERAPI DIBERIKAN',
              style: TextStyle(
                color: Color(0xFF8B9CB2),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Medicine text field with flask icon
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C1420),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1B283A)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.science_outlined, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _medicineController,
                      style: const TextStyle(color: Colors.white, fontSize: 12.5),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // SUBMIT BUTTON: ✓ Simpan Rekam Medis
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitMedicalRecord,
                icon: const Icon(Icons.check_rounded, color: Colors.black, size: 20),
                label: const Text(
                  'Simpan Rekam Medis',
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
                  'Tersimpan di memori perangkat lokal dan siap disinkronkan',
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
}

