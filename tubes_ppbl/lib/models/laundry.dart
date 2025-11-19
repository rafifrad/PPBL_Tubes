class Laundry {
  int? id;
  String type;
  int quantity;
  String status;

  Laundry({
    this.id,
    required this.type,
    required this.quantity,
    required this.status,
  });

  factory Laundry.fromMap(Map<String, dynamic> map) => Laundry(
        id: map['id'] as int?,
        type: map['type'] as String,
        quantity: map['quantity'] as int,
        status: map['status'] as String,
      );

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'type': type,
      'quantity': quantity,
      'status': status,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}

