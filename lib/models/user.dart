class User {
  final int? id;
  final String username;
  final String? email;
  final String? displayName;

  User({
    this.id,
    required this.username,
    this.email,
    this.displayName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final username = json['username'];
    final email = json['email'];
    final displayName = json['displayName'];
    
    return User(
      id: id is int ? id : (id is String ? int.tryParse(id) : null),
      username: username is String ? username : username?.toString() ?? '',
      email: email is String ? email : email?.toString(),
      displayName: displayName is String ? displayName : displayName?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
    };
  }
}
