import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../explore/providers/book_source_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/reading_progress.dart';
import '../../../../core/models/reader_settings.dart';
import '../../../../core/models/book_models.dart';
import '../../../../shared/utils/toast.dart';

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

  bool get isLocalBook => sourceId == 'local';

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  bool _showControls = false;
  final ScrollController _scrollController = ScrollController();
  final _storage = StorageService.instance;

  List<ChapterInfo> _chapters = [];
  int _currentChapterIndex = 0;

  // 当前章节 = _anchorIndex，它是 center 的锚点
  // 向下（正方向）：_anchorIndex, _anchorIndex+1, ..., _lastIndex
  // 向上（负方向）：_anchorIndex-1, _anchorIndex-2, ..., _firstIndex
  int _anchorIndex = 0;
  int _firstIndex = 0;  // 最上面已加载的章节
  int _lastIndex = 0;   // 最下面已加载的章节

  // center key — CustomScrollView 用这个 key 定位锚点 sliver
  final GlobalKey _centerKey = GlobalKey();

  // 每个章节的 GlobalKey，用于位置检测
  final Map<int, GlobalKey> _itemKeys = {};

  // 阅读设置
  late double _fontSize;
  late double _lineHeight;
  late Color _backgroundColor;

  // 自动滚动
  bool _isAutoScrolling = false;
  double _autoScrollSpeed = 50.0;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final s = _storage.getSettings();
    _fontSize = s.fontSize;
    _lineHeight = s.lineHeight;
    _backgroundColor = Color(s.backgroundColorValue);
    _scrollController.addListener(_onScroll);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _isAutoScrolling = false;
    _scrollController.removeListener(_onScroll);
    _saveProgress();
    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _init(List<ChapterInfo> chapters) {
    if (_initialized) return;
    _initialized = true;
    _chapters = chapters;

    int idx = chapters.indexWhere((c) => c.id == widget.chapterId);
    if (idx < 0) idx = 0;

    final progress = _storage.getProgress(widget.bookId);
    if (progress != null && progress.chapterIndex < chapters.length) {
      idx = progress.chapterIndex;
    }

    _currentChapterIndex = idx;
    _anchorIndex = idx;
    _firstIndex = idx;
    _lastIndex = idx;

    if (progress != null && progress.scrollPosition > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(progress.scrollPosition.clamp(
              0.0, _scrollController.position.maxScrollExtent));
        }
      });
    }
  }

  // ===== 滚动 =====

  void _onScroll() {
    if (!_scrollController.hasClients || _chapters.isEmpty) return;
    final pos = _scrollController.position;

    // 接近正方向底部 → 追加下一章
    if (pos.pixels >= pos.maxScrollExtent - 800) {
      if (_lastIndex < _chapters.length - 1) {
        setState(() => _lastIndex++);
      }
    }

    // 接近负方向顶部 → 向上追加上一章（无需补偿！）
    if (pos.pixels <= pos.minScrollExtent + 800) {
      if (_firstIndex > 0) {
        setState(() => _firstIndex--);
      }
    }

    _detectCurrentChapter();
  }

  void _detectCurrentChapter() {
    int detected = _currentChapterIndex;
    for (int i = _firstIndex; i <= _lastIndex; i++) {
      final key = _itemKeys[i];
      if (key == null || key.currentContext == null) continue;
      final box = key.currentContext!.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      if (box.localToGlobal(Offset.zero).dy <= 80) {
        detected = i;
      }
    }
    if (detected != _currentChapterIndex) {
      setState(() => _currentChapterIndex = detected);
      _saveProgress();
    }
  }

  // ===== 章节跳转 =====

  void _jumpToChapter(int index) {
    if (index < 0 || index >= _chapters.length) {
      Toast.show(context, index < 0 ? '已是第一章' : '已是最后一章');
      return;
    }
    _saveProgress();
    _isAutoScrolling = false;

    // 如果目标在当前范围内，直接滚过去
    if (index >= _firstIndex && index <= _lastIndex) {
      final key = _itemKeys[index];
      if (key?.currentContext != null) {
        setState(() { _currentChapterIndex = index; _showControls = false; });
        Scrollable.ensureVisible(key!.currentContext!,
            duration: const Duration(milliseconds: 300));
        return;
      }
    }

    // 否则重置，以目标章为新锚点
    _itemKeys.clear();
    setState(() {
      _currentChapterIndex = index;
      _anchorIndex = index;
      _firstIndex = index;
      _lastIndex = index;
      _showControls = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  // ===== 进度 =====

  void _saveProgress() {
    if (_chapters.isEmpty) return;
    final idx = _currentChapterIndex.clamp(0, _chapters.length - 1);
    _storage.saveProgress(ReadingProgress(
      bookId: widget.bookId,
      sourceId: widget.sourceId,
      chapterId: _chapters[idx].id,
      chapterTitle: _chapters[idx].title,
      chapterIndex: idx,
      scrollPosition: _scrollController.hasClients ? _scrollController.offset : 0,
      updatedAt: DateTime.now(),
    )).catchError((e) => debugPrint('保存进度失败: $e'));
  }

  Future<void> _saveSettings() async {
    await _storage.saveSettings(ReaderSettings(
      fontSize: _fontSize, lineHeight: _lineHeight,
      backgroundColorValue: _backgroundColor.toARGB32(),
    ));
  }

  // ===== 自动滚动 =====

  void _toggleAutoScroll() {
    setState(() => _isAutoScrolling = !_isAutoScrolling);
    if (_isAutoScrolling) _autoScrollTick();
  }

  void _autoScrollTick() {
    if (!_isAutoScrolling || !mounted || !_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.offset + _autoScrollSpeed / 60);
    Future.delayed(const Duration(milliseconds: 16), _autoScrollTick);
  }

  // ===== 构建 =====

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chapterListProvider((
        sourceId: widget.sourceId, bookId: widget.bookId)));

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: chaptersAsync.when(
        data: (chapters) {
          _init(chapters);
          _chapters = chapters;
          final textColor = _backgroundColor == const Color(0xFF1C1C1E)
              ? Colors.white70 : Colors.black87;

          // 上方章节（锚点上方，反序排列，往负方向增长）
          final upCount = _anchorIndex - _firstIndex; // 锚点上方有多少章
          // 下方章节（包含锚点自身）
          final downCount = _lastIndex - _anchorIndex + 1;

          return GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SafeArea(
                  child: CustomScrollView(
                    controller: _scrollController,
                    center: _centerKey,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // === 上方内容（负方向，反序）===
                      if (upCount > 0)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              // i=0 是离锚点最近的，i=upCount-1 是最远的
                              final chapterIdx = _anchorIndex - 1 - i;
                              return _buildChapterItem(chapterIdx, textColor);
                            },
                            childCount: upCount,
                          ),
                        ),
                      // === 锚点 + 下方内容（正方向）===
                      SliverList(
                        key: _centerKey,
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final chapterIdx = _anchorIndex + i;
                            return _buildChapterItem(chapterIdx, textColor);
                          },
                          childCount: downCount,
                        ),
                      ),
                      // 底部提示
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(child: Text(
                            _lastIndex >= _chapters.length - 1
                                ? '— 已是最后一章 —' : '上拉加载更多',
                            style: TextStyle(color: textColor.withValues(alpha: 0.4), fontSize: 13),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showControls) _buildTopBar(),
                if (_showControls) _buildBottomBar(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('加载失败: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(chapterListProvider((
                    sourceId: widget.sourceId, bookId: widget.bookId)));
              },
              child: const Text('重试'),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildChapterItem(int chapterIdx, Color textColor) {
    _itemKeys.putIfAbsent(chapterIdx, () => GlobalKey());
    return _ChapterWidget(
      key: _itemKeys[chapterIdx],
      chapter: _chapters[chapterIdx],
      sourceId: widget.sourceId,
      bookId: widget.bookId,
      fontSize: _fontSize,
      lineHeight: _lineHeight,
      textColor: textColor,
    );
  }

  // ===== 控制栏 =====

  Widget _buildTopBar() {
    final title = _chapters.isNotEmpty
        ? _chapters[_currentChapterIndex.clamp(0, _chapters.length - 1)].title
        : '';
    return Positioned(
      top: 0, left: 0, right: 0,
      child: GestureDetector(
        onTap: () {}, // 吞掉点击，不穿透到下层关闭控制栏
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: const Color(0xFF2C2C2C),
          child: SafeArea(bottom: false, child: Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () { _saveProgress(); Navigator.pop(context); }),
            Expanded(child: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
            IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.white),
              onPressed: () => Toast.show(context, '已添加书签')),
          ])),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: const Color(0xFF2C2C2C),
          child: SafeArea(top: false, child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${_currentChapterIndex + 1} / ${_chapters.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(width: 8),
                SizedBox(height: 2, width: 100, child: LinearProgressIndicator(
                  value: _chapters.isNotEmpty ? (_currentChapterIndex + 1) / _chapters.length : 0,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                )),
              ]),
            ),
            if (_isAutoScrolling)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  const Icon(Icons.speed, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  const Text('速度', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Expanded(child: Slider(
                    value: _autoScrollSpeed, min: 10, max: 200, divisions: 19,
                    activeColor: Colors.white, inactiveColor: Colors.white24,
                    label: '${_autoScrollSpeed.toInt()}',
                    onChanged: (v) => setState(() => _autoScrollSpeed = v),
                  )),
                ]),
              ),
            Row(children: [
              _btn(Icons.skip_previous, '上一章', () => _jumpToChapter(_currentChapterIndex - 1)),
              _btn(Icons.list, '目录', _showChapterList),
              _btn(_isAutoScrolling ? Icons.pause_circle : Icons.play_circle,
                  _isAutoScrolling ? '停止' : '自动', _toggleAutoScroll),
              _btn(Icons.settings, '设置', _showSettings),
              _btn(Icons.skip_next, '下一章', () => _jumpToChapter(_currentChapterIndex + 1)),
            ]),
          ]),
        )),
      )),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  // ===== 目录 =====

  void _showChapterList() {
    showModalBottomSheet(context: context, builder: (ctx) => Container(
      height: MediaQuery.of(ctx).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('目录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('共 ${_chapters.length} 章', style: TextStyle(color: Colors.grey[600])),
        ]),
        const SizedBox(height: 16),
        Expanded(child: ListView.builder(
          itemCount: _chapters.length,
          itemBuilder: (ctx, i) {
            final cur = i == _currentChapterIndex;
            return ListTile(
              title: Text(_chapters[i].title, style: TextStyle(
                color: cur ? Theme.of(ctx).colorScheme.primary : null,
                fontWeight: cur ? FontWeight.bold : FontWeight.normal)),
              trailing: cur ? Icon(Icons.book, color: Theme.of(ctx).colorScheme.primary, size: 20) : null,
              onTap: () { Navigator.pop(ctx); _jumpToChapter(i); },
            );
          },
        )),
      ]),
    ));
  }

  // ===== 设置 =====

  void _showSettings() {
    showModalBottomSheet(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModal) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('阅读设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('字体大小', style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(value: _fontSize.clamp(16, 32), min: 16, max: 32, divisions: 16,
            label: _fontSize.toInt().toString(),
            onChanged: (v) { setModal(() => _fontSize = v); setState(() {}); },
            onChangeEnd: (_) => _saveSettings()),
          const SizedBox(height: 16),
          const Text('行间距', style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(value: _lineHeight.clamp(2.0, 2.5), min: 2.0, max: 2.5, divisions: 5,
            label: _lineHeight.toStringAsFixed(1),
            onChanged: (v) { setModal(() => _lineHeight = v); setState(() {}); },
            onChangeEnd: (_) => _saveSettings()),
          const SizedBox(height: 16),
          const Text('背景颜色', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _colorBtn(Colors.white, '白色', setModal),
            _colorBtn(const Color(0xFFF5F0E1), '护眼', setModal),
            _colorBtn(const Color(0xFFCCE8CF), '绿色', setModal),
            _colorBtn(const Color(0xFF1C1C1E), '夜间', setModal),
          ]),
          const SizedBox(height: 20),
        ]),
      ),
    ));
  }

  Widget _colorBtn(Color color, String label, StateSetter setModal) {
    final sel = _backgroundColor == color;
    return GestureDetector(
      onTap: () { setModal(() => _backgroundColor = color); setState(() {}); _saveSettings(); },
      child: Column(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: sel ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
            width: sel ? 2 : 1))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12,
          color: sel ? Theme.of(context).colorScheme.primary : Colors.grey[600])),
      ]),
    );
  }
}

