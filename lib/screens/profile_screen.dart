import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/dummy_data.dart';

class ProfileData {
  final String userId;
  String name;
  String bio;
  String? imagePath;
  String? imageBase64;

  ProfileData({
    required this.userId,
    this.name = 'Me',
    this.bio = '나의 프로필 소개글',
    this.imagePath,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'bio': bio,
    'imagePath': imagePath,
    'imageBase64': imageBase64,
  };

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    userId: json['userId'] ?? const Uuid().v4(),
    name: json['name'] ?? 'Me',
    bio: json['bio'] ?? '나의 프로필 소개글',
    imagePath: json['imagePath'],
    imageBase64: json['imageBase64'],
  );
}

class ProfileNotifier extends AsyncNotifier<ProfileData> {
  @override
  Future<ProfileData> build() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    print('[ProfileNotifier] shared_preferences userId: $userId');
    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('userId', userId);
      print('[ProfileNotifier] 새 userId 생성 및 저장: $userId');
    }
    final jsonString = prefs.getString('profile');
    print('[ProfileNotifier] profile jsonString: $jsonString');
    if (jsonString != null) {
      final data = ProfileData.fromJson(json.decode(jsonString));
      print('[ProfileNotifier] ProfileData.fromJson: userId=${data.userId}, name=${data.name}, bio=${data.bio}, imagePath=${data.imagePath}');
      if (data.imagePath != null) {
        final file = File(data.imagePath!);
        if (!file.existsSync() || data.imagePath!.contains('/tmp/') || data.imagePath!.contains('/cache/')) {
          if (data.imageBase64 != null) {
            final appDir = await getApplicationDocumentsDirectory();
            final fileName = 'profile_${data.userId}_restored.jpg';
            final restoredPath = '${appDir.path}/$fileName';
            final restoredFile = File(restoredPath);
            await restoredFile.writeAsBytes(base64Decode(data.imageBase64!));
            data.imagePath = restoredPath;
          } else {
            data.imagePath = null;
          }
        }
      } else if (data.imageBase64 != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${data.userId}_restored.jpg';
        final restoredPath = '${appDir.path}/$fileName';
        final restoredFile = File(restoredPath);
        await restoredFile.writeAsBytes(base64Decode(data.imageBase64!));
        data.imagePath = restoredPath;
      }
      // userId 보정
      if (data.userId != userId) {
        print('[ProfileNotifier] userId 보정: 기존=${data.userId}, prefs=$userId');
        data.name = data.name;
        data.bio = data.bio;
        data.imagePath = data.imagePath;
        return ProfileData(userId: userId, name: data.name, bio: data.bio, imagePath: data.imagePath, imageBase64: data.imageBase64);
      }
      return data;
    }
    print('[ProfileNotifier] profile 데이터 없음, 새 ProfileData 생성');
    return ProfileData(userId: userId);
  }

  Future<void> saveProfile(ProfileData profile) async {
    print('[ProfileNotifier] saveProfile: userId=${profile.userId}, name=${profile.name}, bio=${profile.bio}, imagePath=${profile.imagePath}');
    state = const AsyncValue.loading();
    final prefs = await SharedPreferences.getInstance();
    String? imageBase64 = profile.imageBase64;
    if (profile.imagePath != null && File(profile.imagePath!).existsSync()) {
      final bytes = await File(profile.imagePath!).readAsBytes();
      imageBase64 = base64Encode(bytes);
    }
    final newProfile = ProfileData(
      userId: profile.userId,
      name: profile.name,
      bio: profile.bio,
      imagePath: profile.imagePath,
      imageBase64: imageBase64,
    );
    await prefs.setString('profile', json.encode(newProfile.toJson()));
    state = AsyncValue.data(newProfile);
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileData>(ProfileNotifier.new);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final posts = ref.watch(postsProvider);
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('프로필 정보를 불러올 수 없습니다.'))),
      data: (profile) {
        final myPosts = posts.where((post) => post.userId == profile.userId).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Flexible(
                      flex: 0,
                      child: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                            final appDir = await getApplicationDocumentsDirectory();
                            final timestamp = DateTime.now().millisecondsSinceEpoch;
                            final fileName = 'profile_${profile.userId}_$timestamp.jpg';
                            final savedPath = '${appDir.path}/$fileName';
                            final savedFile = await File(picked.path).copy(savedPath);
                            await ref.read(profileProvider.notifier).saveProfile(
                              ProfileData(
                                userId: profile.userId,
                        name: profile.name,
                        bio: profile.bio,
                                imagePath: savedFile.path,
                                imageBase64: null,
                              ),
                      );
                    }
                  },
                        child: (profile.imagePath != null && File(profile.imagePath!).existsSync())
                            ? CircleAvatar(
                                radius: 32,
                                backgroundImage: FileImage(File(profile.imagePath!)),
                              )
                            : CircleAvatar(
                    radius: 32,
                                child: const Icon(Icons.person, size: 36),
                              ),
                  ),
                ),
                const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 4),
                          Text(profile.bio, style: const TextStyle(color: Colors.grey, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 2),
                  ],
                      ),
                ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 80, maxWidth: 110),
                      child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                                userId: profile.userId,
                          name: profile.name,
                          bio: profile.bio,
                                imagePath: profile.imagePath,
                                imageBase64: profile.imageBase64,
                        ),
                      ),
                    );
                    if (result is ProfileData) {
                            await ref.read(profileProvider.notifier).saveProfile(result);
                    }
                  },
                        child: const Text('프로필 편집', overflow: TextOverflow.ellipsis),
                      ),
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
      },
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String bio;
  final String? imagePath;
  final String? imageBase64;
  const EditProfileScreen({super.key, required this.userId, required this.name, required this.bio, this.imagePath, this.imageBase64});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _imagePath;
  bool _bioCleared = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _bioController = TextEditingController(text: widget.bio);
    _imagePath = widget.imagePath;
    _bioCleared = false;
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
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_${widget.userId}_$timestamp.jpg';
      final savedPath = '${appDir.path}/$fileName';
      final savedFile = await File(picked.path).copy(savedPath);
      setState(() {
        _imagePath = savedFile.path;
      });
      // 프로필 즉시 저장
      final container = ProviderScope.containerOf(context, listen: false);
      final profileAsync = container.read(profileProvider);
      final profile = profileAsync is AsyncData<ProfileData> ? profileAsync.value : null;
      if (profile != null) {
        await container.read(profileProvider.notifier).saveProfile(
          ProfileData(
            userId: widget.userId,
            name: profile.name,
            bio: profile.bio,
            imagePath: savedFile.path,
            imageBase64: null,
          ),
        );
      }
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
                  backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null ? const Icon(Icons.person, size: 40) : null,
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
              onTap: () {
                if (!_bioCleared && _bioController.text == '나의 프로필 소개글') {
                  _bioController.clear();
                  _bioCleared = true;
                }
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, ProfileData(
                    userId: widget.userId,
                    name: _nameController.text.trim(),
                    bio: _bioController.text.trim(),
                    imagePath: _imagePath,
                    imageBase64: null,
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