class BlokModel {
  final String id;
  final String kode;
  final String namaBlok;
  final String kodeLengkap;

  BlokModel({
    required this.id,
    required this.kode,
    required this.namaBlok,
    required this.kodeLengkap,
  });

  factory BlokModel.fromJson(Map<String, dynamic> json) {
    return BlokModel(
      id: json['id'] ?? '',
      kode: json['kode'] ?? '',
      namaBlok: json['nama_blok'] ?? '',
      kodeLengkap: json['kode_lengkap'] ?? '',
    );
  }
}

class JenisDurianModel {
  final String id;
  final String kode;
  final String namaJenis;

  JenisDurianModel({
    required this.id,
    required this.kode,
    required this.namaJenis,
  });

  factory JenisDurianModel.fromJson(Map<String, dynamic> json) {
    return JenisDurianModel(
      id: json['id'] ?? '',
      kode: json['kode'] ?? '',
      namaJenis: json['nama_jenis'] ?? '',
    );
  }

  String get displayName => '$kode - $namaJenis';
}

class PohonModel {
  final String id;
  final String kode;
  final String nama;
  final String kodeLengkap;
  final String blokId;

  PohonModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.kodeLengkap,
    required this.blokId,
  });

  factory PohonModel.fromJson(Map<String, dynamic> json) {
    return PohonModel(
      id: json['id'] ?? '',
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
      kodeLengkap: json['kode_lengkap'] ?? '',
      blokId: json['blok_id'] ?? '',
    );
  }
}

class WarehouseDataModel {
  final int totalBuahRawToday;
  final int totalLotReady;
  final int totalLotSent;

  WarehouseDataModel({
    required this.totalBuahRawToday,
    required this.totalLotReady,
    required this.totalLotSent,
  });

  factory WarehouseDataModel.fromJson(Map<String, dynamic> json) {
    return WarehouseDataModel(
      totalBuahRawToday: json['total_buah_raw_today'] ?? 0,
      totalLotReady: json['total_lot_ready'] ?? 0,
      totalLotSent: json['total_lot_sent'] ?? 0,
    );
  }
}
