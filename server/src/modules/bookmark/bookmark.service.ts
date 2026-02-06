import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBookmarkDto } from './dto/create-bookmark.dto';

@Injectable()
export class BookmarkService {
  constructor(private readonly prisma: PrismaService) {}

  // 获取用户所有书签
  async findAll(userId: string, bookId?: string) {
    const where: any = { userId };
    if (bookId) {
      where.bookId = bookId;
    }

    // 由于 Bookmark 表原设计依赖 Book 和 Chapter 表，这里改为直接存储
    // 先查询现有书签数据
    const bookmarks = await this.prisma.$queryRaw`
      SELECT * FROM bookmarks WHERE user_id = ${userId}
      ${bookId ? this.prisma.$queryRaw`AND book_id = ${bookId}` : this.prisma.$queryRaw``}
      ORDER BY created_at DESC
    `;

    return bookmarks;
  }

  // 创建书签 (使用扩展表)
  async create(userId: string, dto: CreateBookmarkDto) {
    // 先检查或创建 Book
    let book = await this.prisma.book.findFirst({
      where: {
        sourceId: dto.sourceId,
        sourceType: dto.sourceType,
      },
    });

    if (!book) {
      book = await this.prisma.book.create({
        data: {
          sourceId: dto.sourceId,
          sourceType: dto.sourceType,
          title: dto.bookTitle,
          author: '',
        },
      });
    }

    // 检查或创建 Chapter
    let chapter = await this.prisma.chapter.findFirst({
      where: {
        bookId: book.id,
        chapterIndex: dto.chapterIndex,
      },
    });

    if (!chapter) {
      chapter = await this.prisma.chapter.create({
        data: {
          bookId: book.id,
          chapterIndex: dto.chapterIndex,
          title: dto.chapterTitle,
        },
      });
    }

    // 创建书签
    return this.prisma.bookmark.create({
      data: {
        userId,
        bookId: book.id,
        chapterId: chapter.id,
        position: dto.position,
        note: dto.note || dto.content,
      },
      include: {
        book: true,
        chapter: true,
      },
    });
  }

  // 删除书签
  async remove(userId: string, bookmarkId: string) {
    const bookmark = await this.prisma.bookmark.findFirst({
      where: {
        id: bookmarkId,
        userId,
      },
    });

    if (!bookmark) {
      throw new NotFoundException('书签不存在');
    }

    await this.prisma.bookmark.delete({
      where: { id: bookmarkId },
    });

    return { message: '删除成功' };
  }

  // 更新书签备注
  async updateNote(userId: string, bookmarkId: string, note: string) {
    const bookmark = await this.prisma.bookmark.findFirst({
      where: {
        id: bookmarkId,
        userId,
      },
    });

    if (!bookmark) {
      throw new NotFoundException('书签不存在');
    }

    return this.prisma.bookmark.update({
      where: { id: bookmarkId },
      data: { note },
    });
  }

  // 获取用户书签统计
  async getStats(userId: string) {
    const [total, bookCount] = await Promise.all([
      this.prisma.bookmark.count({ where: { userId } }),
      this.prisma.bookmark.groupBy({
        by: ['bookId'],
        where: { userId },
      }),
    ]);

    return {
      totalBookmarks: total,
      booksWithBookmarks: bookCount.length,
    };
  }

  // 清空某本书的所有书签
  async clearByBook(userId: string, bookId: string) {
    await this.prisma.bookmark.deleteMany({
      where: { userId, bookId },
    });
    return { message: '已清空该书籍的所有书签' };
  }
}
