#!/bin/bash
# 开发环境运行脚本
# 复制此文件为 run_dev.local.sh 并填入你的服务器地址

# 生产服务器地址（必填）
API_URL="http://your-server:3000"

# 局域网 IP（可选，真机调试时使用）
LAN_IP="192.168.1.100"

# 是否使用真机（true/false）
USE_REAL_DEVICE="false"

flutter run \
  --dart-define=API_URL=$API_URL \
  --dart-define=LAN_IP=$LAN_IP \
  --dart-define=USE_REAL_DEVICE=$USE_REAL_DEVICE \
  "$@"
