import { Injectable, Logger } from '@nestjs/common';
import {
  IBookSource,
  BookSearchResult,
  BookDetail,
  ChapterInfo,
} from '../interfaces/book-source.interface';

/**
 * 番茄小说 API 书源
 * 使用第三方解析 API
 */
@Injectable()
export class FanqieSource implements IBookSource {
  readonly id = 'fanqie';
  readonly name = '番茄小说';
  readonly baseUrl = 'https://novel.snssdk.com';

  private readonly logger = new Logger(FanqieSource.name);

  // 备用 API 地址
  private readonly apiUrls = [
    'https://novel.snssdk.com',
    'https://api5-normal-lf.fqnovel.com',
  ];

  async search(keyword: string, page = 1): Promise<BookSearchResult[]> {
    try {
      const url = `${this.baseUrl}/api/novel/channel/homepage/search/search/v1/?aid=1967&offset=${(page - 1) * 10}&count=10&query=${encodeURIComponent(keyword)}`;

      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        },
      });
      const data = await response.json();

      if (!data.data || !data.data.ret_data) {
        return [];
      }

      return data.data.ret_data.map((book: any) => ({
        id: book.book_id || book.id,
        title: book.book_name || book.title,
        author: book.author,
        cover: book.thumb_url || book.cover,
        description: book.abstract || book.intro,
        category: book.category,
        lastChapter: book.last_chapter_title,
        status: book.creation_status === '0' ? 'ongoing' : 'completed',
        source: this.id,
      }));
    } catch (error) {
      this.logger.error(`Search failed: ${error.message}`);
      return [];
    }
  }

  async getBookDetail(bookId: string): Promise<BookDetail> {
    try {
      const url = `${this.baseUrl}/api/novel/book/directory/list/v1/?book_id=${bookId}&aid=1967`;

      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        },
      });
      const data = await response.json();

      const book = data.data?.book_info || {};

      return {
        id: bookId,
        title: book.book_name || '未知',
        author: book.author || '未知',
        cover: book.thumb_url,
        description: book.abstract,
        category: book.category,
        status: book.creation_status === '0' ? 'ongoing' : 'completed',
        wordCount: book.word_count,
        source: this.id,
      };
    } catch (error) {
      this.logger.error(`Get book detail failed: ${error.message}`);
      throw error;
    }
  }

  async getChapterList(bookId: string): Promise<ChapterInfo[]> {
    try {
      const url = `${this.baseUrl}/api/novel/book/directory/list/v1/?book_id=${bookId}&aid=1967`;

      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        },
      });
      const data = await response.json();

      if (!data.data || !data.data.item_data_list) {
        return [];
      }

      return data.data.item_data_list.map((chapter: any, index: number) => ({
        id: chapter.item_id,
        title: chapter.title,
        index,
        wordCount: chapter.word_count,
      }));
    } catch (error) {
      this.logger.error(`Get chapter list failed: ${error.message}`);
      return [];
    }
  }

  async getChapterContent(bookId: string, chapterId: string): Promise<string> {
    try {
      const url = `${this.baseUrl}/api/novel/book/reader/full/v1/?item_id=${chapterId}&aid=1967`;

      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)',
        },
      });
      const data = await response.json();

      if (data.data && data.data.content) {
        // 解析内容（番茄小说的内容可能是加密的）
        return this.decodeContent(data.data.content);
      }
      return '';
    } catch (error) {
      this.logger.error(`Get chapter content failed: ${error.message}`);
      return '';
    }
  }

  private decodeContent(content: string): string {
    // 番茄小说内容解析
    // 实际使用时可能需要根据 API 返回格式调整
    try {
      // 移除 HTML 标签
      let text = content.replace(/<[^>]+>/g, '\n');
      // 处理特殊字符
      text = text.replace(/&nbsp;/g, ' ');
      text = text.replace(/&lt;/g, '<');
      text = text.replace(/&gt;/g, '>');
      text = text.replace(/&amp;/g, '&');
      // 清理多余空行
      text = text.replace(/\n{3,}/g, '\n\n');
      return text.trim();
    } catch {
      return content;
    }
  }
}
