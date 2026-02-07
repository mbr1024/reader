# 小说阅读器 - 开发文档

> 最后更新时间: 2026-02-07
> 当前进度: 核心功能已完成，待优化体验细节

---

## 项目概述

跨平台小说阅读器 App，支持 Android 和 iOS，提供在线阅读、本地书籍导入、离线缓存、用户系统、云同步和广告变现功能。

### 技术栈

| 层级 | 技术选型 |
|------|---------|
| 移动端 | Flutter 3.x + Riverpod + GoRouter + Hive |
| 后端 | NestJS + Prisma + PostgreSQL |
| 部署 | Docker + Docker Compose |

---

## 功能完成状态

### ✅ 已完成功能

#### 核心功能
| 功能 | 说明 | 状态 |
|------|------|------|
| 阅读进度持久化 | 退出后记住阅读位置、章节 | ✅ |
| 书架数据持久化 | 本地 Hive 存储书架 | ✅ |
| Token 持久化 | 登录后自动保持登录状态 | ✅ |
| 阅读设置持久化 | 记住字体大小、背景色、行间距 | ✅ |
| 本地书籍导入 | 支持 TXT、EPUB 格式导入 | ✅ |
| 用户认证 | 邮箱/手机号登录注册 | ✅ |

#### 阅读器功能
| 功能 | 说明 | 状态 |
|------|------|------|
| 字体大小调节 | 支持多种字号 | ✅ |
| 行间距调节 | 支持多种行高 | ✅ |
| 背景色主题 | 白/黄/绿/黑 多种主题 | ✅ |
| 目录跳转 | 快速跳转到指定章节 | ✅ |
| 进度条快速跳转 | 滑动进度条切换章节 | ✅ |
| 自动滚动 | 支持速度调节的自动阅读 | ✅ |
| 无限滚动加载 | 上下滑动自动加载章节 | ✅ |
| 屏幕常亮 | 阅读时保持屏幕常亮 | ✅ |

#### 云同步功能
| 功能 | 说明 | 状态 |
|------|------|------|
| 书架自动同步 | 登录用户无感同步书架 | ✅ |
| 阅读进度同步 | 多设备同步阅读位置 | ✅ |
| 书签云同步 | 服务端书签存储（App 端待完善） | ⏳ |

#### 广告功能
| 功能 | 说明 | 状态 |
|------|------|------|
| 广告基础架构 | AdConfig、AdService、AdItem | ✅ |
| Banner 广告组件 | 多种样式的横幅广告 | ✅ |
| 信息流广告组件 | 网格/列表两种样式 | ✅ |
| 插页广告组件 | 全屏广告（备用） | ✅ |
| 发现页广告位 | 精选推荐+信息流+底部 Banner | ✅ |
| 书架页广告位 | 网格中插入广告 | ✅ |
| 排行榜广告位 | 列表中插入广告 | ✅ |
| 书籍详情页广告位 | 信息卡片下方 Banner | ✅ |
| 阅读器广告位 | 章节间 Banner（每3章） | ✅ |
| 我的页面广告位 | 统计区下方 Banner | ✅ |

#### 页面功能
| 页面 | 功能 | 状态 |
|------|------|------|
| 发现页 | 推荐、热门、新书、搜索、分类入口 | ✅ |
| 书架页 | 书籍管理、本地导入、排序、置顶 | ✅ |
| 书籍详情 | 书籍信息、章节目录、加入书架 | ✅ |
| 阅读器 | 完整阅读体验 | ✅ |
| 排行榜 | 畅销/人气/新书/完结榜 | ✅ |
| 分类页 | 男频/女频/完本等分类筛选 | ✅ |
| 我的页面 | 用户信息、统计、设置入口 | ✅ |
| 阅读历史 | 历史记录展示和管理 | ✅ |
| 书签页 | 书签列表展示和管理 | ✅ |
| 设置页 | 应用设置 | ✅ |
| 登录/注册 | 邮箱、手机号、验证码 | ✅ |

#### 服务端模块
| 模块 | 功能 | 状态 |
|------|------|------|
| auth | 登录/注册/Token 刷新/登出 | ✅ |
| book-source | 书源管理、搜索、详情、章节 | ✅ |
| sync | 书架/进度/书签同步 | ✅ |
| bookmark | 书签 CRUD | ✅ |
| reading-history | 阅读历史管理 | ✅ |
| prisma | 数据库 ORM | ✅ |

---

### ⏳ 待完善功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 书签添加交互 | 阅读器内添加书签功能 | P1 |
| 在线章节持久化缓存 | 将在线书籍章节缓存到本地 | P2 |
| 亮度调节 | 阅读时调节屏幕亮度 | P3 |
| 真实广告 SDK | 接入 AdMob/穿山甲 | P1 |
| 开屏广告 | 应用启动时展示 | P2 |

---

### ❌ 未实现功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 翻页动效 | 仿真/滑动翻页效果 | P3 |
| App 签名配置 | Android/iOS 发布签名 | P4 |
| 应用商店素材 | 截图、描述、关键词 | P4 |

---

## 项目结构

