#!/bin/bash
# Webhook 触发的自动部署脚本
# 路径: /opt/reader-server/scripts/webhook-deploy.sh

set -e

APP_DIR="/opt/reader-server"
LOG_FILE="/opt/reader-server/logs/deploy.log"

# 确保日志目录存在
mkdir -p $(dirname $LOG_FILE)

echo "========================================" >> $LOG_FILE
echo "[$(date)] 开始部署..." >> $LOG_FILE

cd $APP_DIR

# 拉取最新代码
echo "[$(date)] 拉取代码..." >> $LOG_FILE
git pull origin main >> $LOG_FILE 2>&1

# 重新构建镜像
echo "[$(date)] 构建 Docker 镜像..." >> $LOG_FILE
docker build -t reader-server:latest . >> $LOG_FILE 2>&1

# 重启服务
echo "[$(date)] 重启服务..." >> $LOG_FILE
docker compose -f docker-compose.prod.yml down >> $LOG_FILE 2>&1
docker compose -f docker-compose.prod.yml up -d >> $LOG_FILE 2>&1

# 清理旧镜像
docker image prune -f >> $LOG_FILE 2>&1

echo "[$(date)] ✅ 部署完成！" >> $LOG_FILE
echo "========================================" >> $LOG_FILE
