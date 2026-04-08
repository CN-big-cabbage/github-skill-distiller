#!/bin/bash
set -e
SKILL_NAME=${1:-"my-skill"}
echo "=== 技能快速创建 ==="
echo "技能名称: $SKILL_NAME"
mkdir -p $SKILL_NAME/{guides,configs}
cp templates/clawhub/SKILL.md.template $SKILL_NAME/SKILL.md
echo "✅ 技能框架已创建！"
