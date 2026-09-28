# fn-store — 飞牛 fnOS 自有应用仓库脚手架

一个开箱即用的飞牛 NAS 应用分发仓库，支持 **FnDepot V2 源规范**，基于 **GitHub Pages** 免费托管。

## 目录结构

```
fn-store/
├── build.py                  # 核心构建脚本（Python）
├── build.sh                  # 一键构建入口（Bash）
├── deploy.sh                 # 推送到 GitHub Pages（Bash + git + gh）
├── apps/                     # 所有应用源码（每个子目录一个应用）
│   └── hello-fn/             # 示例：静态页面应用
│       ├── manifest          # fnpack manifest（应用元数据）
│       ├── app.json          # 仓库元数据（平台/分类/图标等）
│       ├── app/              # 前端/后端文件
│       │   ├── ui/           # 桌面入口 UI
│       │   └── www/          # 静态页面内容
│       ├── cmd/              # 生命周期脚本（start/stop/status 等）
│       ├── config/           # 权限 + 共享文件夹配置
│       ├── wizard/           # 安装/卸载/配置向导
│       ├── ICON.PNG          # 64×64 图标
│       ├── ICON_256.PNG      # 256×256 图标
│       └── icons/            # 仓库用图标（可选，自动复制到 dist）
└── dist/                     # 构建产物（不提交到 git，deploy 时同步）
    ├── fnpack.json           # V2 源索引
    ├── fpk/                  # 所有 .fpk 安装包
    ├── icons/                # 图标
    └── previews/             # 预览图
```

## 快速开始

### 1. 本地构建

```bash
# 设置环境变量（可选）
export FN_STORE_NAME="我的飞牛仓库"
export FN_STORE_AUTHOR="fn-store"

# 构建（fnpack 在 bin/ 目录自动查找）
bash build.sh
```

### 2. 推送到 GitHub Pages

```bash
# 设置 Pages URL
export FN_STORE_BASE_URL="https://yourname.github.io/fn-repo"

# 构建 + 提交 + 推送
bash deploy.sh
```

### 3. 用户在 FnDepot 添加源

在 FnDepot 客户端 → 添加源 → 填入：
```
https://yourname.github.io/fn-repo/fnpack.json
```

## 添加新应用

```bash
# 1. 创建应用项目
fnpack create my-app
# 将 my-app 目录移到 apps/ 下
mv my-app apps/

# 2. 添加仓库元数据
cat > apps/my-app/app.json << 'EOF'
{
  "display_name": "我的应用",
  "desc": "应用描述",
  "platform": ["all"],
  "categories": ["系统工具"],
  "run_as": "package",
  "install_type": "",
  "is_docker": false,
  "maintainer": "你的名字"
}
EOF

# 3. 构建验证
bash build.sh
```

## app.json 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `display_name` | ✅ | 应用显示名 |
| `desc` | ✅ | 简介（支持 HTML） |
| `platform` | ✅ | `["all"]` / `["x86"]` / `["arm"]` / 混合 |
| `categories` | ✅ | 从 9 大固定分类中选，最多 2 个 |
| `run_as` | ✅ | `"package"` 或 `"root"` |
| `install_type` | ✅ | `""` = 存储空间，`"root"` = 系统空间 |
| `is_docker` | ✅ | 是否 Docker 应用 |
| `icon_url` | 可选 | 仓库图标（默认用 `icons/icon.png`） |
| `preview_urls` | 可选 | 预览图（最多 8 张） |

**9 大固定分类**：`影音娱乐` / `系统工具` / `编程开发` / `AI赋能` / `生活服务` / `智能智控` / `教育学习` / `游戏地带` / `硬件驱动`

## 发布新版本

1. 修改 `apps/xxx/manifest` 中的 `version`
2. 修改 `apps/xxx/app.json`（可选：更新 desc、changelog）
3. 运行 `bash deploy.sh`

## GitHub 仓库设置

1. 在 GitHub 创建空仓库（与本项目同名）
2. 开启 **Settings → Pages → GitHub Pages → Main branch / root**
3. 确保 `fnpack.json` 和 `fpk/` 目录在仓库根目录
