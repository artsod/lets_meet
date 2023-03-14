class Contact {
  final String id;
  final String name;
  final String email;

  Contact({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

