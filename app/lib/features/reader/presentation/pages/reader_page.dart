import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReaderPage extends StatefulWidget {
  final String bookId;
  final int initialChapter;

  const ReaderPage({
    super.key,
    required this.bookId,
    this.initialChapter = 0,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late PageController _pageController;
  bool _showControls = false;
  int _currentChapter = 0;
  int _currentPage = 0;
  int _totalPages = 10;

  // 阅读设置
  double _fontSize = 18;
  double _lineHeight = 1.8;
  Color _backgroundColor = const Color(0xFFF5F0E1); // 护眼黄

  // 示例章节内容
  final List<String> _chapters = [
    '第一章 初入江湖',
    '第二章 奇遇',
    '第三章 修炼',
    '第四章 试炼',
    '第五章 突破',
  ];

  final String _sampleContent = '''
    天色渐暗，夕阳的余晖洒在青石板路上，将整个小镇染成了一片金黄。

    少年背着简单的行囊，踏上了这条未知的道路。他的眼中满是对未来的期待，却也带着一丝离家的惆怅。

    "既然选择了这条路，就要走到底。"他在心中暗暗发誓。

    远处的山峦层叠，云雾缭绕，仿佛隐藏着无数的秘密。传说在那深山之中，有着无数的机缘与危险。

    少年深吸一口气，迈开了坚定的步伐。他知道，从这一刻起，他的人生将会完全不同。

    路边的老树上，一只乌鸦发出沙哑的叫声，似乎在为他送行，又似乎在警告着什么。

    但少年没有回头，他的目光始终望向前方，那片充满未知的世界。
  ''';

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _pageController = PageController();

    // 进入阅读模式：全屏沉浸式
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // 退出时恢复系统UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: GestureDetector(
        onTap: _handleTap,
        child: Stack(
          children: [
            // 阅读内容
            _buildReaderContent(),

            // 顶部控制栏
            if (_showControls) _buildTopBar(),

            // 底部控制栏
            if (_showControls) _buildBottomBar(),

            // 设置面板
            if (_showControls) _buildSettingsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildReaderContent() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemCount: _totalPages,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 章节标题
              if (index == 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _chapters[_currentChapter],
                    style: TextStyle(
                      fontSize: _fontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

              // 正文内容
              Expanded(
                child: Text(
                  _sampleContent,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: _lineHeight,
                    color: Colors.black87,
                  ),
                ),
              ),

              // 页码
              Center(
                child: Text(
                  '${index + 1} / $_totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black54,
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  _chapters[_currentChapter],
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
                  // TODO: Add bookmark
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black54,
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 进度条
                Row(
                  children: [
                    Text(
                      '${_currentPage + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentPage.toDouble(),
                        min: 0,
                        max: (_totalPages - 1).toDouble(),
                        onChanged: (value) {
                          _pageController.jumpToPage(value.toInt());
                        },
                      ),
                    ),
                    Text(
                      '$_totalPages',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),

                // 功能按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomButton(Icons.list, '目录', () {
                      _showChapterList();
                    }),
                    _buildBottomButton(Icons.nightlight_round, '夜间', () {
                      setState(() {
                        _backgroundColor = _backgroundColor == const Color(0xFF1C1C1E)
                            ? const Color(0xFFF5F0E1)
                            : const Color(0xFF1C1C1E);
                      });
                    }),
                    _buildBottomButton(Icons.text_fields, '字体', () {
                      _showFontSettings();
                    }),
                    _buildBottomButton(Icons.download, '缓存', () {
                      // TODO: Download chapters
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

  Widget _buildBottomButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return const SizedBox.shrink();
  }

  void _handleTap() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '目录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _chapters[index],
                      style: TextStyle(
                        color: index == _currentChapter
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentChapter = index;
                        _currentPage = 0;
                      });
                      _pageController.jumpToPage(0);
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
              const Text(
                '字体大小',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _fontSize,
                min: 12,
                max: 32,
                divisions: 20,
                label: _fontSize.toInt().toString(),
                onChanged: (value) {
                  setModalState(() {
                    _fontSize = value;
                  });
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              const Text(
                '行间距',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _lineHeight,
                min: 1.2,
                max: 2.5,
                divisions: 13,
                label: _lineHeight.toStringAsFixed(1),
                onChanged: (value) {
                  setModalState(() {
                    _lineHeight = value;
                  });
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              const Text(
                '背景颜色',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
        setModalState(() {
          _backgroundColor = color;
        });
        setState(() {});
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
