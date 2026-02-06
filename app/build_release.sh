#!/bin/bash
# Release 打包脚本
# 确保 .env 文件已配置正确的 API_URL

if [ ! -f .env ]; then
  echo "错误: 未找到 .env 文件，请先创建并配置 API_URL"
  exit 1
fi

echo "使用 .env 环境变量打包..."

case "$1" in
  apk)
    flutter build apk --release --dart-define-from-file=.env
    echo "APK 输出: build/app/outputs/flutter-apk/app-release.apk"
    ;;
  aab)
    flutter build appbundle --release --dart-define-from-file=.env
    echo "AAB 输出: build/app/outputs/bundle/release/app-release.aab"
    ;;
  ios)
    flutter build ios --release --dart-define-from-file=.env
    ;;
  *)
    echo "用法: $0 {apk|aab|ios}"
    exit 1
    ;;
esac
