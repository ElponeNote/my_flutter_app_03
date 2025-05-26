import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/dummy_data.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    final activities = posts.map((post) => '${post.author}님이 게시글을 작성했습니다').toList();
    return Scaffold(
      appBar: AppBar(title: const Text('활동')),
      body: activities.isEmpty
          ? const Center(child: Text('활동 내역이 없습니다.'))
          : ListView.separated(
              itemCount: activities.length,
              separatorBuilder: (context, idx) => const Divider(height: 1),
              itemBuilder: (context, idx) => ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(activities[idx]),
              ),
            ),
    );
  }
} 