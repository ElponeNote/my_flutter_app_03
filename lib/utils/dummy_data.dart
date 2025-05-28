import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'package:faker/faker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

final faker = Faker();

final sampleImages = [
  'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
  'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
  'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c',
  'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429',
  'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99',
];

List<Post> generateDummyPosts(int count, {int? startId}) {
  final now = DateTime.now();
  return List.generate(count, (i) {
    final id = (startId ?? 0) + i + 1;
    final author = faker.person.firstName();
    final hasImage = faker.randomGenerator.boolean();
    final imageUrl = hasImage ? (sampleImages..shuffle()).first : null;
    return Post(
      id: id.toString(),
      author: author.length > 3 ? author.substring(0, 3) : author,
      content: faker.lorem.sentence(),
      imageUrl: imageUrl,
      createdAt: now.subtract(Duration(minutes: faker.randomGenerator.integer(120))),
      likes: faker.randomGenerator.integer(100),
      likedByMe: false,
      comments: [],
    );
  });
}

class PostListNotifier extends StateNotifier<List<Post>> {
  PostListNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await loadPostsFromPrefs();
  }

  Future<void> addPost(Post post) async {
    state = [post, ...state];
    await savePostsToPrefs(state);
  }

  Future<void> setPosts(List<Post> posts) async {
    state = posts;
    await savePostsToPrefs(state);
  }

  Future<void> removePost(String id) async {
    state = state.where((p) => p.id != id).toList();
    await savePostsToPrefs(state);
  }
}

final postsProvider = StateNotifierProvider<PostListNotifier, List<Post>>((ref) => PostListNotifier());

String postsToJson(List<Post> posts) => json.encode(posts.map((e) => e.toJson()).toList());
List<Post> postsFromJson(String jsonStr) => (json.decode(jsonStr) as List).map((e) => Post.fromJson(e)).toList();

Future<void> savePostsToPrefs(List<Post> posts) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('posts', postsToJson(posts));
}

Future<List<Post>> loadPostsFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString('posts');
  List<Post> posts;
  if (jsonStr != null) {
    posts = postsFromJson(jsonStr);
  } else {
    posts = generateDummyPosts(20);
  }
  // 파일 존재하지 않는 로컬 이미지 경로 자동 정리
  for (final post in posts) {
    if (post.imageUrl != null && !post.imageUrl!.startsWith('http') && !File(post.imageUrl!).existsSync()) {
      post.imageUrl = null;
    }
    if (post.authorImage != null && !post.authorImage!.startsWith('http') && !File(post.authorImage!).existsSync()) {
      post.authorImage = null;
    }
  }
  return posts;
} 