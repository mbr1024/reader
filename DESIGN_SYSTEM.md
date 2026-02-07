# 设计系统 Design System

本文档定义了应用的视觉设计语言，确保 UI 设计的一致性和延续性。

## 设计风格定义

**风格名称**: 现代极简主义 (Modern Minimalism) / 简约互联网风格

**核心理念**: 
- **Less is More** - 减少视觉噪音，突出内容本身
- **内容优先** - UI 服务于内容，而非抢夺注意力
- **克制用色** - 用最少的颜色传达最清晰的信息层级

**风格参考**: 
- Apple Human Interface Guidelines
- 微信读书、得到等阅读类应用
- 现代 SaaS 产品设计趋势

---

## 色彩系统 Color Palette

### 主色调 Primary Colors

| 名称 | 色值 | 用途 |
|------|------|------|
| Primary | `#1A1A1A` | 主要按钮、标题文字、选中状态 |
| Accent | `#E53935` | 强调元素、破坏性操作提示 |

### 中性色 Neutral Colors

| 名称 | 色值 | 用途 |
|------|------|------|
| Background | `#FAFAFA` | 页面背景 |
| Surface | `#FFFFFF` | 卡片、弹窗背景 |
| Surface Variant | `#F5F5F5` | 输入框背景、次级卡片 |
| Border | `#F0F0F0` | 分割线、边框 |
| Divider | `#EEEEEE` | 列表分割线 |

### 文字色 Text Colors

| 名称 | 色值 | 用途 |
|------|------|------|
| Text Primary | `#1A1A1A` | 标题、主要内容 |
| Text Secondary | `#666666` | 次要信息、图标 |
| Text Tertiary | `#999999` | 辅助说明、时间戳 |
| Text Placeholder | `#BBBBBB` | 占位符、禁用文字 |
| Text Disabled | `#CCCCCC` | 禁用状态 |

### 色彩使用原则

1. **克制原则**: 主色 (Primary) 仅用于关键交互元素（CTA 按钮、选中态）
2. **层级原则**: 通过灰度变化建立视觉层级，而非多种颜色
3. **强调原则**: Accent 色仅用于需要特别注意的元素（如删除操作）
4. **一致性原则**: 同类元素使用相同颜色，不随意变化

---

## 字体系统 Typography

### 字重规范 Font Weights

| 字重 | 值 | 用途 |
|------|-----|------|
| Bold | `w700` | 页面大标题 |
| Semibold | `w600` | 区块标题、重要信息 |
| Medium | `w500` | 按钮文字、列表标题 |
| Regular | `w400` | 正文、描述文字 |

### 字号规范 Font Sizes

| 场景 | 字号 | 字重 | 颜色 |
|------|------|------|------|
| 页面标题 | 28px | w700 | Primary |
| 区块标题 | 16px | w600 | Primary |
| 列表标题 | 15px | w600 | Primary |
| 正文内容 | 14-15px | w400 | Primary |
| 辅助说明 | 12-13px | w400 | Tertiary |
| 标签/角标 | 9-11px | w500 | 根据场景 |

### 排版原则

1. **对比鲜明**: 标题与正文字号差距明显（至少 4px）
2. **字重分层**: 标题用粗体，正文用常规，形成清晰层级
3. **颜色辅助**: 通过颜色深浅进一步强化主次关系
4. **行高舒适**: 正文行高 1.5-1.6，保证阅读舒适度

---

## 间距系统 Spacing

### 基础单位

基础间距单位: **8px**

### 常用间距

| 名称 | 值 | 用途 |
|------|-----|------|
| xs | 4px | 紧凑元素间距 |
| sm | 8px | 相关元素间距 |
| md | 16px | 组件内部间距 |
| lg | 24px | 区块间距、页面边距 |
| xl | 32px | 区块之间间距 |
| xxl | 48px | 大区块分隔 |

### 页面边距

- 水平边距: **24px**
- 顶部安全区: **16px**（SafeArea 之后）

---

## 圆角系统 Border Radius

| 场景 | 圆角值 |
|------|--------|
| 小型元素（标签、角标） | 4px |
| 中型元素（按钮、输入框） | 8-10px |
| 卡片、弹窗 | 12px |
| 底部弹窗顶部 | 20px |
| 圆形按钮 | 20-24px |
| 头像 | 50% (圆形) |

---

## 阴影系统 Shadows

### 设计原则

**轻量化阴影**: 本设计系统采用极轻或无阴影设计，通过背景色差异和边框建立层级。

### 阴影规范

| 场景 | 阴影参数 |
|------|----------|
| 卡片 | `0 2px 8px rgba(0,0,0,0.06)` |
| 封面图 | `0 2px 8px rgba(0,0,0,0.08)` |
| 底部导航 | 无阴影，使用顶部边框 `0.5px #F0F0F0` |
| 按钮 | 无阴影 (`elevation: 0`) |
| 弹窗 | 系统默认 |

