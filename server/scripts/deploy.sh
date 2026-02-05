#!/bin/bash
# 服务端部署脚本
# 在服务器上执行

set -e

APP_DIR="/opt/reader-server"
COMPOSE_FILE="docker-compose.prod.yml"

echo "🚀 开始部署 Reader Server..."

# 进入应用目录
cd $APP_DIR

# 拉取最新镜像
echo "📦 构建 Docker 镜像..."
docker build -t reader-server:latest .

# 停止旧容器
echo "⏹️  停止旧容器..."
docker compose -f $COMPOSE_FILE down --remove-orphans || true

# 启动新容器
echo "▶️  启动新容器..."
docker compose -f $COMPOSE_FILE up -d

# 等待服务健康
echo "⏳ 等待服务启动..."
sleep 10

# 检查健康状态
echo "🔍 检查服务状态..."
docker compose -f $COMPOSE_FILE ps

# 清理旧镜像
echo "🧹 清理未使用的镜像..."
docker image prune -f

echo "✅ 部署完成！"
echo "📊 服务状态："
docker compose -f $COMPOSE_FILE ps
