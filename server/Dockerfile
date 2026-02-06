# 多阶段构建 - NestJS 服务端
FROM node:20-alpine AS builder

WORKDIR /app

# 安装构建依赖（Prisma 需要 OpenSSL）
RUN apk add --no-cache openssl openssl-dev

# 复制依赖文件
COPY package*.json ./
COPY prisma ./prisma/

# 安装依赖
RUN npm ci

# 生成 Prisma Client（必须在 build 之前）
RUN npx prisma generate

# 复制源码并构建
COPY . .
RUN npm run build

# ============ 生产镜像 ============
FROM node:20-alpine AS production

WORKDIR /app

# 安装运行时依赖
RUN apk add --no-cache dumb-init openssl

# 创建非 root 用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

# 复制构建产物
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/prisma ./prisma
COPY --from=builder --chown=nestjs:nodejs /app/package*.json ./

# 切换到非 root 用户
USER nestjs

# 暴露端口
EXPOSE 3000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# 启动命令（prisma migrate deploy 需要数据库连接）
ENTRYPOINT ["dumb-init", "--"]
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main"]