---

## 图标系统 Icons

### 图标风格

- **风格**: 线性图标 (Outlined)
- **线宽**: 1.5-2px
- **来源**: Material Icons Outlined / 同风格自定义图标

### 图标尺寸

| 场景 | 尺寸 |
|------|------|
| 导航栏 | 24px |
| 列表项 | 20-22px |
| 小型操作 | 16-18px |
| 装饰性大图标 | 28-32px |

### 图标颜色

| 状态 | 颜色 |
|------|------|
| 默认 | `#666666` |
| 选中/激活 | `#1A1A1A` |
| 禁用 | `#CCCCCC` |
| 强调 | `#E53935` |

---

## 组件规范 Components

### 按钮 Buttons

#### 主要按钮 (Primary)
```
背景: #1A1A1A
文字: #FFFFFF
圆角: 20-24px (胶囊形)
内边距: 16px 水平, 8-12px 垂直
字号: 13-14px
字重: w500
阴影: 无
```

#### 次要按钮 (Secondary)
```
背景: 透明
边框: 1px #E0E0E0
文字: #1A1A1A
圆角: 同主要按钮
```

#### 文字按钮 (Text)
```
背景: 无
文字: #1A1A1A 或 #666666
```

### 输入框 Input Fields

```
背景: #F5F5F5 或 #FAFAFA
边框: 无 (聚焦时显示 1px #1A1A1A)
圆角: 10px
内边距: 14-16px
字号: 15px
占位符颜色: #BBBBBB
```

### 卡片 Cards

```
背景: #FAFAFA 或 #FFFFFF
圆角: 12px
内边距: 16px
阴影: 无或极轻 (0.06 opacity)
```

### 列表项 List Items

```
内边距: 14-16px 垂直, 24px 水平
分割线: 0.5px #EEEEEE (左侧留 54px 缩进)
图标-文字间距: 14px
箭头颜色: #CCCCCC
```

### 底部弹窗 Bottom Sheet

```
背景: #FFFFFF
顶部圆角: 20px
拖拽指示器: 36px × 4px, #E0E0E0, 圆角 2px
顶部内边距: 12px
```

### 底部导航栏 Bottom Navigation

```
背景: #FFFFFF
高度: 56px + SafeArea
顶部边框: 0.5px #F0F0F0
图标尺寸: 24px
选中颜色: #1A1A1A
未选中颜色: #999999
标签字号: 10px
```

---

## 动效规范 Motion

### 动效原则

1. **微妙自然**: 动效应该被感知但不被注意
2. **快速响应**: 持续时间 150-300ms
3. **缓动函数**: 使用 `Curves.easeInOut` 或 `Curves.easeOut`

### 常用动效

| 场景 | 持续时间 | 缓动 |
|------|----------|------|
| 按钮状态切换 | 150ms | easeInOut |
| 页面切换 | 300ms | easeOut |
| 弹窗出现 | 250ms | easeOut |
| 列表项出现 | 200ms | easeOut |

---

## 设计检查清单 Design Checklist

在设计新页面或组件时，请确认：

- [ ] 颜色是否在规定的色板范围内？
- [ ] 是否避免了多彩配色，保持黑白灰为主？
- [ ] 标题是否使用了足够粗的字重 (w600+)？
- [ ] 辅助文字是否使用了较浅的颜色 (#999999)？
- [ ] 间距是否遵循 8px 基础单位？
- [ ] 页面左右边距是否为 24px？
- [ ] 按钮是否为零阴影设计？
- [ ] 图标是否使用线性风格？
- [ ] 卡片阴影是否足够轻量（或无阴影）？
- [ ] 是否有足够的留白，避免拥挤感？

---

## 设计禁忌 Don'ts

1. **不要** 使用高饱和度的彩色图标背景
2. **不要** 使用渐变色作为普通按钮背景
3. **不要** 使用重阴影（opacity > 0.1）
4. **不要** 在同一页面使用超过 2 种强调色
5. **不要** 使用全部相同字重的文字
6. **不要** 给图标添加背景色块
7. **不要** 使用 Glow/发光效果
8. **不要** 使用过小的字号（< 11px）
9. **不要** 忽略留白，避免元素过于拥挤

---

## Flutter 实现参考

### 主题配置位置

```
app/lib/app/theme/app_theme.dart
```

### 颜色常量

```dart
class AppColors {
  static const primary = Color(0xFF1A1A1A);
  static const accent = Color(0xFFE53935);
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFF999999);
  static const border = Color(0xFFF0F0F0);
  static const divider = Color(0xFFEEEEEE);
}
```

---

*最后更新: 2026-02-07*
