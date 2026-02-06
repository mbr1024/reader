/// 应用 Mock 数据
/// 包含书籍、分类、Banner 等模拟数据
/// 封面使用本地 assets/images/covers/ 目录下的图片

class MockBook {
  final String id;
  final String title;
  final String author;
  final String cover;
  final String category;
  final String description;
  final int chapterCount;
  final String status;

  const MockBook({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.category,
    required this.description,
    this.chapterCount = 0,
    this.status = '连载中',
  });
}

class MockData {
  // 本地封面图片列表 (从 assets/images/covers/ 目录)
  static final List<String> _localCovers = List.generate(
    38, 
    (index) => 'assets/images/covers/${index + 1}.webp'
  );

  // 随机打乱封面列表
  static final List<String> _randomCovers = List.of(_localCovers)..shuffle();

  // 获取封面（随机顺序，尽量不重复）
  static String getCover(int index) => _randomCovers[index % _randomCovers.length];

  // 本地调试书籍 - 三体（可用于调试详情页和阅读器）
  static const localDebugBook = MockBook(
    id: 'santi',
    title: '三体',
    author: '刘慈欣',
    cover: 'assets/images/covers/image.png',
    category: '科幻',
    description: '文化大革命如火如荼进行的同时，军方探寻外星文明的绝秘计划"红岸工程"取得了突破性进展。',
    chapterCount: 36,
    status: '完结',
  );
  
  // Banner 推荐书籍
  static final bannerBooks = [
    // 本地调试书籍 - 三体
    localDebugBook,
    MockBook(
      id: '1',
      title: '斗破苍穹',
      author: '天蚕土豆',
      category: '玄幻',
      cover: getCover(0),
      description: '三十年河东，三十年河西，莫欺少年穷！',
      chapterCount: 1648,
      status: '完结',
    ),
    MockBook(
      id: '2',
      title: '诡秘之主',
      author: '爱潜水的乌贼',
      category: '玄幻',
      cover: getCover(1),
      description: '蒸汽与机械的浪潮中，谁能触及非凡？',
      chapterCount: 1432,
      status: '完结',
    ),
    MockBook(
      id: '3',
      title: '遮天',
      author: '辰东',
      category: '仙侠',
      cover: getCover(2),
      description: '九具庞大的龙尸拉着一座古老的铜棺',
      chapterCount: 1880,
      status: '完结',
    ),
  ];

  // 热门推荐
  static final hotBooks = [
    MockBook(
      id: '4',
      title: '深空彼岸',
      author: '辰东',
      category: '玄幻',
      cover: getCover(3),
      description: '浩瀚的宇宙中，璀璨的星河之上',
    ),
    MockBook(
      id: '5',
      title: '大奉打更人',
      author: '卖报小郎君',
      category: '仙侠',
      cover: getCover(4),
      description: '这个世界，有儒、有佛、有妖、有术士',
    ),
    MockBook(
      id: '6',
      title: '凡人修仙传',
      author: '忘语',
      category: '仙侠',
      cover: getCover(5),
      description: '凡人流开创者，修仙小说巅峰之作',
    ),
    MockBook(
      id: '7',
      title: '剑来',
      author: '烽火戏诸侯',
      category: '仙侠',
      cover: getCover(6),
      description: '大千世界，无奇不有',
    ),
    MockBook(
      id: '8',
      title: '万相之王',
      author: '天蚕土豆',
      category: '玄幻',
      cover: getCover(7),
      description: '万相天骄，谁主沉浮',
    ),
    MockBook(
      id: '9',
      title: '庆余年',
      author: '猫腻',
      category: '历史',
      cover: getCover(8),
      description: '积善之家，必有余庆',
    ),
  ];

  // 新书上架
  static final newBooks = [
    MockBook(
      id: '10',
      title: '灵境行者',
      author: '卖报小郎君',
      category: '仙侠',
      cover: getCover(9),
      description: '这是一个光怪陆离的世界',
    ),
    MockBook(
      id: '11',
      title: '斗罗大陆V重生唐三',
      author: '唐家三少',
      category: '玄幻',
      cover: getCover(10),
      description: '一代神王唐三重生归来',
    ),
    MockBook(
      id: '12',
      title: '星门',
      author: '老鹰吃小鸡',
      category: '都市',
      cover: getCover(11),
      description: '星门洞开，异兽入侵',
    ),
    MockBook(
      id: '13',
      title: '完美世界',
      author: '辰东',
      category: '玄幻',
      cover: getCover(12),
      description: '一粒尘可填海，一根草斩尽日月星辰',
    ),
    MockBook(
      id: '14',
      title: '雪中悍刀行',
      author: '烽火戏诸侯',
      category: '仙侠',
      cover: getCover(13),
      description: '江湖儿女江湖见',
    ),
    MockBook(
      id: '15',
      title: '吞噬星空',
      author: '我吃西红柿',
      category: '科幻',
      cover: getCover(14),
      description: '未来，地球经历一场大灾变后',
    ),
  ];

  // 热门搜索
  static const hotSearch = [
    '斗破苍穹', '诡秘之主', '遮天', '深空彼岸', 
    '凡人修仙传', '剑来', '庆余年',
  ];

  // 初始书架数据
  static final defaultBookshelf = [
    MockBook(
      id: '1',
      title: '斗破苍穹',
      author: '天蚕土豆',
      category: '玄幻',
      cover: getCover(0),
      description: '三十年河东，三十年河西，莫欺少年穷！',
    ),
    MockBook(
      id: '2',
      title: '诡秘之主',
      author: '爱潜水的乌贼',
      category: '玄幻',
      cover: getCover(1),
      description: '蒸汽与机械的浪潮中，谁能触及非凡？',
    ),
    MockBook(
      id: '6',
      title: '凡人修仙传',
      author: '忘语',
      category: '仙侠',
      cover: getCover(5),
      description: '凡人流开创者，修仙小说巅峰之作',
    ),
  ];

  static List<MockBook> get allBooks => [...hotBooks, ...newBooks, ...bannerBooks];
}
