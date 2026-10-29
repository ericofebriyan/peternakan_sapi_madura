import 'package:flutter/material.dart';
import '../models/cattle.dart';

class MockDatabase extends ChangeNotifier {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  final String userName = 'H. Syamsul Arifin';
  final String farmLocation = 'Kandang Madura Sentosa';

  final List<Cattle> _cattleList = [
    Cattle(
      eartagId: '#012',
      ras: 'Sapi Madura Asli',
      kelompokUmur: 'Kereman',
      tanggalMasuk: DateTime(2026, 1, 15),
      beratAwal: 210,
      beratTerakhir: 245.0,
      statusKesehatan: 'Dalam Pemulihan',
      weightHistory: [210, 218, 225, 230, 235, 240, 245],
      kandangPen: 'Kandang Pen A-04',
      umurDeskripsi: 'Dewasa (2.4 Thn)',
      pakan: 'Konsentrat + TMR',
      manualDaysInFeedlot: 286,
      adgCustom: 0.48,
      customActionButtonText: 'Catatan Medis',
    ),
    Cattle(
      eartagId: '#007',
      ras: 'Peranakan Ongole (PO)',
      kelompokUmur: 'Fase Pertumbuhan',
      tanggalMasuk: DateTime(2026, 3, 8),
      beratAwal: 155,
      beratTerakhir: 178.0,
      statusKesehatan: 'Stunted',
      weightHistory: [155, 158, 162, 165, 170, 174, 178],
      kandangPen: 'Kandang Pen B-01',
      umurDeskripsi: 'Muda (1.2 Thn)',
      pakan: 'Silase Formula B (Defisit)',
      manualDaysInFeedlot: 234,
      adgCustom: 0.21,
      adgStatus: '(Kritis)',
      customActionButtonText: 'Cek Nutrisi',
    ),
    Cattle(
      eartagId: '#019',
      ras: 'Silangan Limosin',
      kelompokUmur: 'Kereman / Dewasa',
      tanggalMasuk: DateTime(2026, 2, 20),
      beratAwal: 270,
      beratTerakhir: 312.0,
      statusKesehatan: 'Dalam Pemulihan',
      weightHistory: [270, 278, 285, 290, 298, 305, 312],
      kandangPen: 'Kandang Pen A-02',
      manualDaysInFeedlot: 250,
      customActionButtonText: 'Catatan Medis',
    ),
    Cattle(
      eartagId: '#021',
      ras: 'Silangan Simental',
      kelompokUmur: 'Kereman',
      tanggalMasuk: DateTime(2026, 1, 30),
      beratAwal: 285,
      beratTerakhir: 334.0,
      statusKesehatan: 'Sehat Optimal',
      weightHistory: [285, 294, 302, 310, 318, 326, 334],
      kandangPen: 'Kandang Pen A-01',
      umurDeskripsi: 'Dewasa (2.8 Thn)',
      pakan: 'Konsentrat Pro+ (9.5 kg/h)',
      manualDaysInFeedlot: 271,
      adgCustom: 0.82,
      customActionButtonText: 'Timbang Ulang',
    ),
    Cattle(
      eartagId: '#003',
      ras: 'Sapi Madura Asli',
      kelompokUmur: 'Pedet',
      tanggalMasuk: DateTime(2026, 4, 12),
      beratAwal: 90,
      beratTerakhir: 112.0,
      statusKesehatan: 'Sehat',
      weightHistory: [90, 95, 98, 102, 105, 109, 112],
      kandangPen: 'Kandang Pen Pedet-01',
      manualDaysInFeedlot: 199,
      customActionButtonText: 'Timbang Ulang',
    ),
    Cattle(
      eartagId: '#008',
      ras: 'Silangan Limosin',
      kelompokUmur: 'Muda',
      tanggalMasuk: DateTime(2026, 2, 5),
      beratAwal: 200,
      beratTerakhir: 238,
      statusKesehatan: 'Sehat',
      weightHistory: [200, 208, 215, 220, 226, 232, 238],
    ),
    Cattle(
      eartagId: '#015',
      ras: 'Silangan Simental',
      kelompokUmur: 'Kereman / Dewasa',
      tanggalMasuk: DateTime(2025, 11, 20),
      beratAwal: 300,
      beratTerakhir: 367,
      statusKesehatan: 'Sehat',
      weightHistory: [300, 312, 322, 335, 345, 356, 367],
    ),
    Cattle(
      eartagId: '#023',
      ras: 'Peranakan Ongole (PO)',
      kelompokUmur: 'Muda',
      tanggalMasuk: DateTime(2026, 3, 25),
      beratAwal: 175,
      beratTerakhir: 199,
      statusKesehatan: 'Sehat',
      weightHistory: [175, 179, 183, 188, 192, 196, 199],
    ),
    Cattle(
      eartagId: '#004',
      ras: 'Sapi Madura Asli',
      kelompokUmur: 'Muda',
      tanggalMasuk: DateTime(2026, 4, 1),
      beratAwal: 140,
      beratTerakhir: 168,
      statusKesehatan: 'Sehat',
      weightHistory: [140, 146, 151, 155, 160, 164, 168],
    ),
    Cattle(
      eartagId: '#011',
      ras: 'Silangan Limosin',
      kelompokUmur: 'Kereman / Dewasa',
      tanggalMasuk: DateTime(2025, 12, 10),
      beratAwal: 260,
      beratTerakhir: 305,
      statusKesehatan: 'Sehat',
      weightHistory: [260, 270, 278, 285, 292, 298, 305],
    ),
    Cattle(
      eartagId: '#017',
      ras: 'Sapi Madura Asli',
      kelompokUmur: 'Pedet',
      tanggalMasuk: DateTime(2026, 5, 1),
      beratAwal: 75,
      beratTerakhir: 88,
      statusKesehatan: 'Pertumbuhan Lambat / Stunted',
      weightHistory: [75, 77, 79, 81, 83, 85, 88],
    ),
    Cattle(
      eartagId: '#025',
      ras: 'Silangan Simental',
      kelompokUmur: 'Kereman / Dewasa',
      tanggalMasuk: DateTime(2026, 1, 10),
      beratAwal: 290,
      beratTerakhir: 348,
      statusKesehatan: 'Sehat',
      weightHistory: [290, 300, 310, 320, 330, 340, 348],
    ),
  ];

