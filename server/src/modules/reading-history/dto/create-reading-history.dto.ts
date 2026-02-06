import { IsString, IsNumber, IsOptional, Min, Max } from 'class-validator';

export class CreateReadingHistoryDto {
  @IsString()
  bookId: string;

  @IsString()
  sourceId: string;

  @IsString()
  sourceType: string;

  @IsString()
  bookTitle: string;

  @IsString()
  bookAuthor: string;

  @IsOptional()
  @IsString()
  bookCover?: string;

  @IsNumber()
  @Min(0)
  lastChapter: number;

  @IsOptional()
  @IsString()
  chapterTitle?: string;

  @IsNumber()
  @Min(0)
  @Max(100)
  progress: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  readDuration?: number;
}
