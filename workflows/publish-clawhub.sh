#!/bin/bash
# ClawHub技能发布脚本

set -e

SKILL_DIR=${1:-"."}

echo "=== ClawHub技能发布 ==="
echo "技能目录: $SKILL_DIR"

# 步骤1: 验证技能
echo "[1/6] 验证技能..."
if [ ! -f "workflows/validate-skill.sh" ]; then
    echo "❌ 验证脚本不存在"
    exit 1
fi

./workflows/validate-skill.sh $SKILL_DIR

# 步骤2: 检查ClawHub CLI
echo "[2/6] 检查ClawHub CLI..."
if ! command -v clawhub-cli &> /dev/null; then
    echo "⚠️  ClawHub CLI未安装"
    echo ""
    echo "ClawHub平台说明："
    echo "- ClawHub是一个AI技能发布平台"
    echo "- 官网: https://clawhub.ai"
    echo "- 当前状态: 平台正在开发中"
    echo ""
    echo "替代方案："
    echo "1. 将技能发布到GitHub（当前项目已支持）"
    echo "2. 等待ClawHub平台上线"
    echo "3. 使用其他AI技能平台（如LangChain Hub）"
    echo ""
    echo "当前你可以："
    echo "- 查看技能内容: cat $SKILL_DIR/SKILL.md"
    echo "- 测试技能命令: 直接向AI描述需求"
    echo "- 分享技能: 推送到GitHub仓库"
    exit 0
fi

# 步骤3: 打包技能
echo "[3/6] 打包技能..."
cd $SKILL_DIR
clawhub-cli pack
SKILL_BUNDLE="${SKILL_DIR}-bundle.tar.gz"
echo "✅ 打包完成: $SKILL_BUNDLE"

# 步骤4: 检查元数据
echo "[4/6] 检查元数据..."
skill_name=$(grep "^name:" SKILL.md | cut -d' ' -f2)
skill_desc=$(grep "^description:" SKILL.md | cut -d' ' -f2-)
skill_version=$(grep "^version:" SKILL.md | cut -d' ' -f2)

echo "技能名称: $skill_name"
echo "技能描述: $skill_desc"
echo "技能版本: $skill_version"

# 步骤5: 提交发布
echo "[5/6] 提交发布..."
clawhub-cli publish $SKILL_BUNDLE

# 步骤6: 完成提示
echo "[6/6] ✅ 发布成功！"
echo ""
echo "技能地址: https://clawhub.ai/skills/$skill_name"
echo ""
echo "后续动作:"
echo "1. 公告发布（博客、社区）"
echo "2. 收集用户反馈"
echo "3. 监控使用数据"
echo "4. 版本迭代"

cd ..