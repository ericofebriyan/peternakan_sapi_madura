import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cattle.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (kIsWeb) {
      path = 'ternakpro.db';
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      path = join(docsDir.path, 'ternakpro.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE cattles (
        eartag_id TEXT PRIMARY KEY,
        ras TEXT NOT NULL,
        kelompok_umur TEXT NOT NULL,
        tanggal_masuk TEXT NOT NULL,
        berat_awal REAL NOT NULL,
        berat_terakhir REAL NOT NULL,
        status_kesehatan TEXT NOT NULL,
        weight_history TEXT NOT NULL,
        kandang_pen TEXT NOT NULL,
        umur_deskripsi TEXT,
        pakan TEXT,
        adg_custom REAL,
        adg_status TEXT,
        custom_action_button_text TEXT,
        manual_days_in_feedlot INTEGER,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE financial_transactions (
        id TEXT PRIMARY KEY,
        eartag_id TEXT NOT NULL,
        kategori TEXT NOT NULL,
        nominal REAL NOT NULL,
        tanggal TEXT NOT NULL,
        catatan TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE medical_records (
        id TEXT PRIMARY KEY,
        eartag_id TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        tindakan TEXT NOT NULL,
        obat TEXT NOT NULL,
        petugas TEXT NOT NULL,
        jenis_penanganan TEXT NOT NULL,
        lokasi_kandang TEXT NOT NULL,
        status_tindak_lanjut TEXT NOT NULL,
        catatan_khusus TEXT,
        jenis_catatan_khusus TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _seedInitialData(Database db) async {
    final initialCattles = [
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
    ];

    for (var c in initialCattles) {
      final map = c.toMap();
      map['is_synced'] = 0;
      await db.insert('cattles', map, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final initialTxs = [
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
        id: 'tx005',
        eartagId: '#012',
        kategori: ExpenseCategory.insidental,
        nominal: 45000,
        tanggal: DateTime(2026, 3, 5),
        catatan: 'Salep kuku retak',
      ),
      FinancialTransaction(
        id: 'tx008',
        eartagId: '#007',
        kategori: ExpenseCategory.pembelianBakalan,
        nominal: 5500000,
        tanggal: DateTime(2026, 3, 8),
        catatan: 'Pasar Pamekasan',
      ),
    ];

    for (var tx in initialTxs) {
      final map = tx.toMap();
      map['is_synced'] = 0;
      await db.insert('financial_transactions', map, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final initialMedicals = [
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

    for (var m in initialMedicals) {
      final map = m.toMap();
      map['is_synced'] = 0;
      await db.insert('medical_records', map, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // --- Cattles CRUD ---
  Future<List<Cattle>> getCattles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cattles');
    return maps.map((m) => Cattle.fromMap(m)).toList();
  }

  Future<void> insertCattle(Cattle cattle, {bool isSynced = false}) async {
    final db = await database;
    final map = cattle.toMap();
    map['is_synced'] = isSynced ? 1 : 0;
    await db.insert('cattles', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCattle(Cattle cattle, {bool isSynced = false}) async {
    final db = await database;
    final map = cattle.toMap();
    map['is_synced'] = isSynced ? 1 : 0;
    await db.update('cattles', map, where: 'eartag_id = ?', whereArgs: [cattle.eartagId]);
  }

  // --- Transactions CRUD ---
  Future<List<FinancialTransaction>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'financial_transactions',
      orderBy: 'tanggal DESC',
    );
    return maps.map((m) => FinancialTransaction.fromMap(m)).toList();
  }

  Future<void> insertTransaction(FinancialTransaction tx, {bool isSynced = false}) async {
    final db = await database;
    final map = tx.toMap();
    map['is_synced'] = isSynced ? 1 : 0;
    await db.insert('financial_transactions', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Medical Records CRUD ---
  Future<List<MedicalRecord>> getMedicalRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medical_records',
      orderBy: 'tanggal DESC',
    );
    return maps.map((m) => MedicalRecord.fromMap(m)).toList();
  }

  Future<void> insertMedicalRecord(MedicalRecord record, {bool isSynced = false}) async {
    final db = await database;
    final map = record.toMap();
    map['is_synced'] = isSynced ? 1 : 0;
    await db.insert('medical_records', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Sync Helpers ---
  Future<List<Map<String, dynamic>>> getUnsyncedCattles() async {
    final db = await database;
    return await db.query('cattles', where: 'is_synced = 0');
  }

  Future<List<Map<String, dynamic>>> getUnsyncedTransactions() async {
    final db = await database;
    return await db.query('financial_transactions', where: 'is_synced = 0');
  }

  Future<List<Map<String, dynamic>>> getUnsyncedMedicalRecords() async {
    final db = await database;
    return await db.query('medical_records', where: 'is_synced = 0');
  }

  Future<void> markCattleSynced(String eartagId) async {
    final db = await database;
    await db.update('cattles', {'is_synced': 1}, where: 'eartag_id = ?', whereArgs: [eartagId]);
  }

  Future<void> markTransactionSynced(String id) async {
    final db = await database;
    await db.update('financial_transactions', {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markMedicalRecordSynced(String id) async {
    final db = await database;
    await db.update('medical_records', {'is_synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
