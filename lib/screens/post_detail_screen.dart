import 'package:flutter/material.dart';
import '../models/post.dart';
import 'dart:io';
import 'dart:convert';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 상세')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAuthorAvatar(post),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    if (post.authorBio != null && post.authorBio!.isNotEmpty)
                      Text(post.authorBio!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(post.content, style: const TextStyle(fontSize: 16)),
            if (post.imageUrl != null && File(post.imageUrl!).existsSync()) ...[
              const SizedBox(height: 18),
              Image.file(File(post.imageUrl!), fit: BoxFit.cover, width: double.infinity, height: 220),
            ],
            const Spacer(),
            Text('작성일: ${post.createdAt.year}.${post.createdAt.month.toString().padLeft(2, '0')}.${post.createdAt.day.toString().padLeft(2, '0')} ${post.createdAt.hour.toString().padLeft(2, '0')}:${post.createdAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorAvatar(Post post) {
    if (post.authorImage != null && File(post.authorImage!).existsSync()) {
      return CircleAvatar(radius: 24, backgroundImage: FileImage(File(post.authorImage!)));
    } else if (post.authorImageBase64 != null) {
      return CircleAvatar(radius: 24, backgroundImage: MemoryImage(base64Decode(post.authorImageBase64!)));
    } else {
      return const CircleAvatar(radius: 24, child: Icon(Icons.person));
    }
  }
} 