import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// 离线下载管理页面
class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _downloads = [];
  List<Map<String, dynamic>> _completed = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDownloads();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDownloads() {
    // 模拟加载下载数据
    setState(() {
      _downloads = [
        {
          'bookId': 'book1',
          'title': '斗破苍穹',
          'author': '天蚕土豆',
          'totalChapters': 1500,
          'downloadedChapters': 750,
          'status': 'downloading', // downloading, paused, waiting
          'speed': '128 KB/s',
        },
        {
          'bookId': 'book2',
          'title': '完美世界',
          'author': '辰东',
          'totalChapters': 2000,
          'downloadedChapters': 500,
          'status': 'paused',
          'speed': '',
        },
      ];
      _completed = [
        {
          'bookId': 'book3',
          'title': '遮天',
          'author': '辰东',
          'totalChapters': 1800,
          'downloadedChapters': 1800,
          'size': '256 MB',
          'completedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        },
      ];
      _isLoading = false;
    });
  }

  void _toggleDownload(Map<String, dynamic> item) {
    setState(() {
      final index = _downloads.indexWhere((d) => d['bookId'] == item['bookId']);
      if (index != -1) {
        if (_downloads[index]['status'] == 'downloading') {
          _downloads[index]['status'] = 'paused';
          _downloads[index]['speed'] = '';
        } else {
          _downloads[index]['status'] = 'downloading';
          _downloads[index]['speed'] = '128 KB/s';
        }
      }
    });
  }

  void _cancelDownload(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('取消下载'),
        content: Text('确定要取消下载《${item['title']}》吗？已下载的内容将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('保留', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _downloads.removeWhere((d) => d['bookId'] == item['bookId']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已取消下载'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _deleteCompleted(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('删除下载'),
        content: Text('确定要删除《${item['title']}》的离线内容吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _completed.removeWhere((d) => d['bookId'] == item['bookId']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已删除离线内容'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('离线下载'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: '下载中 (${_downloads.length})'),
            Tab(text: '已完成 (${_completed.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDownloadingTab(),
                _buildCompletedTab(),
              ],
            ),
    );
  }

  Widget _buildDownloadingTab() {
    if (_downloads.isEmpty) {
      return _buildEmptyState(
        icon: Icons.download_outlined,
        title: '暂无下载任务',
        subtitle: '在书籍详情页点击下载即可离线阅读',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _downloads.length,
      itemBuilder: (context, index) {
        return _buildDownloadItem(_downloads[index]);
      },
    );
  }

  Widget _buildCompletedTab() {
    if (_completed.isEmpty) {
      return _buildEmptyState(
        icon: Icons.download_done,
        title: '暂无已完成下载',
        subtitle: '下载完成的书籍会显示在这里',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _completed.length,
      itemBuilder: (context, index) {
        return _buildCompletedItem(_completed[index]);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(Map<String, dynamic> item) {
    final progress = item['downloadedChapters'] / item['totalChapters'];
    final isDownloading = item['status'] == 'downloading';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['author'],
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              // 操作按钮
              IconButton(
                icon: Icon(
                  isDownloading ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  color: AppColors.primary,
                ),
                onPressed: () => _toggleDownload(item),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                onPressed: () => _cancelDownload(item),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDownloading ? AppColors.primary : AppColors.textMuted,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item['downloadedChapters']}/${item['totalChapters']}章',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              if (isDownloading && item['speed'].isNotEmpty)
                Text(
                  item['speed'],
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                )
              else
                Text(
                  item['status'] == 'paused' ? '已暂停' : '等待中',
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['totalChapters']}章 · ${item['size']}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
            onPressed: () => _deleteCompleted(item),
          ),
        ],
      ),
    );
  }
}
