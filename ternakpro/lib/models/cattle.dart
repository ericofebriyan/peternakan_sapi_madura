import 'dart:convert';

class Cattle {
  final String eartagId;
  final String ras;
  final String kelompokUmur;
  final DateTime tanggalMasuk;
  final double beratAwal;
  double beratTerakhir;
  String statusKesehatan;
  final List<double> weightHistory;
  final String kandangPen;
  final String? umurDeskripsi;
  final String? pakan;
  final double? adgCustom;
  final String? adgStatus;
  final String? customActionButtonText;
  final int? manualDaysInFeedlot;

  Cattle({
    required this.eartagId,
    required this.ras,
    required this.kelompokUmur,
    required this.tanggalMasuk,
    required this.beratAwal,
    required this.beratTerakhir,
    required this.statusKesehatan,
    required this.weightHistory,
    this.kandangPen = 'Kandang Pen A-01',
    this.umurDeskripsi,
    this.pakan,
    this.adgCustom,
    this.adgStatus,
    this.customActionButtonText,
    this.manualDaysInFeedlot,
  });

  int get daysInFeedlot {
    if (manualDaysInFeedlot != null) return manualDaysInFeedlot!;
    return DateTime.now().difference(tanggalMasuk).inDays;
  }

  double get weightGain {
    return beratTerakhir - beratAwal;
  }

  double get adg {
    if (adgCustom != null) return adgCustom!;
    if (daysInFeedlot <= 0) return 0.0;
    return weightGain / daysInFeedlot;
  }

  Map<String, dynamic> toMap() {
    return {
      'eartag_id': eartagId,
      'ras': ras,
      'kelompok_umur': kelompokUmur,
      'tanggal_masuk': tanggalMasuk.toIso8601String(),
      'berat_awal': beratAwal,
      'berat_terakhir': beratTerakhir,
      'status_kesehatan': statusKesehatan,
      'weight_history': jsonEncode(weightHistory),
      'kandang_pen': kandangPen,
      'umur_deskripsi': umurDeskripsi,
      'pakan': pakan,
      'adg_custom': adgCustom,
      'adg_status': adgStatus,
      'custom_action_button_text': customActionButtonText,
      'manual_days_in_feedlot': manualDaysInFeedlot,
    };
  }

  factory Cattle.fromMap(Map<String, dynamic> map) {
    List<double> history = [];
    if (map['weight_history'] != null) {
      if (map['weight_history'] is String) {
        try {
          final decoded = jsonDecode(map['weight_history']);
          if (decoded is List) {
            history = decoded.map((e) => (e as num).toDouble()).toList();
          }
        } catch (_) {}
      } else if (map['weight_history'] is List) {
        history = (map['weight_history'] as List).map((e) => (e as num).toDouble()).toList();
      }
    }

    return Cattle(
      eartagId: map['eartag_id'] ?? '',
      ras: map['ras'] ?? '',
      kelompokUmur: map['kelompok_umur'] ?? '',
      tanggalMasuk: map['tanggal_masuk'] != null
          ? DateTime.tryParse(map['tanggal_masuk'].toString()) ?? DateTime.now()
          : DateTime.now(),
      beratAwal: (map['berat_awal'] as num?)?.toDouble() ?? 0.0,
      beratTerakhir: (map['berat_terakhir'] as num?)?.toDouble() ?? 0.0,
      statusKesehatan: map['status_kesehatan'] ?? 'Sehat',
      weightHistory: history.isNotEmpty
          ? history
          : [(map['berat_awal'] as num?)?.toDouble() ?? 0.0, (map['berat_terakhir'] as num?)?.toDouble() ?? 0.0],
      kandangPen: map['kandang_pen'] ?? 'Kandang Pen A-01',
      umurDeskripsi: map['umur_deskripsi'],
      pakan: map['pakan'],
      adgCustom: (map['adg_custom'] as num?)?.toDouble(),
      adgStatus: map['adg_status'],
      customActionButtonText: map['custom_action_button_text'],
      manualDaysInFeedlot: map['manual_days_in_feedlot'] as int?,
    );
  }
}

enum ExpenseCategory {
  pembelianBakalan,
  konsentratPakan,
  vitaminMedis,
  insidental,
}

