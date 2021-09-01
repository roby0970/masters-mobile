class Ble {
  final int? id;
  final String? title;
  final int? idspace;


  Ble({this.id, this.title, this.idspace});

  factory Ble.fromJson(Map<String, dynamic> json) {
    return Ble(
      id: json['id'],
      title: json['title'],
      idspace: json['idspace'],

    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'idspace': idspace,

      };
}
