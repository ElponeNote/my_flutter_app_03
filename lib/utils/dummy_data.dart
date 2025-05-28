import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'package:faker/faker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

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
  final uuid = const Uuid();
  return List.generate(count, (i) {
    final id = (startId ?? 0) + i + 1;
    final author = faker.person.firstName();
    final hasImage = faker.randomGenerator.boolean();
    final imageUrl = hasImage ? (sampleImages..shuffle()).first : null;
    return Post(
      id: id.toString(),
      userId: uuid.v4(),
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
    print('[PostListNotifier] 생성자 호출');
    _load();
  }

  Future<void> _load() async {
    print('[PostListNotifier] _load() 호출');
    state = await loadPostsFromPrefs();

    // userId 마이그레이션: 내 예전 게시글의 userId를 현재 userId로 맞춤
    final prefs = await SharedPreferences.getInstance();
    final myUserId = prefs.getString('userId');
    final profileJson = prefs.getString('profile');
    String? myName;
    if (profileJson != null) {
      final map = json.decode(profileJson) as Map<String, dynamic>;
      myName = map['name'] as String?;
    }
    if (myUserId != null && myName != null) {
      bool changed = false;
      for (var i = 0; i < state.length; i++) {
        final post = state[i];
        // 내 예전 게시글(작성자 이름이 내 프로필 이름과 같고 userId가 다르면 교체)
        if (post.author == myName && post.userId != myUserId) {
          state[i] = Post(
            id: post.id,
            userId: myUserId,
            author: post.author,
            content: post.content,
            imageUrl: post.imageUrl,
            videoUrl: post.videoUrl,
            authorImage: post.authorImage,
            authorBio: post.authorBio,
            createdAt: post.createdAt,
            likes: post.likes,
            likedByMe: post.likedByMe,
            comments: post.comments,
          );
          changed = true;
        }
      }
      if (changed) {
        await savePostsToPrefs(state);
      }
    }
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
List<Post> postsFromJson(String jsonStr) => (json.decode(jsonStr) as List).map((e) {
  final map = e as Map<String, dynamic>;
  if (!map.containsKey('userId')) map['userId'] = '';
  return Post.fromJson(map);
}).toList();

Future<void> savePostsToPrefs(List<Post> posts) async {
  final prefs = await SharedPreferences.getInstance();
  print('[savePostsToPrefs] posts.length: \x1B[33m${posts.length}[0m');
  await prefs.setString('posts', postsToJson(posts));
  print('[savePostsToPrefs] 저장 완료');
}

Future<List<Post>> loadPostsFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString('posts');
  print('[loadPostsFromPrefs] posts 존재 여부: \x1B[33m${jsonStr != null}\x1B[0m');
  List<Post> posts;
  if (jsonStr != null) {
    posts = postsFromJson(jsonStr);
    print('[loadPostsFromPrefs] 불러온 posts.length: \x1B[33m${posts.length}\x1B[0m');
    for (final post in posts) {
      print('[loadPostsFromPrefs] post: id=\x1B[33m${post.id}\x1B[0m, author=\x1B[33m${post.author}\x1B[0m, content=\x1B[33m${post.content}\x1B[0m');
    }
  } else {
    posts = [];
    print('[loadPostsFromPrefs] 저장된 posts 없음, 빈 리스트 반환');
  }
  for (final post in posts) {
    // imageUrl 복구
    if (post.imageUrl != null && !post.imageUrl!.startsWith('http') && !File(post.imageUrl!).existsSync()) {
      if (post.imageBase64 != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'post_${post.id}_restored.jpg';
        final restoredPath = '${appDir.path}/$fileName';
        final restoredFile = File(restoredPath);
        await restoredFile.writeAsBytes(base64Decode(post.imageBase64!));
        post.imageUrl = restoredPath;
      } else {
        post.imageUrl = null;
      }
    }
    // authorImage 복구
    if (post.authorImage != null && !post.authorImage!.startsWith('http') && !File(post.authorImage!).existsSync()) {
      if (post.authorImageBase64 != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'author_${post.userId}_restored.jpg';
        final restoredPath = '${appDir.path}/$fileName';
        final restoredFile = File(restoredPath);
        await restoredFile.writeAsBytes(base64Decode(post.authorImageBase64!));
        post.authorImage = restoredPath;
      } else {
        post.authorImage = null;
      }
    }
  }
  return posts;
} 