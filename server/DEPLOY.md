# 服务端部署指南

## 🚀 自动化部署配置

本项目已配置 GitHub Actions 自动化部署，推送 `main` 分支的 `server/` 目录变更会自动触发部署。

## 📋 配置步骤

### 1. 配置 GitHub Secrets

进入 GitHub 仓库 → Settings → Secrets and variables → Actions，添加以下 Secrets：

| Secret 名称 | 值 |
|------------|---|
| `SERVER_HOST` | `115.191.16.227` |
| `SERVER_USER` | `root` |
| `SERVER_PASSWORD` | 你的服务器密码 |

### 2. 首次部署

首次部署时，GitHub Actions 会自动在服务器上：
- 安装 Docker（如未安装）
- 安装 Docker Compose（如未安装）
- 创建 `/opt/reader-server` 目录
- 复制代码并构建镜像
- 启动全部服务（App + PostgreSQL + Redis）

### 3. 后续部署

推送代码到 `main` 分支的 `server/` 目录后，会自动触发部署。

## 🔧 手动操作

### SSH 登录服务器
```bash
ssh root@115.191.16.227
```

### 查看服务状态
```bash
cd /opt/reader-server
docker compose -f docker-compose.prod.yml ps
```

### 查看日志
```bash
docker compose -f docker-compose.prod.yml logs -f app
```

### 重启服务
```bash
docker compose -f docker-compose.prod.yml restart
```

## 📁 文件结构

```
server/
├── Dockerfile              # 多阶段构建配置
├── docker-compose.prod.yml # 生产环境编排
├── .dockerignore           # Docker 构建忽略
├── .env.example            # 环境变量示例
└── scripts/
    └── deploy.sh           # 手动部署脚本

.github/
└── workflows/
    └── deploy-server.yml   # GitHub Actions 工作流
```

## 🌐 访问地址

- **API 地址**: http://115.191.16.227:3000
- **健康检查**: http://115.191.16.227:3000/health