  final List<FinancialTransaction> _transactions = [
    FinancialTransaction(
      id: 'tx001',
      eartagId: '#012',
      kategori: ExpenseCategory.pembelianBakalan,
      nominal: 7500000,
      tanggal: DateTime(2026, 1, 15),
      catatan: 'Pembelian dari pasar Sampang',
    ),
    FinancialTransaction(
      id: 'tx002',
      eartagId: '#012',
      kategori: ExpenseCategory.konsentratPakan,
      nominal: 350000,
      tanggal: DateTime(2026, 1, 20),
      catatan: 'Dedak + konsentrat pabrikan',
    ),
    FinancialTransaction(
      id: 'tx003',
      eartagId: '#012',
      kategori: ExpenseCategory.vitaminMedis,
      nominal: 125000,
      tanggal: DateTime(2026, 2, 10),
      catatan: 'Vitamin B-kompleks injeksi',
    ),
    FinancialTransaction(
      id: 'tx004',
      eartagId: '#012',
      kategori: ExpenseCategory.konsentratPakan,
      nominal: 350000,
      tanggal: DateTime(2026, 2, 20),
      catatan: 'Pakan rutin bulanan',
    ),
    FinancialTransaction(
      id: 'tx005',
      eartagId: '#012',
      kategori: ExpenseCategory.insidental,
      nominal: 45000,
      tanggal: DateTime(2026, 3, 5),
      catatan: 'Salep kuku retak',
    ),
    FinancialTransaction(
      id: 'tx006',
      eartagId: '#012',
      kategori: ExpenseCategory.konsentratPakan,
      nominal: 350000,
      tanggal: DateTime(2026, 3, 20),
      catatan: 'Pakan rutin bulanan',
    ),
    FinancialTransaction(
      id: 'tx007',
      eartagId: '#012',
      kategori: ExpenseCategory.vitaminMedis,
      nominal: 200000,
      tanggal: DateTime(2026, 4, 2),
      catatan: 'Obat cacing Ivomec',
    ),
    FinancialTransaction(
      id: 'tx008',
      eartagId: '#007',
      kategori: ExpenseCategory.pembelianBakalan,
      nominal: 5500000,
      tanggal: DateTime(2026, 3, 8),
      catatan: 'Pasar Pamekasan',
    ),
    FinancialTransaction(
      id: 'tx009',
      eartagId: '#007',
      kategori: ExpenseCategory.konsentratPakan,
      nominal: 280000,
      tanggal: DateTime(2026, 3, 15),
      catatan: 'Konsentrat standar',
    ),
    FinancialTransaction(
      id: 'tx010',
      eartagId: '#007',
      kategori: ExpenseCategory.vitaminMedis,
      nominal: 350000,
      tanggal: DateTime(2026, 3, 22),
      catatan: 'Konsultasi mantri + obat diare',
    ),
    FinancialTransaction(
      id: 'tx013',
      eartagId: '#019',
      kategori: ExpenseCategory.pembelianBakalan,
      nominal: 11000000,
      tanggal: DateTime(2026, 2, 20),
      catatan: 'Bakalan limosin grading A',
    ),
    FinancialTransaction(
      id: 'tx017',
      eartagId: '#021',
      kategori: ExpenseCategory.pembelianBakalan,
      nominal: 12500000,
      tanggal: DateTime(2026, 1, 30),
      catatan: 'Simental impor F1',
    ),
  ];

