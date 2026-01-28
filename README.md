# 小说阅读器

跨平台小说阅读器 App，支持 Android 和 iOS。

## 技术栈

- **移动端**: Flutter + Riverpod + GoRouter
- **后端**: NestJS + Prisma + PostgreSQL

## 快速开始

### 环境要求

- Node.js 18+
- Flutter 3.x
- Docker

### 一键初始化

```bash
./scripts/setup.sh
```

### 手动启动

```bash
# 1. 启动数据库
docker-compose up -d

# 2. 启动后端
cd server
npm install
npx prisma generate
npx prisma migrate dev
npm run start:dev

# 3. 启动 App
cd app
flutter pub get
flutter run
```

## 开发文档

详细开发计划和进度请查看 [DEVELOPMENT.md](./DEVELOPMENT.md)

## 项目结构

```
reader/
├── app/                # Flutter 移动端
├── server/             # NestJS 后端
├── docker-compose.yml  # Docker 配置
├── DEVELOPMENT.md      # 开发计划文档
└── scripts/            # 脚本工具
```
