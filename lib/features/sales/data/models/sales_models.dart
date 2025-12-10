class SalesModel {
  final String id;
  final String pengirimanId;
  final double beratTerjual;
  final double hargaTotal;
  final String tipeJual;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SalesModel({
    required this.id,
    required this.pengirimanId,
    required this.beratTerjual,
    required this.hargaTotal,
    required this.tipeJual,
    required this.createdAt,
    this.updatedAt,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      id: json['id'],
      pengirimanId: json['pengiriman_id'],
      beratTerjual: (json['berat_terjual'] as num).toDouble(),
      hargaTotal: (json['harga_total'] as num).toDouble(),
      tipeJual: json['tipe_jual'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}

class CreateSalesRequest {
  final String pengirimanId;
  final double beratTerjual;
  final double hargaTotal;
  final String tipeJual;

  CreateSalesRequest({
    required this.pengirimanId,
    required this.beratTerjual,
    required this.hargaTotal,
    required this.tipeJual,
  });

  Map<String, dynamic> toJson() {
    return {
      'pengiriman_id': pengirimanId,
      'berat_terjual': beratTerjual,
      'harga_total': hargaTotal,
      'tipe_jual': tipeJual,
    };
  }
}

class UpdateSalesRequest {
  final double beratTerjual;
  final double hargaTotal;
  final String tipeJual;

  UpdateSalesRequest({
    required this.beratTerjual,
    required this.hargaTotal,
    required this.tipeJual,
  });

  Map<String, dynamic> toJson() {
    return {
      'berat_terjual': beratTerjual,
      'harga_total': hargaTotal,
      'tipe_jual': tipeJual,
    };
  }
}
