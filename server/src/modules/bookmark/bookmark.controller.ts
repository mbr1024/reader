import {
  Controller,
  Get,
  Post,
  Delete,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { BookmarkService } from './bookmark.service';
import { CreateBookmarkDto } from './dto/create-bookmark.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('bookmarks')
@UseGuards(JwtAuthGuard)
export class BookmarkController {
  constructor(private readonly bookmarkService: BookmarkService) {}

  // 获取书签列表
  @Get()
  findAll(@Request() req, @Query('bookId') bookId?: string) {
    return this.bookmarkService.findAll(req.user.id, bookId);
  }

  // 获取书签统计
  @Get('stats')
  getStats(@Request() req) {
    return this.bookmarkService.getStats(req.user.id);
  }

  // 创建书签
  @Post()
  create(@Request() req, @Body() dto: CreateBookmarkDto) {
    return this.bookmarkService.create(req.user.id, dto);
  }

  // 更新书签备注
  @Patch(':id/note')
  updateNote(
    @Request() req,
    @Param('id') id: string,
    @Body('note') note: string,
  ) {
    return this.bookmarkService.updateNote(req.user.id, id, note);
  }

  // 删除书签
  @Delete(':id')
  remove(@Request() req, @Param('id') id: string) {
    return this.bookmarkService.remove(req.user.id, id);
  }

  // 清空某本书的书签
  @Delete('book/:bookId')
  clearByBook(@Request() req, @Param('bookId') bookId: string) {
    return this.bookmarkService.clearByBook(req.user.id, bookId);
  }
}
