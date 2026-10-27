class AppUser {
  int? id;
  String name;
  String email;
  String password; // hash করা পাসওয়ার্ড

  AppUser({this.id, required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'] as int,
    name: m['name'] as String,
    email: m['email'] as String,
    password: m['password'] as String,
  );
}