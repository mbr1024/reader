import { Controller, Get, Post, Delete, Query, Param, Body, UseGuards, Request } from '@nestjs/common';
import { BookSourceService } from './book-source.service';
import { DemoSource } from './sources/demo.source';
import { OptionalJwtAuthGuard } from '../../common/guards/optional-jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';

@Controller('book-source')
export class BookSourceController {
  constructor(
    private readonly bookSourceService: BookSourceService,
    private readonly demoSource: DemoSource,
    private readonly prisma: PrismaService,
  ) {}

  // 获取推荐数据（banner、热门、新书、热搜等）
  @Get('recommendations')
  @UseGuards(OptionalJwtAuthGuard)
  async getRecommendations(@Request() req) {
    const recommendations = this.demoSource.getRecommendations();
    
    // 未登录用户不返回书架
    if (!req.user) {
      return {
        ...recommendations,
        defaultBookshelf: [],
      };
    }
    
    // 已登录用户返回真实书架
    const bookshelf = await this.prisma.bookshelf.findMany({
      where: { userId: req.user.id },
      include: { book: true },
      orderBy: [{ isTop: 'desc' }, { lastReadAt: 'desc' }],
    });
    
    // 转换为 app 需要的格式
    const userBookshelf = bookshelf.map(item => ({
      id: item.book.sourceId,
      title: item.book.title,
      author: item.book.author,
      cover: item.book.cover,
      category: null,
      description: null,
      chapterCount: null,
      status: null,
      source: item.book.sourceType,
      lastChapter: item.lastChapter,
      isTop: item.isTop,
    }));
    
    return {
      ...recommendations,
      defaultBookshelf: userBookshelf,
    };
  }

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
