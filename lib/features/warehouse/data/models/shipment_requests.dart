class CreateShipmentRequest {
  final String tujuan;
  final String tglKirim;

  CreateShipmentRequest({
    required this.tujuan,
    required this.tglKirim,
  });

  Map<String, dynamic> toJson() {
    return {
      'tujuan': tujuan,
      'tgl_kirim': tglKirim,
    };
  }
}

class AddItemToShipmentRequest {
  final String lotId;
  final int qty;
  final double berat;

  AddItemToShipmentRequest({
    required this.lotId,
    required this.qty,
    required this.berat,
  });

  Map<String, dynamic> toJson() {
    return {
      'lot_id': lotId,
      'qty': qty,
      'berat': berat,
    };
  }
}
