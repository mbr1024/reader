#!/bin/bash

# 小说阅读器项目 - 快速启动脚本
# 使用方法: ./scripts/setup.sh

set -e

echo "🚀 小说阅读器项目初始化..."
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ 请先安装 Docker"
    exit 1
fi

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 请先安装 Node.js (推荐 v18+)"
    exit 1
fi

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ 请先安装 Flutter"
    exit 1
fi

echo "✅ 环境检查通过"
echo ""

# 启动数据库
echo "📦 启动 Docker 容器 (PostgreSQL + Redis)..."
docker-compose up -d

# 等待数据库启动
echo "⏳ 等待数据库启动..."
sleep 5

# 安装后端依赖
echo ""
echo "📦 安装后端依赖..."
cd server
npm install

# 生成 Prisma 客户端
echo ""
echo "🔧 生成 Prisma 客户端..."
npx prisma generate

# 运行数据库迁移
echo ""
echo "🗄️ 运行数据库迁移..."
npx prisma migrate dev --name init

cd ..

# 安装 Flutter 依赖
echo ""
echo "📦 安装 Flutter 依赖..."
cd app
flutter pub get

cd ..

echo ""
echo "✅ 初始化完成!"
echo ""
echo "启动命令:"
echo "  后端: cd server && npm run start:dev"
echo "  App:  cd app && flutter run"
echo ""
