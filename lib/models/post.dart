class Post {
  final String id;
  final String author;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });
} 