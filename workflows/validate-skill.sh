#!/bin/bash
set -e

SKILL_DIR=${1:-"."}
echo "=== 技能验证检查 ==="
echo "技能目录: $SKILL_DIR"

ERRORS=0

# 检查必要文件
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
    echo "❌ 缺失文件: SKILL.md"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ 文件存在: SKILL.md"
fi

# 检查frontmatter
if [ -f "$SKILL_DIR/SKILL.md" ]; then
    if grep -q "^name:" "$SKILL_DIR/SKILL.md"; then
        echo "✅ frontmatter正确"
    else
        echo "❌ frontmatter缺少name"
        ERRORS=$((ERRORS + 1))
    fi
fi

# 验证结果
echo ""
echo "=== 验证结果 ==="
echo "错误数: $ERRORS"

if [ $ERRORS -eq 0 ]; then
    echo "✅ 验证通过！"
    exit 0
else
    echo "❌ 验证失败！"
    exit 1
fi
