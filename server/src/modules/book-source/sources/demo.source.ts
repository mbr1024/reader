import { Injectable } from '@nestjs/common';
import {
  IBookSource,
  BookSearchResult,
  BookDetail,
  ChapterInfo,
} from '../interfaces/book-source.interface';

/**
 * 示例书源 - 用于测试和演示
 * 包含推荐数据和示例书籍
 */
@Injectable()
export class DemoSource implements IBookSource {
  readonly id = 'demo';
  readonly name = '示例书库';
  readonly baseUrl = '';

  // 示例书籍数据（包含所有推荐书籍）
  private readonly books: BookDetail[] = [
    // Banner 推荐
    {
      id: '1',
      title: '斗破苍穹',
      author: '天蚕土豆',
      category: '玄幻',
      description: '三十年河东，三十年河西，莫欺少年穷！',
      chapterCount: 1648,
      status: 'completed',
      source: 'demo',
    },
    {
      id: '2',
      title: '诡秘之主',
      author: '爱潜水的乌贼',
      category: '玄幻',
      description: '蒸汽与机械的浪潮中，谁能触及非凡？',
      chapterCount: 1432,
      status: 'completed',
      source: 'demo',
    },
    {
      id: '3',
      title: '遮天',
      author: '辰东',
      category: '仙侠',
      description: '九具庞大的龙尸拉着一座古老的铜棺',
      chapterCount: 1880,
      status: 'completed',
      source: 'demo',
    },
    // 热门推荐
    {
      id: '4',
      title: '深空彼岸',
      author: '辰东',
      category: '玄幻',
      description: '浩瀚的宇宙中，璀璨的星河之上',
      chapterCount: 800,
      status: 'ongoing',
      source: 'demo',
    },
    {
      id: '5',
      title: '大奉打更人',
      author: '卖报小郎君',
      category: '仙侠',
      description: '这个世界，有儒、有佛、有妖、有术士',
      chapterCount: 1200,
      status: 'completed',
      source: 'demo',
    },
    {
      id: '6',
      title: '凡人修仙传',
      author: '忘语',
      category: '仙侠',
      description: '凡人流开创者，修仙小说巅峰之作',
      chapterCount: 2446,
      status: 'completed',
      source: 'demo',
    },
    {
      id: '7',
      title: '剑来',
      author: '烽火戏诸侯',
      category: '仙侠',
      description: '大千世界，无奇不有',
      chapterCount: 1100,
      status: 'ongoing',
      source: 'demo',
    },
    {
      id: '8',
      title: '万相之王',
      author: '天蚕土豆',
      category: '玄幻',
      description: '万相天骄，谁主沉浮',
      chapterCount: 600,
      status: 'ongoing',
      source: 'demo',
    },
    {
      id: '9',
      title: '庆余年',
      author: '猫腻',
      category: '历史',
      description: '积善之家，必有余庆',
      chapterCount: 746,
      status: 'completed',
      source: 'demo',
    },
    // 新书上架
    {
      id: '10',
      title: '灵境行者',
      author: '卖报小郎君',
      category: '仙侠',
      description: '这是一个光怪陆离的世界',
      chapterCount: 400,
      status: 'ongoing',
      source: 'demo',
    },
    {
      id: '11',
      title: '斗罗大陆V重生唐三',
      author: '唐家三少',
      category: '玄幻',
      description: '一代神王唐三重生归来',
      chapterCount: 500,
      status: 'ongoing',
      source: 'demo',
    },
    {
      id: '12',
      title: '星门',
      author: '老鹰吃小鸡',
      category: '都市',
      description: '星门洞开，异兽入侵',
      chapterCount: 350,
      status: 'ongoing',
      source: 'demo',
    },
    {
      id: '13',
      title: '完美世界',
      author: '辰东',
      category: '玄幻',
      description: '一粒尘可填海，一根草斩尽日月星辰',
      chapterCount: 2014,
      status: 'completed',
      source: 'demo',
    },
    {
      id: '14',
      title: '雪中悍刀行',
      author: '烽火戏诸侯',
      category: '仙侠',
      description: '江湖儿女江湖见',
      chapterCount: 1048,
      status: 'completed',
      source: 'demo',
    },
    {
      id: '15',
      title: '吞噬星空',
      author: '我吃西红柿',
      category: '科幻',
      description: '未来，地球经历一场大灾变后',
      chapterCount: 1511,
      status: 'completed',
      source: 'demo',
    },
    // 古典名著
    {
      id: '16',
      title: '西游记',
      author: '吴承恩',
      category: '古典名著',
      description: '《西游记》是中国古代第一部浪漫主义章回体长篇神魔小说',
      chapterCount: 100,
      status: 'completed',
      source: 'demo',
    },
    {
      id: '17',
      title: '三国演义',
      author: '罗贯中',
      category: '古典名著',
      description: '《三国演义》是中国古典四大名著之一',
      chapterCount: 120,
      status: 'completed',
      source: 'demo',
    },
    {
      id: '18',
      title: '水浒传',
      author: '施耐庵',
      category: '古典名著',
      description: '《水浒传》是中国历史上第一部用白话文写成的章回小说',
      chapterCount: 120,
      status: 'completed',
      source: 'demo',
    },
    {
      id: '19',
      title: '红楼梦',
      author: '曹雪芹',
      category: '古典名著',
      description: '《红楼梦》是中国古典四大名著之首',
      chapterCount: 120,
      status: 'completed',
      source: 'demo',
    },
  ];

