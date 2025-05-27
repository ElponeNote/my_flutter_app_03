import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'package:faker/faker.dart';

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
    );
  });
}

final postsProvider = StateProvider<List<Post>>((ref) => generateDummyPosts(20)); 