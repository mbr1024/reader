import { Injectable, Logger } from '@nestjs/common';
import {
  IBookSource,
  BookSearchResult,
  BookDetail,
  ChapterInfo,
} from '../interfaces/book-source.interface';

/**
 * 追书神器 API 书源
 * API 文档: https://github.com/xiaoshenxian233/ZhuiShuApi
 */
@Injectable()
export class ZhuishuSource implements IBookSource {
  readonly id = 'zhuishu';
  readonly name = '追书神器';
  readonly baseUrl = 'https://api.zhuishushenqi.com';

  private readonly logger = new Logger(ZhuishuSource.name);

  async search(keyword: string, page = 1): Promise<BookSearchResult[]> {
    try {
      const url = `${this.baseUrl}/book/fuzzy-search?query=${encodeURIComponent(keyword)}&start=${(page - 1) * 20}&limit=20`;
      const response = await fetch(url);
      const data = await response.json();

      if (!data.books) return [];

      return data.books.map((book: any) => ({
        id: book._id,
        title: book.title,
        author: book.author,
        cover: book.cover?.startsWith('http')
          ? book.cover
          : `https://statics.zhuishushenqi.com${book.cover}`,
        description: book.shortIntro || book.longIntro,
        category: book.cat,
        lastChapter: book.lastChapter,
        status: book.isSerial ? 'ongoing' : 'completed',
        source: this.id,
      }));
    } catch (error) {
      this.logger.error(`Search failed: ${error.message}`);
      return [];
    }
  }

  async getBookDetail(bookId: string): Promise<BookDetail> {
    try {
      const url = `${this.baseUrl}/book/${bookId}`;
      const response = await fetch(url);
      const book = await response.json();

      return {
        id: book._id,
        title: book.title,
        author: book.author,
        cover: book.cover?.startsWith('http')
          ? book.cover
          : `https://statics.zhuishushenqi.com${book.cover}`,
        description: book.longIntro || book.shortIntro,
        category: book.cat,
        status: book.isSerial ? 'ongoing' : 'completed',
        lastChapter: book.lastChapter,
        lastUpdateTime: book.updated,
        wordCount: book.wordCount,
        chapterCount: book.chaptersCount,
        source: this.id,
      };
    } catch (error) {
      this.logger.error(`Get book detail failed: ${error.message}`);
      throw error;
    }
  }

  async getChapterList(bookId: string): Promise<ChapterInfo[]> {
    try {
      // 先获取书源列表
      const sourcesUrl = `${this.baseUrl}/atoc?view=summary&book=${bookId}`;
      const sourcesRes = await fetch(sourcesUrl);
      const sources = await sourcesRes.json();

      if (!sources || sources.length === 0) {
        return [];
      }

      // 使用第一个书源
      const sourceId = sources[0]._id;
      const chaptersUrl = `${this.baseUrl}/atoc/${sourceId}?view=chapters`;
      const chaptersRes = await fetch(chaptersUrl);
      const data = await chaptersRes.json();

      if (!data.chapters) return [];

      return data.chapters.map((chapter: any, index: number) => ({
        id: chapter.link,
        title: chapter.title,
        index: index,
        wordCount: chapter.wordCount,
      }));
    } catch (error) {
      this.logger.error(`Get chapter list failed: ${error.message}`);
      return [];
    }
  }

  async getChapterContent(bookId: string, chapterLink: string): Promise<string> {
    try {
      const url = `${this.baseUrl}/chapter/${encodeURIComponent(chapterLink)}`;
      const response = await fetch(url);
      const data = await response.json();

      if (data.chapter && data.chapter.body) {
        return data.chapter.body;
      }
      return '';
    } catch (error) {
      this.logger.error(`Get chapter content failed: ${error.message}`);
      return '';
    }
  }
}
