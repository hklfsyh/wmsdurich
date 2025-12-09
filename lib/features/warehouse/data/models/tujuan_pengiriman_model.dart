class TujuanPengirimanModel {
  final String id;
  final String nama;
  final String tipe; // 'internal' or 'external'
  final String alamat;
  final String kontak;
  final String createdAt;
  final String updatedAt;

  TujuanPengirimanModel({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.alamat,
    required this.kontak,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TujuanPengirimanModel.fromJson(Map<String, dynamic> json) {
    return TujuanPengirimanModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      tipe: json['tipe'] as String,
      alamat: json['alamat'] as String,
      kontak: json['kontak'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe,
      'alamat': alamat,
      'kontak': kontak,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TujuanPengirimanListResponse {
  final int code;
  final String message;
  final List<TujuanPengirimanModel> data;

  TujuanPengirimanListResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory TujuanPengirimanListResponse.fromJson(Map<String, dynamic> json) {
    return TujuanPengirimanListResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => TujuanPengirimanModel.fromJson(item))
          .toList(),
    );
  }
}

class TujuanPengirimanResponse {
  final int code;
  final String message;
  final TujuanPengirimanModel data;

  TujuanPengirimanResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory TujuanPengirimanResponse.fromJson(Map<String, dynamic> json) {
    return TujuanPengirimanResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: TujuanPengirimanModel.fromJson(json['data']),
    );
  }
}

class CreateTujuanPengirimanRequest {
  final String nama;
  final String tipe;
  final String alamat;
  final String kontak;

  CreateTujuanPengirimanRequest({
    required this.nama,
    required this.tipe,
    required this.alamat,
    required this.kontak,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'tipe': tipe,
      'alamat': alamat,
      'kontak': kontak,
    };
  }
}

class UpdateTujuanPengirimanRequest {
  final String nama;
  final String tipe;
  final String alamat;
  final String kontak;

  UpdateTujuanPengirimanRequest({
    required this.nama,
    required this.tipe,
    required this.alamat,
    required this.kontak,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'tipe': tipe,
      'alamat': alamat,
      'kontak': kontak,
    };
  }
}
