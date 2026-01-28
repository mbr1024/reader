import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookshelfPage extends StatelessWidget {
  const BookshelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.go('/explore');
            },
          ),
        ],
      ),
      body: _buildBookshelfContent(context),
    );
  }

  Widget _buildBookshelfContent(BuildContext context) {
    // 示例数据
    final books = [
      {'title': '斗破苍穹', 'author': '天蚕土豆', 'progress': '第100章'},
      {'title': '完美世界', 'author': '辰东', 'progress': '第50章'},
      {'title': '遮天', 'author': '辰东', 'progress': '第200章'},
    ];

    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '书架空空如也',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.go('/explore');
              },
              child: const Text('去发现好书'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _BookCard(
          title: book['title']!,
          author: book['author']!,
          progress: book['progress']!,
          onTap: () {
            context.push('/reader/book_$index');
          },
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String progress;
  final VoidCallback onTap;

  const _BookCard({
    required this.title,
    required this.author,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面占位
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.book,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            progress,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
