class Comment {
  final int id;
  final int userId;
  final String authorUsername;
  final String authorDisplayName;
  final String content;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.authorUsername,
    required this.authorDisplayName,
    required this.content,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return Comment(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      authorUsername: json['authorUsername']?.toString() ?? '',
      authorDisplayName: json['authorDisplayName']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: created == null ? null : DateTime.tryParse(created.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'authorUsername': authorUsername,
        'authorDisplayName': authorDisplayName,
        'content': content,
        'createdAt': createdAt?.toIso8601String(),
      };
}
