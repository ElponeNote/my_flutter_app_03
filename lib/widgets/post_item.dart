import 'package:flutter/material.dart';
import '../models/post.dart';
import 'dart:io';

class PostItem extends StatelessWidget {
  final Post post;
  const PostItem({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initials = post.author.isNotEmpty ? post.author.characters.take(2).toList().join() : '?';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                CircleAvatar(
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
                        color: Colors.black.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Row(
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
      onTap: () {},
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: _pressed ? Colors.grey.withOpacity(0.13) : Colors.transparent,
          ),
          child: Icon(widget.icon, size: 28, color: color),
        ),
      ),
    );
  }
} 