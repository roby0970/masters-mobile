class ARCoordinate {
  final double? x;
  final double? y;

  ARCoordinate({this.x, this.y});

  factory ARCoordinate.fromJson(Map<String, dynamic> json) {
    return ARCoordinate(
      x: json['x'],
      y: json['y'],
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };

      @override
  String toString() {
    return "$x, $y";
  }
}