// ===== 章节内容 Widget =====

class _ChapterWidget extends ConsumerWidget {
  final ChapterInfo chapter;
  final String sourceId;
  final String bookId;
  final double fontSize;
  final double lineHeight;
  final Color textColor;

  const _ChapterWidget({
    super.key, required this.chapter, required this.sourceId,
    required this.bookId, required this.fontSize,
    required this.lineHeight, required this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(chapterContentProvider((
        sourceId: sourceId, bookId: bookId, chapterId: chapter.id)));

    return contentAsync.when(
      data: (content) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 40),
          Text(content.title, style: TextStyle(
            fontSize: fontSize + 4, fontWeight: FontWeight.bold,
            color: textColor, height: 1.5)),
          const SizedBox(height: 24),
          Text(content.content, style: TextStyle(
            fontSize: fontSize, height: lineHeight,
            color: textColor, letterSpacing: 0.5)),
          const SizedBox(height: 40),
          Center(child: Container(width: 120, height: 1,
            color: textColor.withValues(alpha: 0.15))),
        ]),
      ),
      loading: () => const SizedBox(height: 300,
        child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SizedBox(height: 200,
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败', style: TextStyle(color: textColor)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(chapterContentProvider((
                    sourceId: sourceId, bookId: bookId, chapterId: chapter.id)));
              },
              child: const Text('重试'),
            ),
          ],
        ))),
    );
  }
}
