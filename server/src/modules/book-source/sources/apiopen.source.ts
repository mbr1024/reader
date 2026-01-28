import { Injectable, Logger } from '@nestjs/common';
import {
  IBookSource,
  BookSearchResult,
  BookDetail,
  ChapterInfo,
} from '../interfaces/book-source.interface';

/**
 * APIOpen 小说书源
 * https://api.apiopen.top
 */
@Injectable()
export class ApiopenSource implements IBookSource {
  readonly id = 'apiopen';
  readonly name = 'APIOpen';
  readonly baseUrl = 'https://api.apiopen.top';

  private readonly logger = new Logger(ApiopenSource.name);

  async search(keyword: string): Promise<BookSearchResult[]> {
    try {
      const url = `${this.baseUrl}/api/searchNovel?name=${encodeURIComponent(keyword)}`;
      const response = await fetch(url, {
        headers: { 'User-Agent': 'Mozilla/5.0' },
      });
      const data = await response.json();

      if (data.code !== 200 || !data.result) {
        return [];
      }

      return data.result.map((book: any) => ({
        id: book.bookId || book.id || String(Math.random()),
        title: book.bookName || book.name,
        author: book.author,
        cover: book.cover || book.img,
        description: book.desc || book.description,
        category: book.bookType || book.type,
        source: this.id,
      }));
    } catch (error) {
      this.logger.error(`Search failed: ${error.message}`);
      return [];
    }
  }

  async getBookDetail(bookId: string): Promise<BookDetail> {
    // APIOpen 没有单独的详情接口，返回基础信息
    return {
      id: bookId,
      title: '未知',
      author: '未知',
      source: this.id,
    };
  }

  async getChapterList(bookId: string): Promise<ChapterInfo[]> {
    // 需要具体实现
    return [];
  }

  async getChapterContent(bookId: string, chapterId: string): Promise<string> {
    return '';
  }
}
