<p align="center">
  <img src="app/assets/images/app_icon.png" width="120" alt="绯页 Logo">
</p>

<h1 align="center">绯页</h1>

<p align="center">
  <strong>沉浸式阅读，轻盈如页</strong>
</p>

<p align="center">
  一款追求极致阅读体验的现代小说阅读器
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/NestJS-10.x-E0234E?logo=nestjs" alt="NestJS">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" alt="Platform">
</p>

---

## ✨ 特性

- 📖 **沉浸阅读** — 简约界面设计，专注内容本身
- 🎨 **现代简约** — 遵循现代设计语言，告别臃肿
- 🌙 **护眼模式** — 多种主题配色，呵护双眼
- 📚 **智能书架** — 自动同步阅读进度，无缝切换设备
- ⚡ **流畅体验** — 原生性能，极速响应
- 🔄 **章节无缝切换** — 滚动到边界自动加载上下章

## 📱 截图

<!-- 可添加应用截图 -->

## 🚀 快速开始

### 环境要求

- Node.js 18+
- Flutter 3.x
- Docker

### 开发运行

```bash
# 克隆项目
git clone https://github.com/mbr1024/reader.git
cd reader

# 一键初始化
./scripts/setup.sh

# 或手动启动
docker-compose up -d          # 启动数据库
cd server && npm run start:dev  # 启动后端
cd app && flutter run           # 启动应用
```

### 打包发布

```bash
cd app

# 复制配置模板并填入服务器地址
cp build_release.sh build_release.local.sh
# 编辑 build_release.local.sh 填入 API_URL

# 打包 APK
./build_release.local.sh apk
```

## 🏗️ 技术架构

| 层级 | 技术栈 |
|------|--------|
| 移动端 | Flutter + Riverpod + GoRouter |
| 后端 | NestJS + Prisma + PostgreSQL |
| 部署 | Docker + GitHub Actions |

## 📁 项目结构

```
绯页/
├── app/                  # Flutter 移动端
│   ├── lib/
│   │   ├── app/          # 应用配置、路由、主题
│   │   ├── core/         # 核心服务、模型
│   │   ├── features/     # 功能模块
│   │   └── shared/       # 共享组件
│   └── assets/           # 静态资源
├── server/               # NestJS 后端
│   ├── src/modules/      # 业务模块
│   └── prisma/           # 数据库模型
├── DESIGN_SYSTEM.md      # 设计语言规范
├── DEVELOPMENT.md        # 开发计划文档
└── docker-compose.yml    # Docker 配置
```

## 📖 文档

- [开发计划](./DEVELOPMENT.md) — 功能规划与开发进度
- [设计规范](./DESIGN_SYSTEM.md) — UI/UX 设计语言

## 📄 许可

本项目仅供学习交流使用。

---

<p align="center">
  <sub>用心阅读，静享绯页</sub>
</p>
