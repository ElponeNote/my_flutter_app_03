import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/post.dart';
import '../widgets/post_item.dart';
import '../widgets/skeleton_post_item.dart';
import '../utils/dummy_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _pageSize = 3;
  late final PagingController<int, Post> _pagingController;
  List<Post> _lastPosts = [];

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchPage);
  }

  void _fetchPage(int pageKey) {
    final posts = ref.read(postsProvider);
    final newItems = posts.skip(pageKey).take(_pageSize).toList();
    final isLastPage = pageKey + newItems.length >= posts.length;
    if (isLastPage) {
      // 더미 게시글 추가 없이 마지막 페이지 처리
      _pagingController.appendLastPage(newItems);
    } else {
      final nextPageKey = pageKey + newItems.length;
      _pagingController.appendPage(newItems, nextPageKey);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 최초 렌더링 시 postsProvider를 저장
    _lastPosts = ref.read(postsProvider);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯 갱신 시 새로고침
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    // postsProvider가 변경되면 피드 새로고침
    if (_lastPosts != posts) {
      _lastPosts = posts;
      _pagingController.refresh();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('스쿨코리아'),
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _pagingController.refresh();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: PagedListView<int, Post>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, post, index) => PostItem(post: post),
            noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('게시글이 없습니다.')),
            firstPageProgressIndicatorBuilder: (context) =>
              Column(
                children: List.generate(3, (_) => const SkeletonPostItem()),
              ),
            newPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
            firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('피드를 불러오지 못했습니다.')),
            newPageErrorIndicatorBuilder: (context) => const Center(child: Text('더 불러오지 못했습니다.')),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
} 