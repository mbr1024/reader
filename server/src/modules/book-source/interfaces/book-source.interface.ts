// 书源接口定义
export interface IBookSource {
  // 书源标识
  id: string;
  name: string;
  baseUrl: string;

  // 搜索书籍
  search(keyword: string, page?: number): Promise<BookSearchResult[]>;

  // 获取书籍详情
  getBookDetail(bookId: string): Promise<BookDetail>;

  // 获取章节列表
  getChapterList(bookId: string): Promise<ChapterInfo[]>;

  // 获取章节内容
  getChapterContent(bookId: string, chapterId: string): Promise<string>;
}

// 搜索结果
export interface BookSearchResult {
  id: string;
  title: string;
  author: string;
  cover?: string;
  description?: string;
  category?: string;
  lastChapter?: string;
  status?: string; // ongoing | completed
  source: string; // 书源标识
}

// 书籍详情
export interface BookDetail {
  id: string;
  title: string;
  author: string;
  cover?: string;
  description?: string;
  category?: string;
  status?: string;
  lastChapter?: string;
  lastUpdateTime?: string;
  wordCount?: number;
  chapterCount?: number;
  source: string;
}

// 章节信息
export interface ChapterInfo {
  id: string;
  title: string;
  index: number;
  wordCount?: number;
}

// 章节内容
export interface ChapterContent {
  title: string;
  content: string;
  index: number;
  prevId?: string;
  nextId?: string;
}
