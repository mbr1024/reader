# 小说阅读器 - 开发计划文档

> 最后更新时间: 2026-01-28
> 当前进度: 阶段一完成 (项目初始化)

---

## 项目概述

跨平台小说阅读器 App，支持 Android 和 iOS，提供在线阅读、离线缓存、用户系统和广告变现功能。

### 技术栈

| 层级 | 技术选型 |
|------|---------|
| 移动端 | Flutter 3.x + Riverpod + GoRouter + Hive |
| 后端 | NestJS + Prisma + PostgreSQL + Redis |
| 部署 | Docker |

---

## 项目结构

```
reader/
├── app/                          # Flutter 移动端
│   ├── lib/
│   │   ├── main.dart             # 入口文件
│   │   ├── app/                  # App 配置
│   │   │   ├── config/           # 应用配置
│   │   │   ├── router/           # 路由配置
│   │   │   └── theme/            # 主题配置
│   │   ├── features/             # 功能模块
│   │   │   ├── auth/             # 登录注册
│   │   │   ├── bookshelf/        # 书架
│   │   │   ├── explore/          # 发现/搜索
│   │   │   ├── reader/           # 阅读器核心
│   │   │   └── settings/         # 设置
│   │   ├── core/                 # 核心工具类
│   │   └── shared/               # 共享组件
│   └── pubspec.yaml
│
├── server/                       # Node.js 后端
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── modules/
│   │   │   ├── auth/             # 认证模块 ✅
│   │   │   ├── user/             # 用户模块
│   │   │   ├── book/             # 书籍模块
│   │   │   ├── prisma/           # 数据库模块 ✅
│   │   │   └── sync/             # 同步模块
│   │   └── common/               # 公共模块
│   ├── prisma/
│   │   └── schema.prisma         # 数据库模型 ✅
│   └── package.json
│
├── DEVELOPMENT.md                # 本文档
└── docker-compose.yml            # Docker 配置
```

---

## 开发进度

### ✅ 阶段一：项目初始化 (已完成)

#### 1.1 Flutter App 初始化
- [x] 创建 Flutter 项目
- [x] 配置项目结构 (feature-first)
- [x] 集成核心依赖包
  - flutter_riverpod, riverpod_annotation
  - go_router
  - dio
  - hive, hive_flutter
  - flutter_screenutil
  - cached_network_image
  - connectivity_plus
- [x] 配置 App 主题 (亮色/暗色)
- [x] 配置路由系统

#### 1.2 后端初始化
- [x] 创建 NestJS 项目
- [x] 配置 Prisma + PostgreSQL
- [x] 创建数据库 Schema (6 张核心表)
- [x] 配置环境变量
- [x] 后端编译通过

#### 1.3 已创建的页面
- [x] 登录页 (`auth/presentation/pages/login_page.dart`)
- [x] 书架页 (`bookshelf/presentation/pages/bookshelf_page.dart`)
- [x] 发现页 (`explore/presentation/pages/explore_page.dart`)
- [x] 设置页 (`settings/presentation/pages/settings_page.dart`)
- [x] 阅读器页 (`reader/presentation/pages/reader_page.dart`)

#### 1.4 后端已完成模块
- [x] Prisma 模块 (`modules/prisma/`)
- [x] 认证模块 (`modules/auth/`)
  - 用户注册 API
  - 用户登录 API
  - Token 刷新 API
  - 退出登录 API
  - JWT 策略

---

### ⏳ 阶段二：用户系统 (待开发)

#### 2.1 后端 API
- [ ] 用户信息查询 API
- [ ] 用户信息更新 API
- [ ] 头像上传 API
- [ ] 密码重置 API

#### 2.2 App 端
- [ ] 登录页面完善 (表单验证、错误提示)
- [ ] 注册页面 UI
- [ ] Token 持久化存储 (Hive)
- [ ] 自动登录逻辑
- [ ] 个人中心页面完善

---

### ⏳ 阶段三：书籍与书架 (待开发)

#### 3.1 后端 API
- [ ] 书籍搜索 API
- [ ] 书籍详情 API
- [ ] 章节列表 API
- [ ] 章节内容 API
- [ ] 书架 CRUD API
- [ ] 阅读进度同步 API
- [ ] 第三方书源接口适配

#### 3.2 App 端
- [ ] 书架页面完善
  - 网格/列表视图切换
  - 长按管理 (删除、置顶)
  - 下拉刷新
- [ ] 书籍详情页
  - 封面、简介、目录
  - 加入书架 / 开始阅读
- [ ] 发现/搜索页面完善
  - 搜索功能对接 API
  - 分类浏览
  - 推荐列表

---

### ⏳ 阶段四：阅读器核心 (待开发)

