import 'package:flutter/material.dart';

/// App 配色方案 - 简洁现代风格
/// 设计理念：极简、留白、高级感
/// 参考：Linear / Notion / 微信读书
class AppColors {
  // 品牌色 - 深色系（主要用于强调）
  static const Color primary = Color(0xFF1A1A1A);       // 深黑
  static const Color primaryLight = Color(0xFF333333);  // 次深
  static const Color primaryDark = Color(0xFF000000);   // 纯黑
  static const Color accent = Color(0xFFE53935);        // 强调红（用于通知、错误）
  
  // 背景色 - 纯净白灰
  static const Color background = Color(0xFFFAFAFA);    // 极浅灰背景
  static const Color surface = Color(0xFFFFFFFF);       // 纯白
  static const Color surfaceVariant = Color(0xFFF5F5F5); // 输入框/卡片背景
  
  // 文字色 - 层级分明
  static const Color textPrimary = Color(0xFF1A1A1A);   // 主要文字
  static const Color textSecondary = Color(0xFF666666); // 次要文字
  static const Color textMuted = Color(0xFF999999);     // 辅助文字
  static const Color textHint = Color(0xFFBBBBBB);      // 提示文字
  static const Color textLight = Color(0xFFAAAAAA);     // 极淡文字
  
  // 边框与分割
  static const Color border = Color(0xFFE8E8E8);        // 边框
  static const Color divider = Color(0xFFF0F0F0);       // 分割线
  
  // 功能色
  static const Color success = Color(0xFF43A047);       // 成功绿
  static const Color warning = Color(0xFFFFA726);       // 警告黄  
  static const Color error = Color(0xFFE53935);         // 错误红
  
  // 阅读主题色
  static const Color readingWhite = Color(0xFFFAF9DE);  // 羊皮纸色
  static const Color readingGreen = Color(0xFFC7EDCC);  // 护眼绿
  static const Color readingDark = Color(0xFF1C1C1E);   // 夜间模式
}

// 兼容旧的 TomatoColors 引用
class TomatoColors {
  static const Color primary = AppColors.primary;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color primaryDark = AppColors.primaryDark;
  
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color surfaceLight = AppColors.surfaceVariant;
  
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;
  static const Color textHint = AppColors.textHint;
  
  static const Color divider = AppColors.divider;
  static const Color disabled = Color(0xFFD9D9D9);
  static const Color border = AppColors.border;
  
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error = AppColors.error;
}

class AppTheme {
  // 简洁现代风格 - 浅色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.surfaceVariant,
      secondary: AppColors.textSecondary,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    
    scaffoldBackgroundColor: AppColors.background,
    
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w400),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textMuted,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: AppColors.primary,
      labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
    ),
    
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    ),
  );
  
  // 保持兼容
  static ThemeData get tomatoTheme => lightTheme;
}
