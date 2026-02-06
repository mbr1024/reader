import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// 书签管理页面
class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;
  String? _selectedBookId;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    // 模拟加载书签数据
    // 实际应从本地存储或API获取
    setState(() {
      _bookmarks = [
        {
          'id': '1',
          'bookId': 'book1',
          'bookTitle': '斗破苍穹',
          'chapterIndex': 100,
          'chapterTitle': '第一百章 炼药',
          'position': 1500,
          'content': '萧炎看着手中的丹药，嘴角微微上扬...',
          'note': '精彩的炼药场景',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': '2',
          'bookId': 'book1',
          'bookTitle': '斗破苍穹',
          'chapterIndex': 150,
          'chapterTitle': '第一百五十章 对决',
          'position': 2000,
          'content': '一道青色火焰从萧炎手中升起...',
          'note': '',
          'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        },
        {
          'id': '3',
          'bookId': 'book2',
          'bookTitle': '完美世界',
          'chapterIndex': 50,
          'chapterTitle': '第五十章 蛮荒',
          'position': 800,
          'content': '石昊望着远方的群山，心中充满期待...',
          'note': '开始冒险',
          'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
      ];
      _isLoading = false;
    });
  }

  // 按书籍分组
  Map<String, List<Map<String, dynamic>>> get _groupedBookmarks {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final bookmark in _bookmarks) {
      final bookId = bookmark['bookId'] as String;
      grouped.putIfAbsent(bookId, () => []);
      grouped[bookId]!.add(bookmark);
    }
    return grouped;
  }

  void _editNote(Map<String, dynamic> bookmark) {
    final controller = TextEditingController(text: bookmark['note'] ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('编辑备注'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '添加备注...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _bookmarks.indexWhere((b) => b['id'] == bookmark['id']);
                if (index != -1) {
                  _bookmarks[index]['note'] = controller.text;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('备注已更新'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final time = DateTime.tryParse(isoString);
    if (time == null) return '';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${time.month}月${time.day}日';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('我的书签'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? _buildEmptyState()
              : _buildBookmarkList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 80,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无书签',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '阅读时长按可添加书签',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkList() {
    final grouped = _groupedBookmarks;
    final bookIds = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bookIds.length,
      itemBuilder: (context, index) {
        final bookId = bookIds[index];
        final bookmarks = grouped[bookId]!;
        final bookTitle = bookmarks.first['bookTitle'] as String;

        return _buildBookSection(bookId, bookTitle, bookmarks);
      },
    );
  }

  Widget _buildBookSection(String bookId, String title, List<Map<String, dynamic>> bookmarks) {
    final isExpanded = _selectedBookId == null || _selectedBookId == bookId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 书籍标题
        InkWell(
          onTap: () {
            setState(() {
              _selectedBookId = _selectedBookId == bookId ? null : bookId;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${bookmarks.length}个书签',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // 书签列表
        if (isExpanded)
          ...bookmarks.map((bookmark) => _buildBookmarkItem(bookmark)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBookmarkItem(Map<String, dynamic> bookmark) {
    return Dismissible(
      key: Key(bookmark['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        setState(() {
          _bookmarks.removeWhere((b) => b['id'] == bookmark['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('书签已删除'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      child: InkWell(
        onTap: () {
          // 跳转到阅读页面对应位置
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('跳转到: ${bookmark['chapterTitle']}'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
        onLongPress: () => _editNote(bookmark),
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              left: BorderSide(color: AppColors.divider, width: 2),
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bookmark, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bookmark['chapterTitle'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(bookmark['createdAt']),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              if (bookmark['content'] != null && (bookmark['content'] as String).isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    bookmark['content'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (bookmark['note'] != null && (bookmark['note'] as String).isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.note, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bookmark['note'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
