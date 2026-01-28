import { Injectable, Logger } from '@nestjs/common';
import { ZhuishuSource } from './sources/zhuishu.source';
import { BiqugeSource } from './sources/biquge.source';
import { DemoSource } from './sources/demo.source';
import { FanqieSource } from './sources/fanqie.source';
import { LegadoSourceParser } from './services/legado-parser.service';
import {
  IBookSource,
  BookSearchResult,
  BookDetail,
  ChapterInfo,
} from './interfaces/book-source.interface';

@Injectable()
export class BookSourceService {
  private readonly logger = new Logger(BookSourceService.name);
  private readonly sources: Map<string, IBookSource> = new Map();

  constructor(
    private readonly demoSource: DemoSource,
    private readonly fanqieSource: FanqieSource,
    private readonly zhuishuSource: ZhuishuSource,
    private readonly biqugeSource: BiqugeSource,
    private readonly legadoParser: LegadoSourceParser,
  ) {
    // 注册内置书源
    this.sources.set(this.demoSource.id, this.demoSource);
    this.sources.set(this.fanqieSource.id, this.fanqieSource);
    this.sources.set(this.zhuishuSource.id, this.zhuishuSource);
    this.sources.set(this.biqugeSource.id, this.biqugeSource);
  }

  // 获取所有书源列表
  getSources(): { id: string; name: string; type: string }[] {
    const builtIn = Array.from(this.sources.values()).map((s) => ({
      id: s.id,
      name: s.name,
      type: 'builtin',
    }));

    const imported = this.legadoParser.getImportedSources().map((s) => ({
      id: s.id,
      name: s.name,
      type: 'imported',
    }));

    return [...builtIn, ...imported];
  }

  // 导入 Legado 书源
  async importLegadoSources(jsonOrUrl: string) {
    return this.legadoParser.importSources(jsonOrUrl);
  }

  // 获取已导入的 Legado 书源
  getImportedSources() {
    return this.legadoParser.getImportedSources();
  }

  // 删除导入的书源
  removeImportedSource(id: string) {
    return this.legadoParser.removeSource(id);
  }

  // 搜索书籍 (多书源聚合)
  async search(
    keyword: string,
    sourceId?: string,
  ): Promise<BookSearchResult[]> {
    if (sourceId) {
      // 检查是否是导入的书源
      if (sourceId.startsWith('legado_')) {
        return this.legadoParser.search(sourceId, keyword);
      }

      const source = this.sources.get(sourceId);
      if (!source) {
        throw new Error(`书源 ${sourceId} 不存在`);
      }
      return source.search(keyword);
    }

    // 多书源并行搜索 (只使用内置源)
    const results = await Promise.allSettled(
      Array.from(this.sources.values()).map((source) => source.search(keyword)),
    );

    const allBooks: BookSearchResult[] = [];
    results.forEach((result) => {
      if (result.status === 'fulfilled') {
        allBooks.push(...result.value);
      }
    });

    // 去重 (按标题+作者)
    const uniqueBooks = this.deduplicateBooks(allBooks);
    return uniqueBooks;
  }

  // 获取书籍详情
  async getBookDetail(sourceId: string, bookId: string): Promise<BookDetail> {
    const source = this.sources.get(sourceId);
    if (!source) {
      throw new Error(`书源 ${sourceId} 不存在`);
    }
    return source.getBookDetail(bookId);
  }

  // 获取章节列表
  async getChapterList(sourceId: string, bookId: string): Promise<ChapterInfo[]> {
    const source = this.sources.get(sourceId);
    if (!source) {
      throw new Error(`书源 ${sourceId} 不存在`);
    }
    return source.getChapterList(bookId);
  }

  // 获取章节内容
  async getChapterContent(
    sourceId: string,
    bookId: string,
    chapterId: string,
  ): Promise<{ title: string; content: string }> {
    const source = this.sources.get(sourceId);
    if (!source) {
      throw new Error(`书源 ${sourceId} 不存在`);
    }

    const content = await source.getChapterContent(bookId, chapterId);

    // 获取章节列表以获取标题
    const chapters = await source.getChapterList(bookId);
    const chapter = chapters.find((c) => c.id === chapterId);

    return {
      title: chapter?.title || '未知章节',
      content,
    };
  }

  // 书籍去重
  private deduplicateBooks(books: BookSearchResult[]): BookSearchResult[] {
    const seen = new Map<string, BookSearchResult>();
    for (const book of books) {
      const key = `${book.title}-${book.author}`;
      if (!seen.has(key)) {
        seen.set(key, book);
      }
    }
    return Array.from(seen.values());
  }
}
