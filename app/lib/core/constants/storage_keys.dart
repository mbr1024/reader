/// 存储 Key 常量
class StorageKeys {
  // Box 名称
  static const String authBox = 'auth_box';
  static const String bookshelfBox = 'bookshelf_box';
  static const String progressBox = 'progress_box';
  static const String settingsBox = 'settings_box';
  static const String cacheBox = 'cache_box';
  static const String localBooksBox = 'local_books_box'; // bookId -> filePath
  static const String localChaptersIndexBox = 'local_ch_index'; // bookId -> JSON章节列表
  static const String localChaptersContentBox = 'local_ch_content'; // bookId_idx -> 内容
  static const String bookmarkBox = 'bookmark_box'; // 书签存储
  
  // Auth Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  
  // Settings Keys
  static const String fontSize = 'font_size';
  static const String lineHeight = 'line_height';
  static const String backgroundColor = 'background_color';
  static const String brightness = 'brightness';
  static const String keepScreenOn = 'keep_screen_on';
}
