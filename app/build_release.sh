#!/bin/bash
# Release 打包脚本
# 复制此文件为 build_release.local.sh 并填入你的服务器地址

API_URL="http://your-server:3000"

echo "Building with API_URL: $API_URL"

case "$1" in
  apk)
    flutter build apk --release --dart-define=API_URL=$API_URL
    echo "APK 输出: build/app/outputs/flutter-apk/app-release.apk"
    ;;
  aab)
    flutter build appbundle --release --dart-define=API_URL=$API_URL
    echo "AAB 输出: build/app/outputs/bundle/release/app-release.aab"
    ;;
  ios)
    flutter build ios --release --dart-define=API_URL=$API_URL
    ;;
  *)
    echo "用法: $0 {apk|aab|ios}"
    exit 1
    ;;
esac
