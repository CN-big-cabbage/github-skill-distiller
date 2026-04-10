#!/bin/bash
set -e

echo "=== 发布 you-get 技能到 ClawHub ==="

SKILL_DIR="./you-get"
VERSION="0.1.0"
CHANGELOG="Initial release - AI-powered web media downloader supporting 80+ websites"

echo "[1/3] 检查 ClawHub CLI..."
if ! command -v clawhub &> /dev/null; then
    echo "❌ ClawHub CLI 未安装"
    echo "安装方法: npm install -g @clawhub/cli"
    exit 1
fi

echo "✅ ClawHub CLI 已安装"

echo ""
echo "[2/3] 发布 you-get 技能到 ClawHub..."
clawhub publish "$SKILL_DIR" \
  --slug you-get \
  --name "you-get" \
  --version "$VERSION" \
  --changelog "$CHANGELOG"

echo ""
echo "[3/3] ✅ 发布完成！"
echo ""
echo "技能地址: https://clawhub.ai/skills/you-get"