  // Banner 书籍 ID
  private readonly bannerBookIds = ['1', '2', '3'];

  // 热门推荐书籍 ID
  private readonly hotBookIds = ['4', '5', '6', '7', '8', '9'];

  // 新书上架书籍 ID
  private readonly newBookIds = ['10', '11', '12', '13', '14', '15'];

  // 热门搜索关键词
  private readonly hotSearchKeywords = [
    '斗破苍穹', '诡秘之主', '遮天', '深空彼岸',
    '凡人修仙传', '剑来', '庆余年',
  ];

  // 默认书架书籍 ID
  private readonly defaultBookshelfIds = ['1', '2', '6'];

  // 获取推荐数据
  getRecommendations() {
    return {
      banners: this.bannerBookIds.map(id => this.getBookSummary(id)),
      hotBooks: this.hotBookIds.map(id => this.getBookSummary(id)),
      newBooks: this.newBookIds.map(id => this.getBookSummary(id)),
      hotSearch: this.hotSearchKeywords,
      defaultBookshelf: this.defaultBookshelfIds.map(id => this.getBookSummary(id)),
    };
  }

  // 获取书籍摘要（用于推荐列表）
  private getBookSummary(id: string) {
    const book = this.books.find(b => b.id === id);
    if (!book) return null;
    return {
      id: book.id,
      title: book.title,
      author: book.author,
      cover: book.cover,
      category: book.category,
      description: book.description,
      chapterCount: book.chapterCount,
      status: book.status,
      source: 'demo',
    };
  }

  // 示例章节
  private readonly sampleChapters = [
    '第一章 序章',
    '第二章 初遇',
    '第三章 觉醒',
    '第四章 修炼',
    '第五章 突破',
    '第六章 对决',
    '第七章 胜利',
    '第八章 新程',
    '第九章 挑战',
    '第十章 巅峰',
  ];

  private readonly sampleContent = `
    天色渐暗，夕阳的余晖洒在青石板路上，将整个小镇染成了一片金黄。

    少年背着简单的行囊，踏上了这条未知的道路。他的眼中满是对未来的期待，却也带着一丝离家的惆怅。

    "既然选择了这条路，就要走到底。"他在心中暗暗发誓。

    远处的山峦层叠，云雾缭绕，仿佛隐藏着无数的秘密。传说在那深山之中，有着无数的机缘与危险。

    少年深吸一口气，迈开了坚定的步伐。他知道，从这一刻起，他的人生将会完全不同。

    路边的老树上，一只乌鸦发出沙哑的叫声，似乎在为他送行，又似乎在警告着什么。

    但少年没有回头，他的目光始终望向前方，那片充满未知的世界。

    ......

    这一走，便是十年。

    十年后，当少年再次回到这条青石板路时，他已不再是当年那个懵懂的少年。

    他的眼中多了几分沧桑，却也多了几分从容。

    "终于回来了。"他轻声说道，嘴角浮现出一丝微笑。
  `;

  async search(keyword: string): Promise<BookSearchResult[]> {
    const results = this.books.filter(
      (book) =>
        book.title.includes(keyword) ||
        book.author.includes(keyword) ||
        (book.description && book.description.includes(keyword)),
    );

    return results.map((book) => ({
      id: book.id,
      title: book.title,
      author: book.author,
      cover: book.cover,
      description: book.description,
      category: book.category,
      status: book.status,
      source: this.id,
    }));
  }

  async getBookDetail(bookId: string): Promise<BookDetail> {
    const book = this.books.find((b) => b.id === bookId);
    if (!book) {
      throw new Error('书籍不存在');
    }
    return book;
  }

  async getChapterList(bookId: string): Promise<ChapterInfo[]> {
    const book = this.books.find((b) => b.id === bookId);
    if (!book) {
      return [];
    }

    // 生成章节列表
    const chapterCount = Math.min(book.chapterCount || 10, 100);
    return Array.from({ length: chapterCount }, (_, i) => ({
      id: String(i + 1),
      title: i < this.sampleChapters.length
        ? this.sampleChapters[i]
        : `第${i + 1}章`,
      index: i,
      wordCount: 2000 + Math.floor(Math.random() * 3000),
    }));
  }

  async getChapterContent(bookId: string, chapterId: string): Promise<string> {
    return this.sampleContent.trim();
  }
}
