class Contact {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  bool isRegistered;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isRegistered,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isRegistered: json['isRegistered'] as bool,
    );
  }
}

