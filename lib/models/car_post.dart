class CarPost {
  final int id;
  final String title;
  final String? brand;
  final String? model;
  final int? year;
  final String photoUrl;
  final String? description;
  final String authorUsername;
  final String authorDisplayName;
  final DateTime? createdAt;

  CarPost({
    required this.id,
    required this.title,
    required this.photoUrl,
    required this.authorUsername,
    required this.authorDisplayName,
    this.brand,
    this.model,
    this.year,
    this.description,
    this.createdAt,
  });

  factory CarPost.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final year = json['year'];
    final createdAt = json['createdAt'];

    return CarPost(
      id: id is int ? id : (id is String ? int.tryParse(id) ?? 0 : 0),
      title: json['title']?.toString() ?? '',
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      year: year is int ? year : (year is String ? int.tryParse(year) : null),
      photoUrl: json['photoUrl']?.toString() ?? '',
      description: json['description']?.toString(),
      authorUsername: json['authorUsername']?.toString() ?? '',
      authorDisplayName: json['authorDisplayName']?.toString() ?? '',
      createdAt: createdAt == null
          ? null
          : DateTime.tryParse(createdAt.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brand': brand,
      'model': model,
      'year': year,
      'photoUrl': photoUrl,
      'description': description,
      'authorUsername': authorUsername,
      'authorDisplayName': authorDisplayName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}