  final List<MedicalRecord> _medicalRecords = [
    MedicalRecord(
      id: 'med005',
      eartagId: '#007',
      tanggal: DateTime(2026, 4, 15),
      diagnosis: 'Pemberian Jamu Empon-empon Nafsu Makan',
      tindakan: 'Pemberian ramuan temu lawak + kunyit + telur',
      obat: 'Herbal Alami (Tradisional)',
      petugas: 'Pekerja Kandang (Mandiri)',
      jenisPenanganan: MedicalHandlingType.mandiri,
      lokasiKandang: 'Kandang B - Limousin',
      statusTindakLanjut: 'Membaik / Selesai',
      catatanKhusus: 'Evaluasi: Nafsu makan kembali tinggi, pakan rumput habis.',
      jenisCatatanKhusus: 'evaluasi',
    ),
    MedicalRecord(
      id: 'med004',
      eartagId: '#019',
      tanggal: DateTime(2026, 4, 10),
      diagnosis: 'Salep Kuku Retak & Pembersihan Rutin',
      tindakan: 'Pembersihan kuku dengan antiseptik dan salep',
      obat: 'Salep Iodin & Minyak Ikan',
      petugas: 'H. Syamsul Arifin (Mandiri)',
      jenisPenanganan: MedicalHandlingType.mandiri,
      lokasiKandang: 'Kandang A - Simental',
      statusTindakLanjut: 'Kontrol 3 Hari',
      catatanKhusus: 'Perhatian: Pastikan lantai kandang tetap kering agar salep tidak terbilas kotoran.',
      jenisCatatanKhusus: 'perhatian',
    ),
    MedicalRecord(
      id: 'med001',
      eartagId: '#012',
      tanggal: DateTime(2026, 4, 2),
      diagnosis: 'Indikasi Cacingan & Penurunan Nafsu Makan',
      tindakan: 'Injeksi Ivomec 5ml & B-Kompleks',
      obat: 'Ivomec, Biosan TP',
      petugas: 'Mantri Agus Setiawan',
      jenisPenanganan: MedicalHandlingType.resepMantri,
      lokasiKandang: 'Kandang C - Brahman',
      statusTindakLanjut: 'Kontrol Ulang Terjadwal',
      catatanKhusus: 'Nomor Resep: RM/2026/04/012-A • Rekomendasi booster vitamin setelah 14 hari.',
      jenisCatatanKhusus: 'resep',
    ),
  ];

  final List<ActivityItem> _activities = [
    ActivityItem(
      id: 'act1',
      title: 'Scan AI Sapi #012 Selesai',
      subtitle: 'Estimasi bobot 245.8 kg (+5.8 kg dalam 14 hari)',
      timeAgo: '15 mnt lalu',
      icon: 'camera',
    ),
    ActivityItem(
      id: 'act2',
      title: 'Pemberian Konsentrat Pagi',
      subtitle: 'Tercatat Rp 350.000 untuk 12 ekor sapi',
      timeAgo: '2 jam lalu',
      icon: 'receipt',
    ),
    ActivityItem(
      id: 'act3',
      title: 'Vaksinasi Berkala Ditugaskan',
      subtitle: 'Mantri Agus dijadwalkan besok 08:30 WIB',
      timeAgo: '5 jam lalu',
      icon: 'medical',
    ),
  ];

  // Getters
  List<Cattle> get cattleList => List.unmodifiable(_cattleList);
  List<FinancialTransaction> get transactions => List.unmodifiable(_transactions);
  List<MedicalRecord> get medicalRecords => List.unmodifiable(_medicalRecords);
  List<ActivityItem> get activities => List.unmodifiable(_activities);

  int get totalCattle => _cattleList.length;

  int get needAttentionCount => _cattleList.where((c) => c.statusKesehatan != 'Sehat').length;

  double get averageWeight {
    if (_cattleList.isEmpty) return 0.0;
    final total = _cattleList.fold<double>(0.0, (sum, c) => sum + c.beratTerakhir);
    return total / _cattleList.length;
  }

  double calculateHppForCattle(String eartagId) {
    return _transactions
        .where((t) => t.eartagId == eartagId)
        .fold<double>(0.0, (sum, t) => sum + t.nominal);
  }

  double get totalFarmExpense {
    return _transactions.fold<double>(0.0, (sum, t) => sum + t.nominal);
  }

  double get averageHpp {
    if (_cattleList.isEmpty) return 0.0;
    return totalFarmExpense / _cattleList.length;
  }

  double liveCattleMarketPricePerKg = 52000; // Rp 52.000 / kg bobot hidup (Pasar Sapi Madura)
  bool isOfflineMode = true; // Offline-first storage status (SQLite / Hive)
  DateTime lastSyncTime = DateTime.now().subtract(const Duration(minutes: 7));

