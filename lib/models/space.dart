class Space {
  final int? id;
  final String? title;
  final int? area;
  final double? longitude;
  final double? latitude;

  Space({this.id, this.title, this.area, this.longitude, this.latitude});

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'],
      title: json['title'],
      area: json['area'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'area': area,
        'longitude': longitude,
        'latitude': latitude,
      };
}
