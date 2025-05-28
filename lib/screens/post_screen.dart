import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/post.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/profile_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class PostScreen extends ConsumerStatefulWidget {
  final void Function(Post post) onPost;
  const PostScreen({super.key, required this.onPost});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isPosting = false;
  File? _imageFile;
  File? _videoFile;
  VideoPlayerController? _videoController;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _videoFile = null;
        _videoController?.dispose();
        _videoController = null;
      });
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: source);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _imageFile = null;
        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController?.setLooping(true);
          });
      });
    }
  }

  void _handlePost() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력하세요.')),
      );
      _focusNode.requestFocus();
      return;
    }
    setState(() => _isPosting = true);
    final profileAsync = ref.read(profileProvider);
    final profile = profileAsync.value;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 정보를 불러올 수 없습니다.')),
      );
      setState(() => _isPosting = false);
      return;
    }
    String? imagePath;
    String? imageBase64;
    if (_imageFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'post_${profile.userId}_$timestamp.jpg';
      final savedPath = '${appDir.path}/$fileName';
      final savedFile = await _imageFile!.copy(savedPath);
      imagePath = savedFile.path;
      final bytes = await savedFile.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }
    String? authorImageBase64 = profile.imageBase64;
    if (profile.imagePath != null && File(profile.imagePath!).existsSync()) {
      final bytes = await File(profile.imagePath!).readAsBytes();
      authorImageBase64 = base64Encode(bytes);
    }
    String? videoPath;
    if (_videoFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'post_${profile.userId}_$timestamp.mp4';
      final savedPath = '${appDir.path}/$fileName';
      final savedFile = await _videoFile!.copy(savedPath);
      videoPath = savedFile.path;
    }
    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: profile.userId,
      author: profile.name,
      content: text,
      imageUrl: imagePath,
      imageBase64: imageBase64,
      videoUrl: videoPath,
      authorImage: profile.imagePath,
      authorImageBase64: authorImageBase64,
      authorBio: profile.bio,
      createdAt: DateTime.now(),
    );
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onPost(post);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 업로드되었습니다.')),
      );
      setState(() {
        _isPosting = false;
        _controller.clear();
        _imageFile = null;
        _videoFile = null;
        _videoController?.dispose();
        _videoController = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포스팅')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 5,
                style: const TextStyle(fontFamily: 'Apple SD Gothic Neo'),
                decoration: const InputDecoration(
                  hintText: '무엇을 생각하고 계신가요?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text('갤러리'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('카메라'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _pickVideo(ImageSource.gallery),
                    icon: const Icon(Icons.videocam),
                    label: const Text('영상 업로드'),
                  ),
                ],
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ],
              if (_videoFile != null && _videoController != null && _videoController!.value.isInitialized) ...[
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_videoController!),
                      VideoProgressIndicator(_videoController!, allowScrubbing: true),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.black54,
                          onPressed: () {
                            setState(() {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                              } else {
                                _videoController!.play();
                              }
                            });
                          },
                          child: Icon(_videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _handlePost,
                  child: _isPosting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('업로드'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 