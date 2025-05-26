import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/post.dart';
import '../widgets/post_item.dart';

class HomeScreen extends StatefulWidget {
  final List<Post> posts;
  const HomeScreen({Key? key, required this.posts}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _pageSize = 10;
  late final PagingController<int, Post> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = widget.posts.skip(pageKey).take(_pageSize).toList();
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.posts != widget.posts) {
      _pagingController.refresh();
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스쿨코리아 피드')),
      body: PagedListView<int, Post>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Post>(
          itemBuilder: (context, post, index) => PostItem(post: post),
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('게시글이 없습니다.')),
          firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
          firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('피드를 불러오지 못했습니다.')),
          newPageErrorIndicatorBuilder: (context) => const Center(child: Text('더 불러오지 못했습니다.')),
        ),
      ),
    );
  }
} 