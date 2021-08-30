class BLEReading {
  final int? idBle;
  final int? rssi;

  BLEReading({this.idBle, this.rssi});

  factory BLEReading.fromJson(Map<String, dynamic> json) {
    return BLEReading(
      idBle: json['id_ble'],
      rssi: json['rssi'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_ble': idBle,
        'rssi': rssi,
      };
}
