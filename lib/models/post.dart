class Post {
  final String id;
  final String author;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final String? authorImage;
  final String? authorBio;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.author,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    this.authorImage,
    this.authorBio,
    required this.createdAt,
  });
} 