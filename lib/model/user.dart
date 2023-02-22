class ApplicationUser {
  final String id;
  final String name;
  final String email;
  final String password;

  ApplicationUser({
    required this.id,
    required this.name,
    required this.email,
    this.password=''
  });
}

