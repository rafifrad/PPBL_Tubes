class Equipment {
  int? id;
  String name;
  String condition;

  Equipment({this.id, required this.name, required this.condition});

  factory Equipment.fromMap(Map<String, dynamic> map) => Equipment(
        id: map['id'] as int?,
        name: map['name'] as String,
        condition: map['condition'] as String,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,
      'condition': condition,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}

