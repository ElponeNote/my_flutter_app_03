import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/post.dart';

class PostScreen extends StatefulWidget {
  final void Function(Post post) onPost;
  const PostScreen({Key? key, required this.onPost}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _handlePost() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력하세요.')),
      );
      return;
    }
    setState(() => _isPosting = true);
    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: 'Me',
      content: text,
      imageUrl: _imageFile?.path,
      createdAt: DateTime.now(),
    );
    await Future.delayed(const Duration(milliseconds: 600)); // UX용 딜레이
    widget.onPost(post);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 업로드되었습니다.')),
      );
      setState(() {
        _isPosting = false;
        _controller.clear();
        _imageFile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포스팅')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '무엇을 생각하고 계신가요?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
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
              ],
            ),
            if (_imageFile != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: Image.file(_imageFile!, fit: BoxFit.cover),
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
    );
  }
} 