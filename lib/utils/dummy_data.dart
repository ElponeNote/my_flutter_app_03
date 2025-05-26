import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'package:faker/faker.dart';

final faker = Faker();

List<Post> generateDummyPosts(int count, {int? startId}) {
  final now = DateTime.now();
  return List.generate(count, (i) {
    final id = (startId ?? 0) + i + 1;
    return Post(
      id: id.toString(),
      author: faker.person.name().substring(0, 3),
      content: faker.lorem.sentence(),
      imageUrl: faker.randomGenerator.boolean(0.4)
          ? null
          : null, // 이미지 랜덤화 필요시 샘플 경로 추가
      createdAt: now.subtract(Duration(minutes: faker.randomGenerator.integer(120))),
    );
  });
}

final postsProvider = StateProvider<List<Post>>((ref) => generateDummyPosts(20)); 