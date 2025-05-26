import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';

final postsProvider = StateProvider<List<Post>>((ref) => [
  Post(
    id: '1',
    author: 'User1',
    content: '첫 번째 더미 게시글',
    imageUrl: null,
    createdAt: DateTime.now(),
  ),
  Post(
    id: '2',
    author: 'User2',
    content: '두 번째 더미 게시글',
    imageUrl: null,
    createdAt: DateTime.now(),
  ),
]); 