#### 4.1 阅读引擎
- [ ] 文本分页算法优化
- [ ] 翻页效果
  - 仿真翻页 (curl effect)
  - 滑动翻页
  - 点击翻页
- [ ] 章节加载与预加载
- [ ] 阅读进度记录与恢复

#### 4.2 阅读设置
- [x] 字体大小调节 (基础实现)
- [x] 行间距调节 (基础实现)
- [x] 背景色主题 (白/黄/绿/黑)
- [ ] 亮度调节
- [x] 夜间模式 (基础实现)
- [ ] 屏幕常亮选项
- [ ] 设置持久化

#### 4.3 阅读辅助
- [x] 目录跳转 (基础实现)
- [x] 进度条快速跳转 (基础实现)
- [ ] 书签功能
- [ ] 搜索本书内容

---

### ⏳ 阶段五：离线阅读 (待开发)

#### 5.1 缓存系统
- [ ] 章节内容本地缓存 (Hive)
- [ ] 缓存管理 (清理、统计)
- [ ] 批量下载功能
  - 下载全部 / 下载后 N 章
  - 下载进度显示
  - 后台下载支持

#### 5.2 离线模式
- [ ] 网络状态检测
- [ ] 离线时自动读取缓存
- [ ] 离线书架标记

---

### ⏳ 阶段六：数据同步 (待开发)

#### 6.1 同步功能
- [ ] 阅读进度云同步
- [ ] 书架数据云同步
- [ ] 书签云同步
- [ ] 阅读设置云同步

#### 6.2 冲突处理
- [ ] 多设备同步冲突解决
- [ ] 增量同步策略

---

### ⏳ 阶段七：广告系统 (待开发)

#### 7.1 广告位设计
- [ ] 书架页底部 Banner
- [ ] 章节切换插屏 (可选)
- [ ] 开屏广告 (可选)

#### 7.2 广告 SDK 集成
- [ ] 预留广告组件接口
- [ ] AdMob / 穿山甲 SDK 集成

---

### ⏳ 阶段八：优化与发布 (待开发)

#### 8.1 性能优化
- [ ] 列表懒加载优化
- [ ] 图片缓存优化
- [ ] 内存管理优化

#### 8.2 发布准备
- [ ] App 图标与启动页
- [ ] Android 签名配置
- [ ] iOS 证书配置
- [ ] 应用商店素材准备

---

## 数据库设计

```sql
-- 用户表
users (
  id, email, phone, password_hash,
  nickname, avatar, created_at, updated_at
)

-- 刷新令牌表
refresh_tokens (
  id, user_id, token, expires_at, created_at
)

-- 书籍表
books (
  id, source_id, source_type,
  title, author, cover, description,
  category, status, created_at, updated_at
)

-- 章节表
chapters (
  id, book_id, chapter_index,
  title, content, word_count, created_at
)

-- 书架表
bookshelves (
  id, user_id, book_id,
  last_chapter, last_position,
  is_top, last_read_at, created_at, updated_at
)

-- 书签表
bookmarks (
  id, user_id, book_id, chapter_id,
  position, note, created_at
)

-- 同步记录表
sync_logs (
  id, user_id, device_id,
  sync_type, sync_data, synced_at
)
```

---

## 环境配置

### 后端环境变量 (`server/.env`)

```bash
# Database
DATABASE_URL="postgresql://reader:reader123@localhost:5432/reader_db?schema=public"

# JWT
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Server
PORT=3000
NODE_ENV=development
```

### 启动命令

```bash
# 后端
cd server
npm install
npx prisma generate
npx prisma migrate dev    # 需要先启动 PostgreSQL
npm run start:dev

# Flutter App
cd app
flutter pub get
flutter run
```

---

## 已知问题

### 1. Android Gradle 兼容性
- **问题**: Android 构建报错 `Unsupported class file major version 68`
- **原因**: Gradle 版本与 Java 版本不兼容
- **解决方案**: 更新 `app/android/gradle/wrapper/gradle-wrapper.properties` 中的 Gradle 版本

### 2. 第三方书源 API
- **状态**: 待确定
- **说明**: 需要后续对接具体的书源 API

### 3. 广告平台
- **状态**: 待确定
- **说明**: 预留广告位，后续选择 AdMob 或穿山甲

---

## 下一步工作

1. **修复 Android 构建问题** - 更新 Gradle 版本
2. **配置 Docker** - 启动 PostgreSQL + Redis
3. **数据库迁移** - 运行 `npx prisma migrate dev`
4. **实现阶段二** - 完善用户系统

---

## 参考资源

- [Flutter 官方文档](https://flutter.dev/docs)
- [NestJS 官方文档](https://docs.nestjs.com)
- [Prisma 官方文档](https://www.prisma.io/docs)
- [Riverpod 文档](https://riverpod.dev)
- [GoRouter 文档](https://pub.dev/packages/go_router)
