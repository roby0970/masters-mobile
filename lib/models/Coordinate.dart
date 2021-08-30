class Coordinate {
  final int? x;
  final int? y;

  Coordinate({this.x, this.y});

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      x: json['x'],
      y: json['y'],
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
}