extension ExpenseCategoryExt on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.pembelianBakalan:
        return 'Pembelian Bakalan';
      case ExpenseCategory.konsentratPakan:
        return 'Konsentrat Pakan';
      case ExpenseCategory.vitaminMedis:
        return 'Vitamin & Medis';
      case ExpenseCategory.insidental:
        return 'Insidental & Lainnya';
    }
  }

  static ExpenseCategory fromString(String val) {
    val = val.toLowerCase();
    if (val.contains('bakalan')) return ExpenseCategory.pembelianBakalan;
    if (val.contains('pakan') || val.contains('konsentrat')) return ExpenseCategory.konsentratPakan;
    if (val.contains('medis') || val.contains('vitamin') || val.contains('salep')) return ExpenseCategory.vitaminMedis;
    return ExpenseCategory.insidental;
  }
}

class FinancialTransaction {
  final String id;
  final String eartagId;
  final ExpenseCategory kategori;
  final double nominal;
  final DateTime tanggal;
  final String catatan;

  FinancialTransaction({
    required this.id,
    required this.eartagId,
    required this.kategori,
    required this.nominal,
    required this.tanggal,
    required this.catatan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eartag_id': eartagId,
      'kategori': kategori.displayName,
      'nominal': nominal,
      'tanggal': tanggal.toIso8601String(),
      'catatan': catatan,
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    return FinancialTransaction(
      id: map['id']?.toString() ?? '',
      eartagId: map['eartag_id'] ?? '',
      kategori: ExpenseCategoryExt.fromString(map['kategori'] ?? ''),
      nominal: (map['nominal'] as num?)?.toDouble() ?? 0.0,
      tanggal: map['tanggal'] != null
          ? DateTime.tryParse(map['tanggal'].toString()) ?? DateTime.now()
          : DateTime.now(),
      catatan: map['catatan'] ?? '',
    );
  }
}

enum MedicalHandlingType {
  mandiri,
  resepMantri,
}

extension MedicalHandlingTypeExt on MedicalHandlingType {
  String get displayName {
    switch (this) {
      case MedicalHandlingType.mandiri:
        return 'Mandiri';
      case MedicalHandlingType.resepMantri:
        return 'Resep Mantri';
    }
  }

  static MedicalHandlingType fromString(String val) {
    if (val.toLowerCase().contains('mandiri')) return MedicalHandlingType.mandiri;
    return MedicalHandlingType.resepMantri;
  }
}

class MedicalRecord {
  final String id;
  final String eartagId;
  final DateTime tanggal;
  final String diagnosis;
  final String tindakan;
  final String obat;
  final String petugas;
  final MedicalHandlingType jenisPenanganan;
  final String lokasiKandang;
  final String statusTindakLanjut;
  final String? catatanKhusus;
  final String? jenisCatatanKhusus; // 'evaluasi', 'perhatian', 'resep'

  MedicalRecord({
    required this.id,
    required this.eartagId,
    required this.tanggal,
    required this.diagnosis,
    required this.tindakan,
    required this.obat,
    required this.petugas,
    this.jenisPenanganan = MedicalHandlingType.resepMantri,
    this.lokasiKandang = 'Kandang A',
    this.statusTindakLanjut = 'Membaik / Selesai',
    this.catatanKhusus,
    this.jenisCatatanKhusus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eartag_id': eartagId,
      'tanggal': tanggal.toIso8601String(),
      'diagnosis': diagnosis,
      'tindakan': tindakan,
      'obat': obat,
      'petugas': petugas,
      'jenis_penanganan': jenisPenanganan.displayName,
      'lokasi_kandang': lokasiKandang,
      'status_tindak_lanjut': statusTindakLanjut,
      'catatan_khusus': catatanKhusus,
      'jenis_catatan_khusus': jenisCatatanKhusus,
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id']?.toString() ?? '',
      eartagId: map['eartag_id'] ?? '',
      tanggal: map['tanggal'] != null
          ? DateTime.tryParse(map['tanggal'].toString()) ?? DateTime.now()
          : DateTime.now(),
      diagnosis: map['diagnosis'] ?? '',
      tindakan: map['tindakan'] ?? '',
      obat: map['obat'] ?? '',
      petugas: map['petugas'] ?? '',
      jenisPenanganan: MedicalHandlingTypeExt.fromString(map['jenis_penanganan'] ?? ''),
      lokasiKandang: map['lokasi_kandang'] ?? 'Kandang A',
      statusTindakLanjut: map['status_tindak_lanjut'] ?? 'Membaik / Selesai',
      catatanKhusus: map['catatan_khusus'],
      jenisCatatanKhusus: map['jenis_catatan_khusus'],
    );
  }
}

class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String icon;

  ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.icon,
  });
}
