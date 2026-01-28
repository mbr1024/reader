import { Injectable } from '@nestjs/common';
import {
  IBookSource,
  BookSearchResult,
  BookDetail,
  ChapterInfo,
} from '../interfaces/book-source.interface';

/**
 * 示例书源 - 用于测试和演示
 * 包含一些公版书籍数据
 */
@Injectable()
export class DemoSource implements IBookSource {
  readonly id = 'demo';
  readonly name = '示例书库';
  readonly baseUrl = '';

  // 示例书籍数据
  private readonly books: BookDetail[] = [
    {
      id: '1',
      title: '西游记',
      author: '吴承恩',
      cover: 'https://img.qidian.com/covers/xyj.jpg',
      description: '《西游记》是中国古代第一部浪漫主义章回体长篇神魔小说。该书以"唐僧取经"这一历史事件为蓝本，通过作者的艺术加工，深刻地描绘了当时的社会现实。',
      category: '古典名著',
      status: 'completed',
      chapterCount: 100,
      source: 'demo',
    },
    {
      id: '2',
      title: '三国演义',
      author: '罗贯中',
      cover: 'https://img.qidian.com/covers/sgyy.jpg',
      description: '《三国演义》是中国古典四大名著之一，是中国第一部长篇章回体历史演义小说，全名为《三国志通俗演义》。',
      category: '古典名著',
      status: 'completed',
      chapterCount: 120,
      source: 'demo',
    },
    {
      id: '3',
      title: '水浒传',
      author: '施耐庵',
      cover: 'https://img.qidian.com/covers/shz.jpg',
      description: '《水浒传》是中国历史上第一部用白话文写成的章回小说，也是中国古典四大名著之一。',
      category: '古典名著',
      status: 'completed',
      chapterCount: 120,
      source: 'demo',
    },
    {
      id: '4',
      title: '红楼梦',
      author: '曹雪芹',
      cover: 'https://img.qidian.com/covers/hlm.jpg',
      description: '《红楼梦》是中国古典四大名著之首，清代作家曹雪芹创作的章回体长篇小说。',
      category: '古典名著',
      status: 'completed',
      chapterCount: 120,
      source: 'demo',
    },
    {
      id: '5',
      title: '斗破苍穹',
      author: '天蚕土豆',
      description: '这是一个属于斗气的世界，没有花俏艳丽的魔法，有的，仅仅是繁衍到巅峰的斗气！',
      category: '玄幻',
      status: 'completed',
      chapterCount: 1648,
      source: 'demo',
    },
    {
      id: '6',
      title: '完美世界',
      author: '辰东',
      description: '一粒尘可填海，一根草斩尽日月星辰，弹指间天翻地覆。',
      category: '玄幻',
      status: 'completed',
      chapterCount: 2014,
      source: 'demo',
    },
  ];

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
