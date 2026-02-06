import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReadingHistoryDto } from './dto/create-reading-history.dto';

@Injectable()
export class ReadingHistoryService {
  constructor(private readonly prisma: PrismaService) {}

  // 获取用户阅读历史列表
  async findAll(userId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;

    const [histories, total] = await Promise.all([
      this.prisma.readingHistory.findMany({
        where: { userId },
        orderBy: { lastReadAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.readingHistory.count({ where: { userId } }),
    ]);

    return {
      data: histories,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // 添加或更新阅读历史
  async upsert(userId: string, dto: CreateReadingHistoryDto) {
    return this.prisma.readingHistory.upsert({
      where: {
        userId_bookId: {
          userId,
          bookId: dto.bookId,
        },
      },
      update: {
        lastChapter: dto.lastChapter,
        chapterTitle: dto.chapterTitle,
        progress: dto.progress,
        readDuration: dto.readDuration
          ? { increment: dto.readDuration }
          : undefined,
        lastReadAt: new Date(),
      },
      create: {
        userId,
        bookId: dto.bookId,
        sourceId: dto.sourceId,
        sourceType: dto.sourceType,
        bookTitle: dto.bookTitle,
        bookAuthor: dto.bookAuthor,
        bookCover: dto.bookCover,
        lastChapter: dto.lastChapter,
        chapterTitle: dto.chapterTitle,
        progress: dto.progress,
        readDuration: dto.readDuration || 0,
      },
    });
  }

  // 获取单条阅读历史
  async findOne(userId: string, bookId: string) {
    const history = await this.prisma.readingHistory.findUnique({
      where: {
        userId_bookId: { userId, bookId },
      },
    });

    if (!history) {
      throw new NotFoundException('阅读历史不存在');
    }

    return history;
  }

  // 删除单条阅读历史
  async remove(userId: string, bookId: string) {
    try {
      await this.prisma.readingHistory.delete({
        where: {
          userId_bookId: { userId, bookId },
        },
      });
      return { message: '删除成功' };
    } catch {
      throw new NotFoundException('阅读历史不存在');
    }
  }

  // 清空所有阅读历史
  async clearAll(userId: string) {
    await this.prisma.readingHistory.deleteMany({
      where: { userId },
    });
    return { message: '已清空所有阅读历史' };
  }

  // 获取阅读统计
  async getStats(userId: string) {
    const [totalBooks, totalDuration, histories] = await Promise.all([
      this.prisma.readingHistory.count({ where: { userId } }),
      this.prisma.readingHistory.aggregate({
        where: { userId },
        _sum: { readDuration: true },
      }),
      this.prisma.readingHistory.findMany({
        where: { userId, progress: { gte: 95 } },
      }),
    ]);

    return {
      totalBooks,
      completedBooks: histories.length,
      totalDuration: totalDuration._sum.readDuration || 0,
      totalHours: Math.round((totalDuration._sum.readDuration || 0) / 3600 * 10) / 10,
    };
  }
}
