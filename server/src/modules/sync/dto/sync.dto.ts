import { IsString, IsOptional, IsObject, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

// 书架项
export class BookshelfItemDto {
  @IsString()
  bookId: string;

  @IsString()
  sourceId: string;

  @IsString()
  sourceType: string;

  @IsString()
  title: string;

  @IsString()
  author: string;

  @IsOptional()
  @IsString()
  cover?: string;

  lastChapter: number;
  lastPosition: number;
  isTop: boolean;
}

// 阅读进度
export class ReadingProgressDto {
  @IsString()
  bookId: string;

  lastChapter: number;
  lastPosition: number;
  progress: number;
}

// 同步请求
export class SyncRequestDto {
  @IsString()
  deviceId: string;

  @IsString()
  syncType: 'bookshelf' | 'progress' | 'bookmark' | 'all';

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => BookshelfItemDto)
  bookshelf?: BookshelfItemDto[];

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ReadingProgressDto)
  progress?: ReadingProgressDto[];

  @IsOptional()
  @IsObject()
  settings?: Record<string, any>;

  @IsOptional()
  lastSyncAt?: string; // ISO 时间戳
}

// 同步响应
export class SyncResponseDto {
  success: boolean;
  syncedAt: string;
  data?: {
    bookshelf?: any[];
    progress?: any[];
    bookmarks?: any[];
    settings?: Record<string, any>;
  };
  conflicts?: any[];
}
