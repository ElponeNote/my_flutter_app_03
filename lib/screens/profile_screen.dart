import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../utils/dummy_data.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    final myPosts = posts.where((post) => post.author == 'Me').toList();
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  child: Icon(Icons.person, size: 36),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Me', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(height: 4),
                    Text('나의 프로필 소개글', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),
            const Text('내 게시글', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: myPosts.isEmpty
                  ? const Center(child: Text('작성한 게시글이 없습니다.'))
                  : ListView.separated(
                      itemCount: myPosts.length,
                      separatorBuilder: (context, idx) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final post = myPosts[idx];
                        return ListTile(
                          title: Text(post.content),
                          subtitle: Text(dateFormat.format(post.createdAt)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 