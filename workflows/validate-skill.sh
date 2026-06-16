#!/bin/bash
set -e

SKILL_DIR=${1:-"."}
echo "=== 技能验证检查 ==="
echo "技能目录: $SKILL_DIR"

ERRORS=0
WARNINGS=0

check_pass() { echo "  ✅ $1"; }
check_fail() { echo "  ❌ $1"; ERRORS=$((ERRORS + 1)); }
check_warn() { echo "  ⚠️  $1"; WARNINGS=$((WARNINGS + 1)); }

# === 1. 文件结构检查 ===
echo ""
echo "[1/4] 文件结构检查..."

[ -f "$SKILL_DIR/SKILL.md" ] && check_pass "SKILL.md 存在" || check_fail "缺失 SKILL.md"
[ -d "$SKILL_DIR/guides" ] && check_pass "guides/ 目录存在" || check_fail "缺失 guides/ 目录"
[ -f "$SKILL_DIR/troubleshooting.md" ] && check_pass "troubleshooting.md 存在" || check_warn "缺失 troubleshooting.md"

GUIDE_COUNT=$(find "$SKILL_DIR/guides" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
[ "$GUIDE_COUNT" -ge 1 ] && check_pass "guides/ 包含 $GUIDE_COUNT 个文档" || check_fail "guides/ 目录为空"

# === 2. Frontmatter 检查 ===
echo ""
echo "[2/4] Frontmatter 检查..."

if [ -f "$SKILL_DIR/SKILL.md" ]; then
    for field in name description version; do
        if grep -q "^${field}:" "$SKILL_DIR/SKILL.md"; then
            check_pass "frontmatter 包含 $field"
        else
            check_fail "frontmatter 缺少 $field"
        fi
    done
    
    # 检查 metadata.openclaw 是否存在
    if grep -q "metadata:" "$SKILL_DIR/SKILL.md" && grep -q "openclaw:" "$SKILL_DIR/SKILL.md"; then
        check_pass "frontmatter 包含 metadata.openclaw"
        
        # 检查 requires 字段格式（应该是对象，不是数组）
        # 提取 requires 部分，检查是否包含 bins: 或 env:
        if grep -A 10 "requires:" "$SKILL_DIR/SKILL.md" | grep -q "bins:\|env:"; then
            check_pass "metadata.openclaw.requires 格式正确（对象）"
        else
            # 检查是否是数组格式（以 - 开头）
            if grep -A 10 "requires:" "$SKILL_DIR/SKILL.md" | grep -q "^\s*-"; then
                check_fail "metadata.openclaw.requires 是数组格式，应该是对象（包含 bins: 或 env:）"
            else
                check_warn "metadata.openclaw.requires 格式不明确"
            fi
        fi
    else
        check_warn "frontmatter 缺少 metadata.openclaw（ClawHub 推荐）"
    fi
fi

# === 3. 占位符检查 ===
echo ""
echo "[3/4] 占位符检查..."

PLACEHOLDER_COUNT=$(grep -rn '{{[A-Z_]*}}' "$SKILL_DIR" --include="*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PLACEHOLDER_COUNT" -eq 0 ]; then
    check_pass "无未替换的占位符"
else
    check_fail "发现 $PLACEHOLDER_COUNT 处未替换的占位符 {{...}}"
    grep -rn '{{[A-Z_]*}}' "$SKILL_DIR" --include="*.md" 2>/dev/null | head -5 | while read line; do
        echo "    $line"
    done
fi

# === 4. 内容质量检查 ===
echo ""
echo "[4/4] 内容质量检查..."

if [ -f "$SKILL_DIR/SKILL.md" ]; then
    WORD_COUNT=$(wc -w < "$SKILL_DIR/SKILL.md" | tr -d ' ')
    [ "$WORD_COUNT" -ge 50 ] && check_pass "SKILL.md 内容充实 (${WORD_COUNT} 词)" || check_fail "SKILL.md 内容过少 (${WORD_COUNT} 词, 最少50)"
fi

# === 结果 ===
echo ""
echo "=== 验证结果 ==="
echo "错误: $ERRORS | 警告: $WARNINGS"

if [ $ERRORS -eq 0 ]; then
    echo "✅ 验证通过！"
    exit 0
else
    echo "❌ 验证失败！请修复以上 $ERRORS 个错误"
    exit 1
fi
