class Comment {
  final String id;
  final String author;
  final String content;
  final DateTime createdAt;
  final String? authorImage;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.authorImage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'authorImage': authorImage,
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    author: json['author'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
    authorImage: json['authorImage'],
  );
}

class Post {
  final String id;
  final String userId;
  final String author;
  final String content;
  String? imageUrl;
  String? imageBase64;
  final String? videoUrl;
  String? authorImage;
  String? authorImageBase64;
  final String? authorBio;
  final DateTime createdAt;
  final int likes;
  final bool likedByMe;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.author,
    required this.content,
    this.imageUrl,
    this.imageBase64,
    this.videoUrl,
    this.authorImage,
    this.authorImageBase64,
    this.authorBio,
    required this.createdAt,
    this.likes = 0,
    this.likedByMe = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'author': author,
    'content': content,
    'imageUrl': imageUrl,
    'imageBase64': imageBase64,
    'videoUrl': videoUrl,
    'authorImage': authorImage,
    'authorImageBase64': authorImageBase64,
    'authorBio': authorBio,
    'createdAt': createdAt.toIso8601String(),
    'likes': likes,
    'likedByMe': likedByMe,
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'],
    userId: json['userId'] ?? '',
    author: json['author'],
    content: json['content'],
    imageUrl: json['imageUrl'],
    imageBase64: json['imageBase64'],
    videoUrl: json['videoUrl'],
    authorImage: json['authorImage'],
    authorImageBase64: json['authorImageBase64'],
    authorBio: json['authorBio'],
    createdAt: DateTime.parse(json['createdAt']),
    likes: json['likes'] ?? 0,
    likedByMe: json['likedByMe'] ?? false,
    comments: (json['comments'] as List?)?.map((e) => Comment.fromJson(e)).toList() ?? [],
  );
} 