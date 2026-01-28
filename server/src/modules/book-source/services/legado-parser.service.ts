import { Injectable, Logger } from '@nestjs/common';
import { LegadoBookSource } from '../interfaces/legado.interface';
import {
  BookSearchResult,
  BookDetail,
  ChapterInfo,
} from '../interfaces/book-source.interface';

/**
 * Legado 书源解析器
 * 支持导入和解析 Legado/阅读 格式的书源
 */
@Injectable()
export class LegadoSourceParser {
  private readonly logger = new Logger(LegadoSourceParser.name);
  private readonly importedSources: Map<string, LegadoBookSource> = new Map();

  // 导入书源 (从 JSON 字符串或 URL)
  async importSources(jsonOrUrl: string): Promise<{ success: number; failed: number }> {
    let sources: LegadoBookSource[] = [];

    try {
      // 判断是 URL 还是 JSON
      if (jsonOrUrl.startsWith('http')) {
        const response = await fetch(jsonOrUrl);
        sources = await response.json();
      } else {
        sources = JSON.parse(jsonOrUrl);
      }

      // 确保是数组
      if (!Array.isArray(sources)) {
        sources = [sources];
      }

      let success = 0;
      let failed = 0;

      for (const source of sources) {
        try {
          if (this.validateSource(source)) {
            const id = this.generateSourceId(source);
            this.importedSources.set(id, source);
            success++;
          } else {
            failed++;
          }
        } catch {
          failed++;
        }
      }

      this.logger.log(`Imported ${success} sources, ${failed} failed`);
      return { success, failed };
    } catch (error) {
      this.logger.error(`Import failed: ${error.message}`);
      throw error;
    }
  }

  // 获取已导入的书源列表
  getImportedSources(): { id: string; name: string; url: string; enabled: boolean }[] {
    return Array.from(this.importedSources.entries()).map(([id, source]) => ({
      id,
      name: source.bookSourceName,
      url: source.bookSourceUrl,
      enabled: source.enabled !== false,
    }));
  }

  // 删除书源
  removeSource(id: string): boolean {
    return this.importedSources.delete(id);
  }

  // 清空所有导入的书源
  clearSources(): void {
    this.importedSources.clear();
  }

  // 使用书源搜索
  async search(sourceId: string, keyword: string): Promise<BookSearchResult[]> {
    const source = this.importedSources.get(sourceId);
    if (!source || !source.searchUrl) {
      return [];
    }

    try {
      // 构建搜索 URL
      let searchUrl = source.searchUrl.replace('{{key}}', encodeURIComponent(keyword));
      if (!searchUrl.startsWith('http')) {
        searchUrl = source.bookSourceUrl + searchUrl;
      }

      const response = await fetch(searchUrl, {
        headers: this.parseHeaders(source.header),
      });

      const contentType = response.headers.get('content-type') || '';

      if (contentType.includes('application/json')) {
        // JSON API 响应
        const data = await response.json();
        return this.parseSearchResultFromJson(data, source);
      } else {
        // HTML 响应，需要解析
        const html = await response.text();
        return this.parseSearchResultFromHtml(html, source);
      }
    } catch (error) {
      this.logger.error(`Search failed for ${sourceId}: ${error.message}`);
      return [];
    }
  }

  private validateSource(source: LegadoBookSource): boolean {
    return !!(source.bookSourceName && source.bookSourceUrl);
  }

  private generateSourceId(source: LegadoBookSource): string {
    // 使用 URL 的 hash 作为 ID
    const url = source.bookSourceUrl;
    let hash = 0;
    for (let i = 0; i < url.length; i++) {
      const char = url.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return `legado_${Math.abs(hash)}`;
  }

  private parseHeaders(headerStr?: string): Record<string, string> {
    const headers: Record<string, string> = {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36',
    };

    if (headerStr) {
      try {
        const parsed = JSON.parse(headerStr);
        Object.assign(headers, parsed);
      } catch {
        // 忽略解析错误
      }
    }

    return headers;
  }

  private parseSearchResultFromJson(
    data: any,
    source: LegadoBookSource,
  ): BookSearchResult[] {
    // 简化的 JSON 解析，实际需要根据规则解析
    const results: BookSearchResult[] = [];
    const rules = source.ruleSearch;

    if (!rules) return results;

    // 获取书籍列表
    let bookList = data;
    if (rules.bookList) {
      bookList = this.getValueByPath(data, rules.bookList);
    }

    if (!Array.isArray(bookList)) {
      bookList = [bookList];
    }

    for (const item of bookList) {
      try {
        results.push({
          id: String(item.id || item.bookId || item.book_id || Math.random()),
          title: this.getValueByPath(item, rules.name || 'name') || '未知',
          author: this.getValueByPath(item, rules.author || 'author') || '未知',
          cover: this.getValueByPath(item, rules.coverUrl || 'cover'),
          description: this.getValueByPath(item, rules.intro || 'intro'),
          category: this.getValueByPath(item, rules.kind || 'category'),
          source: this.generateSourceId(source),
        });
      } catch {
        continue;
      }
    }

    return results;
  }

  private parseSearchResultFromHtml(
    html: string,
    source: LegadoBookSource,
  ): BookSearchResult[] {
    // HTML 解析需要更复杂的实现（XPath/CSS选择器）
    // 这里提供简化版本
    this.logger.warn('HTML parsing not fully implemented');
    return [];
  }

  private getValueByPath(obj: any, path: string): any {
    if (!path || !obj) return undefined;

    // 处理简单路径如 "data.list" 或 "$.data.list"
    const cleanPath = path.replace(/^\$\.?/, '');
    const parts = cleanPath.split('.');

    let value = obj;
    for (const part of parts) {
      if (value === undefined || value === null) return undefined;
      value = value[part];
    }

    return value;
  }
}
