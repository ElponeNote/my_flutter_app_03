import 'package:flutter/material.dart';
import '../models/post.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/dummy_data.dart';
import 'package:intl/intl.dart';
import '../screens/profile_screen.dart';
import 'dart:convert';

class PostItem extends ConsumerStatefulWidget {
  final Post post;
  const PostItem({super.key, required this.post});

  @override
  ConsumerState<PostItem> createState() => _PostItemState();
}

class _PostItemState extends ConsumerState<PostItem> {
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

  void _toggleLike() async {
    final posts = ref.read(postsProvider);
    final idx = posts.indexWhere((p) => p.id == widget.post.id);
    if (idx == -1) return;
    final post = posts[idx];
    final updated = Post(
      id: post.id,
      userId: post.userId,
      author: post.author,
      content: post.content,
      imageUrl: post.imageUrl,
      videoUrl: post.videoUrl,
      authorImage: post.authorImage,
      authorBio: post.authorBio,
      createdAt: post.createdAt,
      likes: post.likedByMe ? post.likes - 1 : post.likes + 1,
      likedByMe: !post.likedByMe,
      comments: post.comments,
    );
    final updatedPosts = [...posts];
    updatedPosts[idx] = updated;
    await ref.read(postsProvider.notifier).setPosts(updatedPosts);
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    final post = posts.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post);
    final initials = post.author.isNotEmpty ? post.author.characters.take(2).toList().join() : '?';
    final commentCount = post.comments.length;
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
                _buildAuthorAvatar(post, initials),
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
                              child: post.imageUrl!.startsWith('http')
                                  ? Image.network(
                                      post.imageUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 64, color: Colors.white),
                                    )
                                  : (File(post.imageUrl!).existsSync()
                                      ? Image.file(
                                File(post.imageUrl!),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 64, color: Colors.white),
                                        )
                                      : const Icon(Icons.broken_image, size: 64, color: Colors.white)),
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
                      child: post.imageUrl!.startsWith('http')
                          ? Image.network(
                              post.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
                            )
                          : (File(post.imageUrl!).existsSync()
                              ? Image.file(
                        File(post.imageUrl!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
                                )
                              : const Icon(Icons.broken_image, size: 48)),
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
                    _LikeButton(
                      liked: post.likedByMe,
                      count: post.likes,
                      onTap: _toggleLike,
                    ),
                    const SizedBox(width: 12),
                    _CommentButton(
                      count: commentCount,
                      onTap: () => _showCommentsModal(context, post),
                    ),
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

  Widget _buildAuthorAvatar(Post post, String initials) {
    if (post.authorImage != null && File(post.authorImage!).existsSync()) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: FileImage(File(post.authorImage!)),
      );
    } else if (post.authorImageBase64 != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: MemoryImage(base64Decode(post.authorImageBase64!)),
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[800],
        child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${time.year}.${time.month}.${time.day}';
  }

  void _showCommentsModal(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final controller = TextEditingController();
        final profile = ref.read(profileProvider).value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.mode_comment_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('댓글', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: post.comments.isEmpty
                    ? const Center(child: Text('아직 댓글이 없습니다.', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        reverse: true,
                        itemCount: post.comments.length,
                        itemBuilder: (context, idx) {
                          final comment = post.comments[post.comments.length - 1 - idx];
                          final isMine = profile != null && comment.author == profile.name;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isMine ? Colors.blueGrey[800] : Colors.grey[850],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (comment.authorImage != null && File(comment.authorImage!).existsSync())
                                  CircleAvatar(radius: 14, backgroundImage: FileImage(File(comment.authorImage!)))
                                else
                                  const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                          const SizedBox(width: 8),
                                          Text(DateFormat('MM.dd HH:mm').format(comment.createdAt), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(comment.content, style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (value) => _addComment(post, controller, context, profile),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () => _addComment(post, controller, context, profile),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _addComment(Post post, TextEditingController controller, BuildContext context, ProfileData? profile) async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final posts = ref.read(postsProvider);
    final idx = posts.indexWhere((p) => p.id == post.id);
    if (idx == -1) return;
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: profile?.name ?? '익명',
      content: text,
      createdAt: DateTime.now(),
      authorImage: profile?.imagePath,
    );
    final updated = Post(
      id: post.id,
      userId: post.userId,
      author: post.author,
      content: post.content,
      imageUrl: post.imageUrl,
      videoUrl: post.videoUrl,
      authorImage: post.authorImage,
      authorBio: post.authorBio,
      createdAt: post.createdAt,
      likes: post.likes,
      likedByMe: post.likedByMe,
      comments: [...post.comments, newComment],
    );
    final updatedPosts = [...posts];
    updatedPosts[idx] = updated;
    await ref.read(postsProvider.notifier).setPosts(updatedPosts);
    if (!context.mounted) return;
    controller.clear();
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
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

class _LikeButton extends StatefulWidget {
  final bool liked;
  final int count;
  final VoidCallback onTap;
  const _LikeButton({required this.liked, required this.count, required this.onTap});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.8,
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

  void _animate() {
    _controller.reverse().then((_) => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _animate();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Row(
          children: [
            Icon(
              widget.liked ? Icons.favorite : Icons.favorite_border,
              color: widget.liked ? Colors.redAccent : Colors.grey[400],
              size: 28,
            ),
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Text(
                '${widget.count}',
                key: ValueKey(widget.count),
                style: TextStyle(
                  color: widget.liked ? Colors.redAccent : Colors.grey[400],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _CommentButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.mode_comment_outlined, color: Colors.grey, size: 28),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Text(
              '$count',
              key: ValueKey(count),
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
} 