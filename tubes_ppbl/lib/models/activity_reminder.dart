class ActivityReminder {
  int? id;
  String name;
  String time;

  ActivityReminder({
    this.id,
    required this.name,
    required this.time,
  });

  factory ActivityReminder.fromMap(Map<String, dynamic> map) => ActivityReminder(
        id: map['id'] as int?,
        name: map['name'] as String,
        time: map['time'] as String,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'name': name,
      'time': time,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}

