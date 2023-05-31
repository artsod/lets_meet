class Contact {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  bool isRegisterd;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isRegisterd,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isRegisterd: json['isRegisterd'] as bool,
    );
  }
}

