import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/dummy_data.dart';

final profileProvider = StateProvider<ProfileData>((ref) => ProfileData());

class ProfileData {
  String name;
  String bio;
  File? imageFile;
  ProfileData({this.name = 'Me', this.bio = '나의 프로필 소개글', this.imageFile});
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final posts = ref.watch(postsProvider);
    final myPosts = posts.where((post) =>
      post.author == profile.name &&
      (post.authorImage ?? '') == (profile.imageFile?.path ?? '') &&
      (post.authorBio ?? '') == profile.bio
    ).toList();
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      ref.read(profileProvider.notifier).state = ProfileData(
                        name: profile.name,
                        bio: profile.bio,
                        imageFile: File(picked.path),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: profile.imageFile != null ? FileImage(profile.imageFile!) : null,
                    child: profile.imageFile == null ? const Icon(Icons.person, size: 36) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(profile.bio, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          name: profile.name,
                          bio: profile.bio,
                          imageFile: profile.imageFile,
                        ),
                      ),
                    );
                    if (result is ProfileData) {
                      ref.read(profileProvider.notifier).state = result;
                    }
                  },
                  child: const Text('프로필 편집'),
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

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String bio;
  final File? imageFile;
  const EditProfileScreen({super.key, required this.name, required this.bio, this.imageFile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _bioController = TextEditingController(text: widget.bio);
    _imageFile = widget.imageFile;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 편집')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null ? const Icon(Icons.person, size: 40) : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: '소개글'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, ProfileData(
                    name: _nameController.text.trim(),
                    bio: _bioController.text.trim(),
                    imageFile: _imageFile,
                  ));
                },
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 