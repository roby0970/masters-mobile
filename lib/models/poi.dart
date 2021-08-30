class Poi {
  final int? id;
  final String? title;
  final int? idspace;
  final int? color;

  Poi({this.id, this.title, this.idspace, this.color});

  factory Poi.fromJson(Map<String, dynamic> json) {
    return Poi(
      id: json['id'],
      title: json['title'],
      idspace: json['idspace'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'idspace': idspace,
        'color': color,
      };
}
