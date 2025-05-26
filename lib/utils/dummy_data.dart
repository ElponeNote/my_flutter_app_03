import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'package:faker/faker.dart';

final faker = Faker();

List<Post> generateDummyPosts(int count, {int? startId}) {
  final now = DateTime.now();
  return List.generate(count, (i) {
    final id = (startId ?? 0) + i + 1;
    final author = faker.person.firstName();
    return Post(
      id: id.toString(),
      author: author.length > 3 ? author.substring(0, 3) : author,
      content: faker.lorem.sentence(),
      imageUrl: null, // 샘플 이미지 경로 필요시 추가
      createdAt: now.subtract(Duration(minutes: faker.randomGenerator.integer(120))),
    );
  });
}

final postsProvider = StateProvider<List<Post>>((ref) => generateDummyPosts(20)); 