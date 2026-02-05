import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../explore/providers/book_source_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/reading_progress.dart';
import '../../../../core/models/reader_settings.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String sourceId;
  final String bookId;
  final String chapterId;

  const ReaderPage({
    super.key,
    required this.sourceId,
    required this.bookId,
    required this.chapterId,
  });

  /// 是否为本地书籍
  bool get isLocalBook => sourceId == 'local';

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  bool _showControls = false;
  String _currentChapterId = '';
  int _currentChapterIndex = 0;
  String _currentChapterTitle = '';
  final ScrollController _scrollController = ScrollController();
  
  // 存储服务
  final _storage = StorageService.instance;

  // 阅读设置
  late double _fontSize;
  late double _lineHeight;
  late Color _backgroundColor;

  // 自动滚动
  bool _isAutoScrolling = false;
  double _autoScrollSpeed = 50.0; // 像素/秒，默认速度

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadProgress();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _loadSettings() {
    final settings = _storage.getSettings();
    _fontSize = settings.fontSize;
    _lineHeight = settings.lineHeight;
    _backgroundColor = Color(settings.backgroundColorValue);
  }

  void _loadProgress() {
    final progress = _storage.getProgress(widget.bookId);
    if (progress != null) {
      // 从保存的进度恢复
      _currentChapterId = progress.chapterId;
      _currentChapterIndex = progress.chapterIndex;
      _currentChapterTitle = progress.chapterTitle;
      // 恢复滚动位置
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && progress.scrollPosition > 0) {
          _scrollController.jumpTo(progress.scrollPosition);
        }
      });
    } else {
      // 使用传入的章节ID
      _currentChapterId = widget.chapterId;
    }
  }

  Future<void> _saveProgress() async {
    final progress = ReadingProgress(
      bookId: widget.bookId,
      sourceId: widget.sourceId,
      chapterId: _currentChapterId,
      chapterTitle: _currentChapterTitle,
      chapterIndex: _currentChapterIndex,
      scrollPosition: _scrollController.hasClients ? _scrollController.offset : 0,
      updatedAt: DateTime.now(),
    );
    await _storage.saveProgress(progress);
  }

  Future<void> _saveSettings() async {
    final settings = ReaderSettings(
      fontSize: _fontSize,
      lineHeight: _lineHeight,
      backgroundColorValue: _backgroundColor.toARGB32(),
    );
    await _storage.saveSettings(settings);
  }

  /// 开始自动滚动
  void _startAutoScroll() {
    if (_isAutoScrolling) return;
    setState(() => _isAutoScrolling = true);
    _autoScrollTick();
  }

  /// 停止自动滚动
  void _stopAutoScroll() {
    setState(() => _isAutoScrolling = false);
  }

  /// 切换自动滚动
  void _toggleAutoScroll() {
    if (_isAutoScrolling) {
      _stopAutoScroll();
    } else {
      _startAutoScroll();
    }
  }

  /// 自动滚动逻辑（每帧执行）
  void _autoScrollTick() {
    if (!_isAutoScrolling || !mounted) return;
    if (!_scrollController.hasClients) return;

    final currentPosition = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    if (currentPosition < maxScroll) {
      // 每 16ms（约 60fps）滚动一小段距离
      final scrollAmount = _autoScrollSpeed / 60;
      _scrollController.jumpTo(currentPosition + scrollAmount);
      
      // 继续下一帧
      Future.delayed(const Duration(milliseconds: 16), _autoScrollTick);
    } else {
      // 到达底部，停止滚动
      _stopAutoScroll();
    }
  }

  @override
  void dispose() {
    _stopAutoScroll(); // 停止自动滚动
    _saveProgress(); // 退出时保存进度
    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根据是否为本地书籍选择不同的 Provider
    final contentAsync = widget.isLocalBook
        ? ref.watch(localChapterContentProvider(_currentChapterId))
        : ref.watch(chapterContentProvider((
            sourceId: widget.sourceId,
            bookId: widget.bookId,
            chapterId: _currentChapterId,
          )));
    
    final chaptersAsync = widget.isLocalBook
        ? ref.watch(localChapterListProvider)
        : ref.watch(chapterListProvider((
            sourceId: widget.sourceId,
            bookId: widget.bookId,
          )));

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          children: [
            contentAsync.when(
              data: (content) {
                // 更新当前章节标题
                _currentChapterTitle = content.title;
                return _buildReaderContent(content.title, content.content);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text('加载失败: $e'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.isLocalBook) {
                          ref.invalidate(localChapterContentProvider(_currentChapterId));
                        } else {
                          ref.invalidate(chapterContentProvider((
                            sourceId: widget.sourceId,
                            bookId: widget.bookId,
                            chapterId: _currentChapterId,
                          )));
                        }
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),

            if (_showControls)
              _buildTopBar(contentAsync.valueOrNull?.title ?? '加载中...'),

            if (_showControls)
              _buildBottomBar(chaptersAsync.valueOrNull ?? []),
          ],
        ),
      ),
    );
  }

  Widget _buildReaderContent(String title, String content) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: _fontSize + 4,
              fontWeight: FontWeight.bold,
              color: _backgroundColor == const Color(0xFF1C1C1E)
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            content,
            style: TextStyle(
              fontSize: _fontSize,
              height: _lineHeight,
              color: _backgroundColor == const Color(0xFF1C1C1E)
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(String title) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xFF2C2C2C), // 不透明深色背景
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  _saveProgress();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已添加书签')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(List chapters) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xFF2C2C2C), // 不透明深色背景
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 自动阅读速度滑块（仅在自动阅读开启时显示）
                if (_isAutoScrolling)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        const Text('速度', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Expanded(
                          child: Slider(
                            value: _autoScrollSpeed,
                            min: 10,
                            max: 200,
                            divisions: 19,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white24,
                            label: '${_autoScrollSpeed.toInt()}',
                            onChanged: (value) {
                              setState(() => _autoScrollSpeed = value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomButton(Icons.skip_previous, '上一章', () {
                      _navigateChapter(chapters, -1);
                    }),
                    _buildBottomButton(Icons.list, '目录', () {
                      _showChapterList(chapters);
                    }),
                    _buildBottomButton(
                      _isAutoScrolling ? Icons.pause_circle : Icons.play_circle,
                      _isAutoScrolling ? '停止' : '自动',
                      _toggleAutoScroll,
                    ),
                    _buildBottomButton(Icons.text_fields, '字体', () {
                      _showFontSettings();
                    }),
                    _buildBottomButton(Icons.skip_next, '下一章', () {
                      _navigateChapter(chapters, 1);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateChapter(List chapters, int direction) {
    if (chapters.isEmpty) return;

    final currentIndex = chapters.indexWhere((c) => c.id == _currentChapterId);
    final newIndex = currentIndex + direction;

    if (newIndex >= 0 && newIndex < chapters.length) {
      _saveProgress(); // 切换章节前保存进度
      setState(() {
        _currentChapterId = chapters[newIndex].id;
        _currentChapterIndex = newIndex;
        _currentChapterTitle = chapters[newIndex].title;
      });
      // 切换章节后滚动到顶部
      _scrollController.jumpTo(0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(direction > 0 ? '已是最后一章' : '已是第一章')),
      );
    }
  }

  Widget _buildBottomButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _handleTap() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _showChapterList(List chapters) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('目录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('共 ${chapters.length} 章', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  final isCurrentChapter = chapter.id == _currentChapterId;
                  return ListTile(
                    title: Text(
                      chapter.title,
                      style: TextStyle(
                        color: isCurrentChapter
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _saveProgress();
                      setState(() {
                        _currentChapterId = chapter.id;
                        _currentChapterIndex = index;
                        _currentChapterTitle = chapter.title;
                      });
                      _scrollController.jumpTo(0);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('字体大小', style: TextStyle(fontWeight: FontWeight.w600)),
              Slider(
                value: _fontSize,
                min: 12,
                max: 32,
                divisions: 20,
                label: _fontSize.toInt().toString(),
                onChanged: (value) {
                  setModalState(() => _fontSize = value);
                  setState(() {});
                },
                onChangeEnd: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),
              const Text('行间距', style: TextStyle(fontWeight: FontWeight.w600)),
              Slider(
                value: _lineHeight,
                min: 1.2,
                max: 2.5,
                divisions: 13,
                label: _lineHeight.toStringAsFixed(1),
                onChanged: (value) {
                  setModalState(() => _lineHeight = value);
                  setState(() {});
                },
                onChangeEnd: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),
              const Text('背景颜色', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildColorOption(Colors.white, '白色', setModalState),
                  _buildColorOption(const Color(0xFFF5F0E1), '护眼', setModalState),
                  _buildColorOption(const Color(0xFFCCE8CF), '绿色', setModalState),
                  _buildColorOption(const Color(0xFF1C1C1E), '夜间', setModalState),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, String label, StateSetter setModalState) {
    final isSelected = _backgroundColor == color;
    return GestureDetector(
      onTap: () {
        setModalState(() => _backgroundColor = color);
        setState(() {});
        _saveSettings();
      },
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
