class Comment {
  final String id;
  final String author;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    author: json['author'],
    content: json['content'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class Post {
  final String id;
  final String author;
  final String content;
  String? imageUrl;
  final String? videoUrl;
  String? authorImage;
  final String? authorBio;
  final DateTime createdAt;
  final int likes;
  final bool likedByMe;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.authorImage,
    this.authorBio,
    required this.createdAt,
    this.likes = 0,
    this.likedByMe = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'content': content,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
    'authorImage': authorImage,
    'authorBio': authorBio,
    'createdAt': createdAt.toIso8601String(),
    'likes': likes,
    'likedByMe': likedByMe,
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'],
    author: json['author'],
    content: json['content'],
    imageUrl: json['imageUrl'],
    videoUrl: json['videoUrl'],
    authorImage: json['authorImage'],
    authorBio: json['authorBio'],
    createdAt: DateTime.parse(json['createdAt']),
    likes: json['likes'] ?? 0,
    likedByMe: json['likedByMe'] ?? false,
    comments: (json['comments'] as List?)?.map((e) => Comment.fromJson(e)).toList() ?? [],
  );
} 