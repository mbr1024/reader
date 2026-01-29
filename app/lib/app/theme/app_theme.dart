import 'package:flutter/material.dart';

/// App 配色方案 - 现代大厂风格
/// 设计理念：高端、舒适、科技感
/// 主色调：蔚蓝/青色 (Blue/Teal)
class AppColors {
  // 品牌色 - 蔚蓝
  static const Color primary = Color(0xFF1677FF);       // 阿里蓝/蚂蚁蓝风格
  static const Color primaryLight = Color(0xFF4096FF);  // 浅蓝
  static const Color primaryDark = Color(0xFF0958D9);   // 深蓝
  static const Color secondary = Color(0xFF13C2C2);     // 明青色 (用于点缀)
  
  // 背景色 - 极简灰白
  static const Color background = Color(0xFFF5F7FA);    // 极浅蓝灰背景，更有质感
  static const Color surface = Color(0xFFFFFFFF);       // 纯白
  static const Color surfaceVariant = Color(0xFFF0F5FF); // 品牌色相近的浅色容器
  
  // 文字色
  static const Color textPrimary = Color(0xFF1F1F1F);   // 主要文字
  static const Color textSecondary = Color(0xFF595959); // 次要文字
  static const Color textMuted = Color(0xFF8C8C8C);     // 辅助文字
  static const Color textHint = Color(0xFFBFBFBF);      // 提示文字
  
  // 边框与分割
  static const Color border = Color(0xFFD9D9D9);        // 一般边框
  static const Color divider = Color(0xFFF0F0F0);       // 分割线
  
  // 功能色
  static const Color success = Color(0xFF52C41A);       // 成功绿
  static const Color warning = Color(0xFFFAAD14);       // 警告黄  
  static const Color error = Color(0xFFFF4D4F);         // 错误红
  
  // 阅读主题色 - 保持舒适
  static const Color readingWhite = Color(0xFFFAF9DE);  // 羊皮纸色
  static const Color readingGreen = Color(0xFFC7EDCC);  // 护眼绿
  static const Color readingDark = Color(0xFF1A1A1A);   // 夜间模式
}

// 兼容旧的 TomatoColors 引用，方便过渡，实际指向新颜色
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
  // 现代大厂风格 - 浅色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.surfaceVariant, // 使用较浅的变体
      secondary: AppColors.secondary,
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
      scrolledUnderElevation: 0, // 移除滚动时的阴影
      backgroundColor: AppColors.surface, // 纯白导航栏
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    
    cardTheme: CardThemeData(
      elevation: 2, // 轻微阴影
      shadowColor: Color(0x1A000000), // 柔和阴影色
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 大圆角
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant, // 浅蓝灰色背景输入框
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.textHint),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
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
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: AppColors.primary,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
    ),
    
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5,
      space: 1,
    ),
    
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary), // 常用标题
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary), // 正文
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textMuted), // 说明文字
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    ),
  );
  
  // 保持兼容
  static ThemeData get tomatoTheme => lightTheme;
}
