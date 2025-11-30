class ShipmentModel {
  final String id;
  final String tujuan;
  final DateTime tglKirim;
  final String status;
  final int totalItems;
  final double totalBerat;
  final String? createdBy;
  final DateTime createdAt;

  ShipmentModel({
    required this.id,
    required this.tujuan,
    required this.tglKirim,
    required this.status,
    required this.totalItems,
    required this.totalBerat,
    this.createdBy,
    required this.createdAt,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] ?? '',
      tujuan: json['tujuan'] ?? '',
      tglKirim: json['tgl_kirim'] != null
          ? DateTime.parse(json['tgl_kirim'])
          : DateTime.now(),
      status: json['status'] ?? 'DRAFT',
      totalItems: json['total_items'] ?? 0,
      totalBerat: (json['total_berat'] ?? 0).toDouble(),
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class ShipmentItemModel {
  final String id;
  final String lotId;
  final String lotKode;
  final String jenisDurian;
  final String kondisiBuah;
  final int qtyAmbil;
  final double beratAmbil;

  ShipmentItemModel({
    required this.id,
    required this.lotId,
    required this.lotKode,
    required this.jenisDurian,
    required this.kondisiBuah,
    required this.qtyAmbil,
    required this.beratAmbil,
  });

  factory ShipmentItemModel.fromJson(Map<String, dynamic> json) {
    return ShipmentItemModel(
      id: json['id'] ?? '',
      lotId: json['lot_id'] ?? '',
      lotKode: json['lot_kode'] ?? '',
      jenisDurian: json['jenis_durian'] ?? '',
      kondisiBuah: json['kondisi_buah'] ?? '',
      qtyAmbil: json['qty_ambil'] ?? 0,
      beratAmbil: (json['berat_ambil'] ?? 0).toDouble(),
    );
  }
}

class ShipmentDetailResponse {
  final ShipmentModel header;
  final List<ShipmentItemModel> items;

  ShipmentDetailResponse({
    required this.header,
    required this.items,
  });

  factory ShipmentDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return ShipmentDetailResponse(
      header: ShipmentModel.fromJson(data['header'] ?? {}),
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => ShipmentItemModel.fromJson(item))
          .toList(),
    );
  }
}
