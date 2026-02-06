import { IsString, IsNumber, IsOptional, Min } from 'class-validator';

export class CreateBookmarkDto {
  @IsString()
  bookId: string;

  @IsString()
  sourceId: string;

  @IsString()
  sourceType: string;

  @IsString()
  bookTitle: string;

  @IsNumber()
  @Min(0)
  chapterIndex: number;

  @IsString()
  chapterTitle: string;

  @IsNumber()
  @Min(0)
  position: number;

  @IsOptional()
  @IsString()
  note?: string;

  @IsOptional()
  @IsString()
  content?: string; // 书签位置的内容摘要
}
