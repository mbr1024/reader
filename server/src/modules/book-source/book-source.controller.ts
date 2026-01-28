import { Controller, Get, Post, Delete, Query, Param, Body } from '@nestjs/common';
import { BookSourceService } from './book-source.service';

@Controller('book-source')
export class BookSourceController {
  constructor(private readonly bookSourceService: BookSourceService) {}

  // 导入 Legado 书源 (支持 JSON 字符串或 URL)
  @Post('import')
  async importLegadoSources(@Body('source') source: string) {
    if (!source) {
      return { error: '请提供书源 JSON 或 URL' };
    }
    const result = await this.bookSourceService.importLegadoSources(source);
    return result;
  }

  // 获取已导入的书源
  @Get('imported')
  getImportedSources() {
    return this.bookSourceService.getImportedSources();
  }

  // 删除导入的书源
  @Delete('imported/:id')
  removeImportedSource(@Param('id') id: string) {
    return this.bookSourceService.removeImportedSource(id);
  }

  // 获取所有书源
  @Get('sources')
  getSources() {
    return this.bookSourceService.getSources();
  }

  // 搜索书籍
  @Get('search')
  async search(
    @Query('keyword') keyword: string,
    @Query('source') sourceId?: string,
  ) {
    if (!keyword) {
      return { error: '请输入搜索关键词' };
    }
    const books = await this.bookSourceService.search(keyword, sourceId);
    return { books, total: books.length };
  }

  // 获取书籍详情
  @Get('book/:source/:bookId')
  async getBookDetail(
    @Param('source') sourceId: string,
    @Param('bookId') bookId: string,
  ) {
    return this.bookSourceService.getBookDetail(sourceId, bookId);
  }

  // 获取章节列表
  @Get('book/:source/:bookId/chapters')
  async getChapterList(
    @Param('source') sourceId: string,
    @Param('bookId') bookId: string,
  ) {
    const chapters = await this.bookSourceService.getChapterList(sourceId, bookId);
    return { chapters, total: chapters.length };
  }

  // 获取章节内容
  @Get('book/:source/:bookId/chapter/:chapterId')
  async getChapterContent(
    @Param('source') sourceId: string,
    @Param('bookId') bookId: string,
    @Param('chapterId') chapterId: string,
  ) {
    return this.bookSourceService.getChapterContent(sourceId, bookId, chapterId);
  }
}
