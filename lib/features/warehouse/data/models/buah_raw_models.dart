class BuahRawBulkRequest {
  final String? tglPanen;
  final List<BuahRawBulkItem> items;

  BuahRawBulkRequest({
    this.tglPanen,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(),
    };
    if (tglPanen != null) {
      json['tgl_panen'] = tglPanen;
    }
    return json;
  }
}

class BuahRawBulkItem {
  final String jenisDurianId;
  final String pohonPanenId;
  final int jumlah;

  BuahRawBulkItem({
    required this.jenisDurianId,
    required this.pohonPanenId,
    required this.jumlah,
  });

  Map<String, dynamic> toJson() {
    return {
      'jenis_durian_id': jenisDurianId,
      'pohon_panen_id': pohonPanenId,
      'jumlah': jumlah,
    };
  }
}

class BuahRawBulkResponse {
  final List<BuahRawItem> items;
  final int totalInserted;

  BuahRawBulkResponse({
    required this.items,
    required this.totalInserted,
  });

  factory BuahRawBulkResponse.fromJson(Map<String, dynamic> json) {
    return BuahRawBulkResponse(
      items: (json['items'] as List)
          .map((item) => BuahRawItem.fromJson(item))
          .toList(),
      totalInserted: json['total_inserted'] ?? 0,
    );
  }
}

class BuahRawItem {
  final String id;
  final String kodeBuah;
  final JenisDurianInfo jenisDurian;
  final LokasiPanenInfo lokasiPanen;
  final String pohonPanen;
  final String tglPanen;
  final bool isSorted;
  final DateTime createdAt;

  BuahRawItem({
    required this.id,
    required this.kodeBuah,
    required this.jenisDurian,
    required this.lokasiPanen,
    required this.pohonPanen,
    required this.tglPanen,
    required this.isSorted,
    required this.createdAt,
  });

  factory BuahRawItem.fromJson(Map<String, dynamic> json) {
    return BuahRawItem(
      id: json['id'] ?? '',
      kodeBuah: json['kode_buah'] ?? '',
      jenisDurian: JenisDurianInfo.fromJson(json['jenis_durian'] ?? {}),
      lokasiPanen: LokasiPanenInfo.fromJson(json['lokasi_panen'] ?? {}),
      pohonPanen: json['pohon_panen'] ?? '',
      tglPanen: json['tgl_panen'] ?? '',
      isSorted: json['is_sorted'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class JenisDurianInfo {
  final String id;
  final String kode;
  final String nama;

  JenisDurianInfo({
    required this.id,
    required this.kode,
    required this.nama,
  });

  factory JenisDurianInfo.fromJson(Map<String, dynamic> json) {
    return JenisDurianInfo(
      id: json['id'] ?? '',
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
    );
  }

  String get displayName => '$kode - $nama';
}

class LokasiPanenInfo {
  final String kodeLengkap;
  final String blokId;
  final String blokNama;
  final String divisiNama;
  final String estateNama;
  final String companyNama;

  LokasiPanenInfo({
    required this.kodeLengkap,
    required this.blokId,
    required this.blokNama,
    required this.divisiNama,
    required this.estateNama,
    required this.companyNama,
  });

  factory LokasiPanenInfo.fromJson(Map<String, dynamic> json) {
    return LokasiPanenInfo(
      kodeLengkap: json['kode_lengkap'] ?? '',
      blokId: json['blok_id'] ?? '',
      blokNama: json['blok_nama'] ?? '',
      divisiNama: json['divisi_nama'] ?? '',
      estateNama: json['estate_nama'] ?? '',
      companyNama: json['company_nama'] ?? '',
    );
  }
}

class UnsortedBuahResponse {
  final List<BuahRawItem> data;
  final PaginationMeta meta;

  UnsortedBuahResponse({
    required this.data,
    required this.meta,
  });

  factory UnsortedBuahResponse.fromJson(Map<String, dynamic> json) {
    return UnsortedBuahResponse(
      data: (json['data'] as List)
          .map((item) => BuahRawItem.fromJson(item))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class PaginationMeta {
  final int page;
  final int limit;
  final int totalData;
  final int totalPage;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.totalData,
    required this.totalPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 50,
      totalData: json['total_data'] ?? 0,
      totalPage: json['total_page'] ?? 1,
    );
  }
}
