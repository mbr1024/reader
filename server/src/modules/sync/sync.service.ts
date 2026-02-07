import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SyncRequestDto } from './dto/sync.dto';

@Injectable()
export class SyncService {
  constructor(private readonly prisma: PrismaService) {}

  // 执行同步
  async sync(userId: string, dto: SyncRequestDto) {
    const now = new Date();
    const result: any = {
      success: true,
      syncedAt: now.toISOString(),
      data: {},
    };

    // 记录同步日志
    await this.prisma.syncLog.create({
      data: {
        userId,
        deviceId: dto.deviceId,
        syncType: dto.syncType,
        syncData: {
          bookshelfCount: dto.bookshelf?.length || 0,
          progressCount: dto.progress?.length || 0,
        },
      },
    });

    // 根据同步类型处理
    if (dto.syncType === 'bookshelf' || dto.syncType === 'all') {
      result.data.bookshelf = await this.syncBookshelf(userId, dto.bookshelf || []);
    }

    if (dto.syncType === 'progress' || dto.syncType === 'all') {
      result.data.progress = await this.syncProgress(userId, dto.progress || []);
    }

    if (dto.syncType === 'all') {
      result.data.bookmarks = await this.getBookmarks(userId);
    }

    return result;
  }

  // 同步书架
  private async syncBookshelf(userId: string, clientBookshelf: any[]) {
    // 获取服务端书架
    const serverBookshelf = await this.prisma.bookshelf.findMany({
      where: { userId },
      include: { book: true },
    });

    // 合并策略：以最近更新为准
    for (const item of clientBookshelf) {
      // 检查或创建 Book
      let book = await this.prisma.book.findFirst({
        where: {
          sourceId: item.sourceId,
          sourceType: item.sourceType,
        },
      });

      if (!book) {
        book = await this.prisma.book.create({
          data: {
            sourceId: item.sourceId,
            sourceType: item.sourceType,
            title: item.title,
            author: item.author,
            cover: item.cover,
          },
        });
      }

      // 更新或创建书架项
      // 使用客户端传来的 lastReadAt，如果没有则使用当前时间
      const lastReadAt = item.lastReadAt ? new Date(item.lastReadAt) : new Date();
      
      await this.prisma.bookshelf.upsert({
        where: {
          userId_bookId: { userId, bookId: book.id },
        },
        update: {
          lastChapter: item.lastChapter,
          lastPosition: item.lastPosition,
          isTop: item.isTop,
          lastReadAt,
        },
        create: {
          userId,
          bookId: book.id,
          lastChapter: item.lastChapter,
          lastPosition: item.lastPosition,
          isTop: item.isTop,
          lastReadAt,
        },
      });
    }

    // 返回合并后的书架
    return this.prisma.bookshelf.findMany({
      where: { userId },
      include: { book: true },
      orderBy: [{ isTop: 'desc' }, { lastReadAt: 'desc' }],
    });
  }

  // 同步阅读进度
  private async syncProgress(userId: string, clientProgress: any[]) {
    for (const item of clientProgress) {
      // 更新阅读历史
      await this.prisma.readingHistory.upsert({
        where: {
          userId_bookId: { userId, bookId: item.bookId },
        },
        update: {
          lastChapter: item.lastChapter,
          progress: item.progress,
          lastReadAt: new Date(),
        },
        create: {
          userId,
          bookId: item.bookId,
          sourceId: item.sourceId || '',
          sourceType: item.sourceType || '',
          bookTitle: item.title || '',
          bookAuthor: item.author || '',
          lastChapter: item.lastChapter,
          progress: item.progress,
        },
      });
    }

    // 返回所有阅读进度
    return this.prisma.readingHistory.findMany({
      where: { userId },
      orderBy: { lastReadAt: 'desc' },
    });
  }

  // 获取书签
  private async getBookmarks(userId: string) {
    return this.prisma.bookmark.findMany({
      where: { userId },
      include: {
        book: true,
        chapter: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  // 获取上次同步信息
  async getLastSync(userId: string, deviceId?: string) {
    const where: any = { userId };
    if (deviceId) {
      where.deviceId = deviceId;
    }

    const lastSync = await this.prisma.syncLog.findFirst({
      where,
      orderBy: { syncedAt: 'desc' },
    });

    return {
      lastSyncAt: lastSync?.syncedAt || null,
      deviceId: lastSync?.deviceId || null,
      syncType: lastSync?.syncType || null,
    };
  }

  // 获取完整同步数据 (用于新设备)
  async getFullSyncData(userId: string) {
    const [bookshelf, histories, bookmarks] = await Promise.all([
      this.prisma.bookshelf.findMany({
        where: { userId },
        include: { book: true },
        orderBy: [{ isTop: 'desc' }, { lastReadAt: 'desc' }],
      }),
      this.prisma.readingHistory.findMany({
        where: { userId },
        orderBy: { lastReadAt: 'desc' },
      }),
      this.prisma.bookmark.findMany({
        where: { userId },
        include: { book: true, chapter: true },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    return {
      bookshelf,
      readingHistories: histories,
      bookmarks,
      syncedAt: new Date().toISOString(),
    };
  }
}
