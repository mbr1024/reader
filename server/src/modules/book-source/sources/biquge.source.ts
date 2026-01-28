import { Injectable, Logger } from '@nestjs/common';
import {
  IBookSource,
  BookSearchResult,
  BookDetail,
  ChapterInfo,
} from '../interfaces/book-source.interface';

/**
 * 笔趣阁书源 (网页爬取)
 * 备用书源，当主书源不可用时使用
 */
@Injectable()
export class BiqugeSource implements IBookSource {
  readonly id = 'biquge';
  readonly name = '笔趣阁';
  readonly baseUrl = 'https://www.xbiquge.so';

  private readonly logger = new Logger(BiqugeSource.name);

  async search(keyword: string): Promise<BookSearchResult[]> {
    try {
      const url = `${this.baseUrl}/search.php?q=${encodeURIComponent(keyword)}`;
      const response = await fetch(url);
      const html = await response.text();

      // 简单的正则匹配搜索结果
      const results: BookSearchResult[] = [];
      const bookRegex = /<a[^>]*href="\/book\/(\d+)\/"[^>]*>([^<]+)<\/a>/g;
      const authorRegex = /<span>([^<]+)<\/span>/g;

      let match;
      while ((match = bookRegex.exec(html)) !== null) {
        results.push({
          id: match[1],
          title: match[2].trim(),
          author: '未知',
          source: this.id,
        });
      }

      return results.slice(0, 20);
    } catch (error) {
      this.logger.error(`Search failed: ${error.message}`);
      return [];
    }
  }

  async getBookDetail(bookId: string): Promise<BookDetail> {
    try {
      const url = `${this.baseUrl}/book/${bookId}/`;
      const response = await fetch(url);
      const html = await response.text();

      // 提取书籍信息
      const titleMatch = html.match(/<h1>([^<]+)<\/h1>/);
      const authorMatch = html.match(/<p>作\s*者：([^<]+)<\/p>/);
      const descMatch = html.match(/<div id="intro">[\s\S]*?<p>([^<]+)<\/p>/);
      const coverMatch = html.match(/<img[^>]*src="([^"]+)"[^>]*id="fmimg"/);

      return {
        id: bookId,
        title: titleMatch ? titleMatch[1].trim() : '未知',
        author: authorMatch ? authorMatch[1].trim() : '未知',
        cover: coverMatch ? coverMatch[1] : undefined,
        description: descMatch ? descMatch[1].trim() : undefined,
        source: this.id,
      };
    } catch (error) {
      this.logger.error(`Get book detail failed: ${error.message}`);
      throw error;
    }
  }

  async getChapterList(bookId: string): Promise<ChapterInfo[]> {
    try {
      const url = `${this.baseUrl}/book/${bookId}/`;
      const response = await fetch(url);
      const html = await response.text();

      const chapters: ChapterInfo[] = [];
      const chapterRegex = /<dd><a href="\/book\/\d+\/(\d+)\.html">([^<]+)<\/a><\/dd>/g;

      let match;
      let index = 0;
      while ((match = chapterRegex.exec(html)) !== null) {
        chapters.push({
          id: match[1],
          title: match[2].trim(),
          index: index++,
        });
      }

      return chapters;
    } catch (error) {
      this.logger.error(`Get chapter list failed: ${error.message}`);
      return [];
    }
  }

  async getChapterContent(bookId: string, chapterId: string): Promise<string> {
    try {
      const url = `${this.baseUrl}/book/${bookId}/${chapterId}.html`;
      const response = await fetch(url);
      const html = await response.text();

      // 提取正文内容
      const contentMatch = html.match(/<div id="content">[\s\S]*?<\/div>/);
      if (contentMatch) {
        let content = contentMatch[0];
        // 清理 HTML 标签
        content = content.replace(/<[^>]+>/g, '\n');
        content = content.replace(/&nbsp;/g, ' ');
        content = content.replace(/\n{3,}/g, '\n\n');
        return content.trim();
      }
      return '';
    } catch (error) {
      this.logger.error(`Get chapter content failed: ${error.message}`);
      return '';
    }
  }
}
