class LotModel {
  final String id;
  final String kode;
  final String jenisDurianId;
  final String jenisDurianNama;
  final String kondisiBuah;
  final double beratAwal;
  final int qtyAwal;
  final double beratSisa;
  final int qtySisa;
  final String status;
  final DateTime createdAt;

  LotModel({
    required this.id,
    required this.kode,
    required this.jenisDurianId,
    required this.jenisDurianNama,
    required this.kondisiBuah,
    required this.beratAwal,
    required this.qtyAwal,
    required this.beratSisa,
    required this.qtySisa,
    required this.status,
    required this.createdAt,
  });

  factory LotModel.fromJson(Map<String, dynamic> json) {
    return LotModel(
      id: json['id'] ?? '',
      kode: json['kode'] ?? '',
      jenisDurianId: json['jenis_durian_id'] ?? '',
      jenisDurianNama: json['jenis_durian_nama'] ?? '',
      kondisiBuah: json['kondisi_buah'] ?? '',
      beratAwal: (json['berat_awal'] ?? 0).toDouble(),
      qtyAwal: json['qty_awal'] ?? 0,
      beratSisa: (json['berat_sisa'] ?? 0).toDouble(),
      qtySisa: json['qty_sisa'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class LotsResponse {
  final List<LotModel> data;

  LotsResponse({required this.data});

  factory LotsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return LotsResponse(
      data: dataList.map((item) => LotModel.fromJson(item)).toList(),
    );
  }
}

class CreateLotRequest {
  final String jenisDurianId;
  final String kondisiBuah;

  CreateLotRequest({
    required this.jenisDurianId,
    required this.kondisiBuah,
  });

  Map<String, dynamic> toJson() {
    return {
      'jenis_durian_id': jenisDurianId,
      'kondisi_buah': kondisiBuah,
    };
  }
}

class CreateLotResponse {
  final String id;
  final String kode;
  final String jenisDurianId;
  final String jenisDurianNama;
  final String kondisiBuah;
  final String status;

  CreateLotResponse({
    required this.id,
    required this.kode,
    required this.jenisDurianId,
    required this.jenisDurianNama,
    required this.kondisiBuah,
    required this.status,
  });

  factory CreateLotResponse.fromJson(Map<String, dynamic> json) {
    return CreateLotResponse(
      id: json['id'] ?? '',
      kode: json['kode'] ?? '',
      jenisDurianId: json['jenis_durian_id'] ?? '',
      jenisDurianNama: json['jenis_durian_nama'] ?? '',
      kondisiBuah: json['kondisi_buah'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class AddItemsToLotRequest {
  final List<String> buahRawIds;

  AddItemsToLotRequest({required this.buahRawIds});

  Map<String, dynamic> toJson() {
    return {
      'buah_raw_ids': buahRawIds,
    };
  }
}

class AddItemsToLotResponse {
  final int currentQty;

  AddItemsToLotResponse({required this.currentQty});

  factory AddItemsToLotResponse.fromJson(Map<String, dynamic> json) {
    return AddItemsToLotResponse(
      currentQty: json['current_qty'] ?? 0,
    );
  }
}

class FinalizeLotRequest {
  final double beratAwal;

  FinalizeLotRequest({required this.beratAwal});

  Map<String, dynamic> toJson() {
    return {
      'berat_awal': beratAwal,
    };
  }
}

class FinalizeLotResponse {
  final String id;
  final int qtyTotal;
  final double beratTotal;
  final String status;

  FinalizeLotResponse({
    required this.id,
    required this.qtyTotal,
    required this.beratTotal,
    required this.status,
  });

  factory FinalizeLotResponse.fromJson(Map<String, dynamic> json) {
    return FinalizeLotResponse(
      id: json['id'] ?? '',
      qtyTotal: json['qty_total'] ?? 0,
      beratTotal: (json['berat_total'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}

class LotDetailItem {
  final String id;
  final String kodeBuah;
  final DateTime tglPanen;
  final String asalBlok;

  LotDetailItem({
    required this.id,
    required this.kodeBuah,
    required this.tglPanen,
    required this.asalBlok,
  });

  factory LotDetailItem.fromJson(Map<String, dynamic> json) {
    return LotDetailItem(
      id: json['id'] ?? '',
      kodeBuah: json['kode_buah'] ?? '',
      tglPanen: json['tgl_panen'] != null
          ? DateTime.parse(json['tgl_panen'])
          : DateTime.now(),
      asalBlok: json['asal_blok'] ?? '',
    );
  }
}

class LotDetailResponse {
  final LotModel header;
  final List<LotDetailItem> items;

  LotDetailResponse({
    required this.header,
    required this.items,
  });

  factory LotDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return LotDetailResponse(
      header: LotModel.fromJson(data['header'] ?? {}),
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => LotDetailItem.fromJson(item))
          .toList(),
    );
  }
}
