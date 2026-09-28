#!/usr/bin/env bash
# deploy.sh — 把构建产物推送到 GitHub Pages
# 用法:  FN_STORE_BASE_URL=https://yourname.github.io/fn-repo ./deploy.sh
# 前提:  git 已配置 GitHub 远程仓库、已安装 gh CLI 并授权

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 获取 GitHub Pages 基础 URL（如果没设就自动从 gh 查）
if [ -z "$FN_STORE_BASE_URL" ]; then
    if command -v gh &>/dev/null; then
        REPO_OWNER="$(gh repo view --json owner -q .owner.login)"
        REPO_NAME="$(gh repo view --json name -q .name)"
        BRANCH="main"
        # GitHub Pages URL 通常是 https://owner.github.io/repo/
        FN_STORE_BASE_URL="https://${REPO_OWNER}.github.io/${REPO_NAME}"
        echo "自动获取 Pages URL: $FN_STORE_BASE_URL"
    else
        echo "[ERROR] 请设置 FN_STORE_BASE_URL 环境变量（GitHub Pages 根 URL）"
        exit 1
    fi
fi

echo "Pages URL: $FN_STORE_BASE_URL"

# 1. 构建
FN_STORE_BASE_URL="$FN_STORE_BASE_URL" bash "$SCRIPT_DIR/build.sh" --base-url "$FN_STORE_BASE_URL"

# 2. 把 dist 内容同步到仓库根目录（Pages 服务根目录）
echo "同步 dist → 仓库根目录..."
cp -r dist/* .
# fnpack.json 放到根目录（Pages 要求根目录有 fnpack.json 或指定目录）

# 3. 提交并推送
git add fnpack.json
git add -f fpk/ icons/ previews/ 2>/dev/null || true
git commit -m "release: $(date +%Y%m%d_%H%M)"
git push

echo "✅ 部署完成"
echo "   FnDepot 源地址: $FN_STORE_BASE_URL/fnpack.json"
echo "   在 FnDepot 客户端 → 添加源 → 填入上面的 URL 即可"