  double calculateMarketValue(Cattle cattle) {
    return cattle.beratTerakhir * liveCattleMarketPricePerKg;
  }

  double calculateNetProfit(Cattle cattle) {
    return calculateMarketValue(cattle) - calculateHppForCattle(cattle.eartagId);
  }

  double calculateProfitMargin(Cattle cattle) {
    final marketVal = calculateMarketValue(cattle);
    if (marketVal <= 0) return 0;
    return (calculateNetProfit(cattle) / marketVal) * 100;
  }

  double calculateBreakEvenPricePerKg(Cattle cattle) {
    if (cattle.beratTerakhir <= 0) return 0;
    return calculateHppForCattle(cattle.eartagId) / cattle.beratTerakhir;
  }

  double get totalFarmMarketValue {
    return _cattleList.fold<double>(0, (sum, c) => sum + calculateMarketValue(c));
  }

  double get totalFarmNetProfit {
    return totalFarmMarketValue - totalFarmExpense;
  }

  double get averageProfitMargin {
    if (totalFarmMarketValue <= 0) return 0;
    return (totalFarmNetProfit / totalFarmMarketValue) * 100;
  }

  String get lastSyncTimeString {
    final diff = DateTime.now().difference(lastSyncTime);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    return '${diff.inHours} jam lalu';
  }

  Future<void> syncWithFirebase() async {
    await Future.delayed(const Duration(milliseconds: 600));
    lastSyncTime = DateTime.now();
    _activities.insert(
      0,
      ActivityItem(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Sinkronisasi Cloud Firebase Berhasil',
        subtitle: '${_cattleList.length} ternak & ${_transactions.length} transaksi tersinkron',
        timeAgo: 'Baru saja',
        icon: 'receipt',
      ),
    );
    notifyListeners();
  }

  Map<ExpenseCategory, double> get categoryBreakdown {
    final map = <ExpenseCategory, double>{
      ExpenseCategory.pembelianBakalan: 0,
      ExpenseCategory.konsentratPakan: 0,
      ExpenseCategory.vitaminMedis: 0,
      ExpenseCategory.insidental: 0,
    };
    for (var t in _transactions) {
      map[t.kategori] = (map[t.kategori] ?? 0) + t.nominal;
    }
    return map;
  }

  List<FinancialTransaction> getTransactionsForCattle(String eartagId) {
    return _transactions.where((t) => t.eartagId == eartagId).toList();
  }

  List<MedicalRecord> getMedicalRecordsForCattle(String eartagId) {
    return _medicalRecords.where((m) => m.eartagId == eartagId).toList();
  }

  void addTransaction(FinancialTransaction tx) {
    _transactions.insert(0, tx);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  List<Cattle> get priorityCattle {
    final list = _cattleList.where((c) => c.statusKesehatan != 'Sehat').toList();
    list.sort((a, b) => a.tanggalMasuk.compareTo(b.tanggalMasuk));
    return list;
  }

  void addMedicalRecord(MedicalRecord record) {
    _medicalRecords.insert(0, record);
    _activities.insert(
      0,
      ActivityItem(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Rekam Medis Sapi ${record.eartagId}',
        subtitle: '${record.diagnosis} (${record.jenisPenanganan.displayName})',
        timeAgo: 'Baru saja',
        icon: 'medical',
      ),
    );
    notifyListeners();
  }

  void addQuickExpense({
    required String eartagId,
    required String categoryName,
    required double amount,
    required String note,
  }) {
    ExpenseCategory cat = ExpenseCategory.insidental;
    if (categoryName.toLowerCase().contains('pakan')) {
      cat = ExpenseCategory.konsentratPakan;
    } else if (categoryName.toLowerCase().contains('obat') ||
        categoryName.toLowerCase().contains('medis') ||
        categoryName.toLowerCase().contains('salep')) {
      cat = ExpenseCategory.vitaminMedis;
    }
    addTransaction(
      FinancialTransaction(
        id: 'tx_quick_${DateTime.now().millisecondsSinceEpoch}',
        eartagId: eartagId,
        kategori: cat,
        nominal: amount,
        tanggal: DateTime.now(),
        catatan: note,
      ),
    );
  }

  void updateCattleWeight(String eartagId, double newWeight) {
    final cattle = _cattleList.firstWhere((c) => c.eartagId == eartagId);
    cattle.beratTerakhir = newWeight;
    cattle.weightHistory.add(newWeight);
    _activities.insert(
      0,
      ActivityItem(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Scan AI Sapi $eartagId Selesai',
        subtitle: 'Bobot baru terdeteksi: ${newWeight.toStringAsFixed(1)} kg',
        timeAgo: 'Baru saja',
        icon: 'camera',
      ),
    );
    notifyListeners();
  }
}
