import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ReadingHistoryService } from './reading-history.service';
import { CreateReadingHistoryDto } from './dto/create-reading-history.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('reading-history')
@UseGuards(JwtAuthGuard)
export class ReadingHistoryController {
  constructor(private readonly readingHistoryService: ReadingHistoryService) {}

  // 获取阅读历史列表
  @Get()
  findAll(
    @Request() req,
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.readingHistoryService.findAll(
      req.user.id,
      parseInt(page),
      parseInt(limit),
    );
  }

  // 获取阅读统计
  @Get('stats')
  getStats(@Request() req) {
    return this.readingHistoryService.getStats(req.user.id);
  }

  // 获取单本书的阅读历史
  @Get(':bookId')
  findOne(@Request() req, @Param('bookId') bookId: string) {
    return this.readingHistoryService.findOne(req.user.id, bookId);
  }

  // 添加/更新阅读历史
  @Post()
  upsert(@Request() req, @Body() dto: CreateReadingHistoryDto) {
    return this.readingHistoryService.upsert(req.user.id, dto);
  }

  // 删除单条阅读历史
  @Delete(':bookId')
  remove(@Request() req, @Param('bookId') bookId: string) {
    return this.readingHistoryService.remove(req.user.id, bookId);
  }

  // 清空所有阅读历史
  @Delete()
  clearAll(@Request() req) {
    return this.readingHistoryService.clearAll(req.user.id);
  }
}
