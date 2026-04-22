#!/bin/bash
set -e

SKILL_DIR=${1:?"用法: push-and-publish.sh <skill-dir> [repo-name]"}
REPO_NAME=${2:-""}

# 从 SKILL.md 读取元数据
SKILL_NAME=$(grep "^name:" "$SKILL_DIR/SKILL.md" | sed 's/^name:[[:space:]]*//')
SKILL_DESC=$(grep "^description:" "$SKILL_DIR/SKILL.md" | sed 's/^description:[[:space:]]*//')

if [ -z "$REPO_NAME" ]; then
    REPO_NAME="skill-${SKILL_NAME}"
fi

echo "=== 推送并发布技能 ==="
echo "技能: $SKILL_NAME"
echo "仓库: $REPO_NAME"

# === 1. 初始化 Git ===
echo ""
echo "[1/4] 初始化 Git 仓库..."
cd "$SKILL_DIR"

if [ ! -d ".git" ]; then
    git init
    git add -A
    git commit -m "feat: initial skill - $SKILL_NAME"
fi

# === 2. 创建 GitHub 仓库 ===
echo ""
echo "[2/4] 创建 GitHub 仓库..."

GH_USER=$(gh api user -q '.login')

if gh repo view "$GH_USER/$REPO_NAME" &>/dev/null; then
    echo "  仓库已存在: $GH_USER/$REPO_NAME"
else
    gh repo create "$REPO_NAME" --public --description "$SKILL_DESC"
    echo "  ✅ 仓库已创建"
fi

# === 3. 推送代码 ===
echo ""
echo "[3/4] 推送代码..."

if ! git remote get-url origin &>/dev/null; then
    git remote add origin "git@github.com:$GH_USER/$REPO_NAME.git"
else
    # 确保 remote 使用 SSH 而非 HTTPS
    git remote set-url origin "git@github.com:$GH_USER/$REPO_NAME.git"
fi

git push -u origin HEAD
echo "  ✅ 代码已推送"

# === 4. 发布到 ClawHub ===
echo ""
echo "[4/4] 发布到 ClawHub..."

if command -v clawhub &>/dev/null || command -v clawhub-cli &>/dev/null; then
    SKILL_VERSION=$(grep "^version:" "$SKILL_DIR/SKILL.md" | sed 's/^version:[[:space:]]*//' | tr -d '"' | head -1)
    SKILL_VERSION=${SKILL_VERSION:-"0.1.0"}
    clawhub publish . --slug "$SKILL_NAME" --version "$SKILL_VERSION"
    echo "  ✅ 已发布到 ClawHub"
    echo "  地址: https://clawhub.ai/skills/$SKILL_NAME"
else
    echo "  ⚠️  ClawHub CLI 未安装，跳过发布"
    echo "  安装后可手动发布: clawhub publish $SKILL_DIR"
fi

echo ""
echo "=== 完成 ==="
echo "GitHub: https://github.com/$GH_USER/$REPO_NAME"
