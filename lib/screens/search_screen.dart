import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../utils/dummy_data.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  bool _isLoading = false;
  String? _error;

  void _onSearch(String value) async {
    setState(() {
      _query = value.trim();
      _isLoading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 300)); // UX용 딜레이
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    final results = _query.isEmpty
        ? []
        : posts.where((post) =>
            post.content.contains(_query) || post.author.contains(_query)).toList();
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('검색')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: '게시글, 작성자 검색',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearch,
            ),
            const SizedBox(height: 16),
            if (_query.isNotEmpty)
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : results.isEmpty
                            ? const Center(child: Text('검색 결과가 없습니다.'))
                            : ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (context, idx) {
                                  final post = results[idx];
                                  return ListTile(
                                    title: Text(post.content),
                                    subtitle: Text('${post.author} · ${dateFormat.format(post.createdAt)}'),
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