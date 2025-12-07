class Visit {
  final int? id;
  final int userId;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final String diagnosis;
  final String notes;
  final bool isCompleted;
  final double price;
  final String tags;      
  final String category;

  Visit({
    this.id,
    required this.userId,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.diagnosis,
    this.notes = '',
    this.isCompleted = false,
    this.price = 0.0,
    this.tags = '',
    this.category = 'Плановий',
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'doctorName': doctorName,
      'specialty': specialty,
      'date': date.toIso8601String(),
      'diagnosis': diagnosis,
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
      'price': price,
      'tags': tags,
      'category': category,
    };
  }

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      doctorName: map['doctorName'] as String,
      specialty: map['specialty'] as String,
      date: DateTime.parse(map['date'] as String),
      diagnosis: map['diagnosis'] as String,
      notes: map['notes'] as String? ?? '',
      isCompleted: (map['isCompleted'] ?? 0) == 1,
      price: (map['price'] != null)
          ? (map['price'] is int ? (map['price'] as int).toDouble() : map['price'] as double)
          : 0.0,
      tags: map['tags'] as String? ?? '',
      category: map['category'] as String? ?? 'Плановий',
    );
  }

  
  Visit copyWith({
    int? id,
    int? userId,
    String? doctorName,
    String? specialty,
    DateTime? date,
    String? diagnosis,
    String? notes,
    bool? isCompleted,
    double? price,
    String? tags,
    String? category,
  }) {
    return Visit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      date: date ?? this.date,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      price: price ?? this.price,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }
}
