import 'package:flutter/material.dart';
import '../models/post.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class PostItem extends StatefulWidget {
  final Post post;
  const PostItem({super.key, required this.post});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.post.videoUrl != null) {
      _videoController = VideoPlayerController.file(File(widget.post.videoUrl!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final initials = post.author.isNotEmpty ? post.author.characters.take(2).toList().join() : '?';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                post.authorImage != null
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: FileImage(File(post.authorImage!)),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[800],
                      child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (post.authorBio != null && post.authorBio!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(post.authorBio!, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ],
                      const SizedBox(height: 2),
                      Text(_formatTime(post.createdAt), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
                // ... (추후 옵션 버튼 등)
              ],
            ),
            const SizedBox(height: 14),
            Text(post.content, style: const TextStyle(fontSize: 15)),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.black,
                      insetPadding: const EdgeInsets.all(0),
                      child: Stack(
                        children: [
                          Center(
                            child: InteractiveViewer(
                              child: Image.file(
                                File(post.imageUrl!),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 64, color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 32,
                            right: 32,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 32),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(post.imageUrl!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.18 * 255).toInt()),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                    ),
                  ],
                ),
              ),
            ],
            if (post.videoUrl != null && _videoController != null && _videoController!.value.isInitialized) ...[
              const SizedBox(height: 14),
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
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _ActionIcon(icon: Icons.favorite_border, label: '좋아요'),
                    const SizedBox(width: 12),
                    _ActionIcon(icon: Icons.mode_comment_outlined, label: '댓글'),
                    const SizedBox(width: 12),
                    _ActionIcon(icon: Icons.repeat, label: '리포스트'),
                    const SizedBox(width: 12),
                    _ActionIcon(icon: Icons.share_outlined, label: '공유'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${time.year}.${time.month}.${time.day}';
  }
}

class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  const _ActionIcon({required this.icon, required this.label});

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails d) {
    _controller.reverse();
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails d) {
    _controller.forward();
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    _controller.forward();
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final color = _pressed ? Theme.of(context).colorScheme.primary : Colors.grey[400];
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        if (widget.label == '좋아요') {
          setState(() => _liked = !_liked);
        } else if (widget.label == '댓글') {
          showDialog(
            context: context,
            builder: (context) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text('댓글 작성'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: '댓글을 입력하세요'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('댓글: \'${controller.text}\'')),
                      );
                    },
                    child: const Text('등록'),
                  ),
                ],
              );
            },
          );
        } else if (widget.label == '리포스트') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('리포스트 되었습니다!')),
          );
        } else if (widget.label == '공유') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('공유'),
              content: const Text('공유 기능은 실제 배포 시 구현하세요!'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기'))],
            ),
          );
        }
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: _pressed ? Colors.grey.withAlpha((0.13 * 255).toInt()) : Colors.transparent,
          ),
          child: Icon(widget.icon, size: 28, color: color),
        ),
      ),
    );
  }
} 