```
reader/
├── app/                              # Flutter 移动端
│   ├── lib/
│   │   ├── main.dart                 # 入口文件
│   │   ├── app/                      # App 配置
│   │   │   ├── config/               # 应用配置
│   │   │   ├── router/               # 路由配置
│   │   │   └── theme/                # 主题配置
│   │   ├── features/                 # 功能模块
│   │   │   ├── auth/                 # 登录注册
│   │   │   ├── bookshelf/            # 书架
│   │   │   ├── book_detail/          # 书籍详情
│   │   │   ├── explore/              # 发现/搜索
│   │   │   ├── reader/               # 阅读器核心
│   │   │   ├── rank/                 # 排行榜
│   │   │   └── settings/             # 设置
│   │   ├── core/                     # 核心模块
│   │   │   ├── ads/                  # 广告模块
│   │   │   │   ├── ad_config.dart    # 广告配置
│   │   │   │   ├── ad_service.dart   # 广告服务
│   │   │   │   └── models/           # 广告模型
│   │   │   ├── models/               # 数据模型
│   │   │   ├── network/              # 网络层
│   │   │   └── services/             # 核心服务
│   │   │       ├── storage_service.dart      # 本地存储
│   │   │       ├── local_book_service.dart   # 本地书籍
│   │   │       ├── bookshelf_sync_service.dart # 书架同步
│   │   │       └── book_source_api.dart      # 书源 API
│   │   └── shared/                   # 共享组件
│   │       ├── widgets/
│   │       │   └── ads/              # 广告组件
│   │       └── utils/
│   └── pubspec.yaml
│
├── server/                           # NestJS 后端
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── modules/
│   │   │   ├── auth/                 # 认证模块
│   │   │   ├── book-source/          # 书源模块
│   │   │   ├── sync/                 # 同步模块
│   │   │   ├── bookmark/             # 书签模块
│   │   │   ├── reading-history/      # 阅读历史模块
│   │   │   └── prisma/               # 数据库模块
│   │   └── common/
│   │       └── guards/               # 认证守卫
│   ├── prisma/
│   │   └── schema.prisma             # 数据库模型
│   └── package.json
│
├── DEVELOPMENT.md                    # 本文档
├── DESIGN_SYSTEM.md                  # 设计系统文档
└── docker-compose.yml                # Docker 配置
```

---

## 本地存储设计 (Hive)

### Box 设计

| Box 名称 | 用途 | 数据结构 |
|---------|------|---------|
| `auth_box` | Token 存储 | accessToken, refreshToken, userId |
| `bookshelf_box` | 书架数据 | List\<BookshelfItem\> |
| `progress_box` | 阅读进度 | Map\<bookId, ReadingProgress\> |
| `settings_box` | 阅读设置 | ReaderSettings |
| `local_book_box` | 本地书籍 | Map\<bookId, LocalBookData\> |
| `bookmark_box` | 书签数据 | List\<BookmarkItem\> |

### 已注册的 TypeAdapter

| TypeId | 类型 |
|--------|------|
| 0 | BookshelfItem |
| 1 | ReadingProgress |
| 2 | ReaderSettings |
| 3 | BookmarkItem |

---

## 广告系统设计

### 广告配置 (AdConfig)

```dart
AdConfig.instance
  .adsEnabled           // 广告总开关
  .bannerEnabled        // Banner 广告开关
  .nativeEnabled        // 信息流广告开关
  .interstitialEnabled  // 插页广告开关
  .bookshelfAdInterval  // 书架页广告间隔（每 N 本书）
  .rankAdInterval       // 排行榜广告间隔（每 N 项）
  .readerChapterInterval // 阅读器广告间隔（每 N 章）
```

### 广告位置

| 页面 | 广告类型 | 位置 |
|------|---------|------|
| 发现页 | Banner | 精选推荐轮播中 |
| 发现页 | 信息流 | 热门推荐后 |
| 发现页 | Banner | 页面底部 |
| 书架页 | 信息流(网格) | 每 6 本书后 |
| 排行榜 | 信息流(列表) | 每 5 项后 |
| 书籍详情 | Banner | 信息卡片下方 |
| 阅读器 | Banner | 每 3 章后 |
| 我的页面 | Banner | 统计区下方 |

---

## 云同步设计

### 同步策略

- **触发条件**：登录后自动启动，每 5 分钟同步一次
- **同步内容**：书架数据（排除本地书籍）
- **认证方式**：JWT Token 自动附加
- **冲突处理**：以最新更新时间为准

### 同步流程

```
1. App 启动 / 用户登录
2. BookshelfSyncService.startAutoSync()
3. 每 5 分钟执行 _doSync()
4. 收集本地书架数据（排除 sourceId == 'local'）
5. 调用 /sync API (authPost)
6. 合并服务端返回的数据
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
npx prisma migrate dev
npm run start:dev

# Flutter App（本地开发）
cd app
./run_dev.local.sh

# 或标准方式
flutter run --dart-define=API_URL=http://your-server:3000
```

### 生产部署

```bash
# 服务器端
cd server
docker-compose -f docker-compose.prod.yml up -d
```

---

## 数据库设计

### 核心表

```sql
-- 用户表
users (id, email, phone, password_hash, nickname, avatar, ...)

-- 刷新令牌
refresh_tokens (id, user_id, token, expires_at, ...)

-- 书籍表
books (id, source_id, source_type, title, author, cover, ...)

-- 章节表
chapters (id, book_id, chapter_index, title, content, ...)

-- 书架表
bookshelves (id, user_id, book_id, last_chapter, is_top, ...)

-- 书签表
bookmarks (id, user_id, book_id, chapter_id, position, note, ...)

-- 阅读历史
reading_histories (id, user_id, book_id, last_chapter, progress, ...)

-- 同步日志
sync_logs (id, user_id, device_id, sync_type, sync_data, ...)
```

---

## 下一步工作

### P1 - 高优先级
1. **实现阅读器书签添加功能** - 在阅读器中长按或点击添加书签
2. **接入真实广告 SDK** - AdMob 或穿山甲

### P2 - 中优先级
3. **在线章节持久化缓存** - 将在线书籍章节缓存到 Hive
4. **开屏广告** - 应用启动展示

### P3 - 低优先级
5. **阅读器亮度调节** - 独立于系统亮度
6. **翻页动效** - 仿真翻页效果

---

*最后更新: 2026-02-07*
