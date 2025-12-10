class ReceiveShipmentItemRequest {
  final String lotId;
  final double beratDiterima;
  final int? qtyDiterima;

  ReceiveShipmentItemRequest({
    required this.lotId,
    required this.beratDiterima,
    this.qtyDiterima,
  });

  Map<String, dynamic> toJson() {
    return {
      'lot_id': lotId,
      'berat_diterima': beratDiterima,
      if (qtyDiterima != null) 'qty_diterima': qtyDiterima,
    };
  }
}

class ReceiveShipmentRequest {
  final String receivedDate;
  final List<ReceiveShipmentItemRequest> details;

  ReceiveShipmentRequest({
    required this.receivedDate,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'received_date': receivedDate,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}
