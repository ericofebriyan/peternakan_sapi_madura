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
