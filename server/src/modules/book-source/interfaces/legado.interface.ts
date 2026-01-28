// Legado 书源格式定义
export interface LegadoBookSource {
  bookSourceName: string;
  bookSourceUrl: string;
  bookSourceType?: number; // 0=文字, 1=音频
  bookSourceGroup?: string;
  enabled?: boolean;
  enabledExplore?: boolean;
  weight?: number;
  customOrder?: number;
  lastUpdateTime?: number;
  respondTime?: number;
  header?: string;

  // 搜索规则
  searchUrl?: string;
  ruleSearch?: {
    bookList?: string;
    name?: string;
    author?: string;
    intro?: string;
    coverUrl?: string;
    bookUrl?: string;
    kind?: string;
    lastChapter?: string;
    wordCount?: string;
  };

  // 详情规则
  ruleBookInfo?: {
    name?: string;
    author?: string;
    intro?: string;
    coverUrl?: string;
    kind?: string;
    lastChapter?: string;
    tocUrl?: string;
    wordCount?: string;
  };

  // 目录规则
  ruleToc?: {
    chapterList?: string;
    chapterName?: string;
    chapterUrl?: string;
    isVolume?: string;
    updateTime?: string;
  };

  // 正文规则
  ruleContent?: {
    content?: string;
    nextContentUrl?: string;
    webJs?: string;
    sourceRegex?: string;
    replaceRegex?: string;
  };

  // 发现规则
  exploreUrl?: string;
  ruleExplore?: {
    bookList?: string;
    name?: string;
    author?: string;
    intro?: string;
    coverUrl?: string;
    bookUrl?: string;
  };
}

// 书源解析结果
export interface ParsedBook {
  id: string;
  title: string;
  author: string;
  cover?: string;
  description?: string;
  category?: string;
  lastChapter?: string;
  bookUrl: string;
  source: string;
}

export interface ParsedChapter {
  id: string;
  title: string;
  url: string;
  index: number;
}
