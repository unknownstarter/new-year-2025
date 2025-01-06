class User {
  final String name;
  final String gender;
  final DateTime birthDateTime;

  User({
    required this.name,
    required this.gender,
    required this.birthDateTime,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'gender': gender,
        'birthDateTime': birthDateTime.toIso8601String(),
      };
}
