import 'comment.dart';

class CarPost {
  static const List<String> reactionTypes = [
    'LIKE',
    'LOVE',
    'ANGRY',
    'SAD',
    'WOW',
    'LAUGH',
  ];

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
  final Map<String, int> reactions;
  final String? userReaction;
  final List<Comment> comments;

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
    this.reactions = const {
      'LIKE': 0,
      'LOVE': 0,
      'ANGRY': 0,
      'SAD': 0,
      'WOW': 0,
      'LAUGH': 0,
    },
    this.userReaction,
    this.comments = const [],
  });

  static Map<String, int> _parseReactions(dynamic value) {
    final result = <String, int>{for (final type in reactionTypes) type: 0};

    if (value is Map) {
      value.forEach((key, dynamic rawCount) {
        final normalizedKey = key.toString().toUpperCase();
        if (!result.containsKey(normalizedKey)) {
          return;
        }

        if (rawCount is int) {
          result[normalizedKey] = rawCount;
          return;
        }

        final parsed = int.tryParse(rawCount?.toString() ?? '0') ?? 0;
        result[normalizedKey] = parsed;
      });
    }

    return result;
  }

  static String? _parseUserReaction(dynamic value) {
    if (value == null) {
      return null;
    }

    final normalized = value.toString().toUpperCase();
    return reactionTypes.contains(normalized) ? normalized : null;
  }

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
      reactions: _parseReactions(json['reactions']),
      userReaction: _parseUserReaction(json['userReaction']),
      comments: (json['comments'] is List)
          ? (json['comments'] as List)
              .map((e) => Comment.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
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
      'reactions': reactions,
      'userReaction': userReaction,
        'comments': comments.map((c) => c.toJson()).toList(),
    };
  }
}