#!/bin/bash
# 分析 GitHub 项目，输出 project-profile.json
set -e

GITHUB_URL=${1:?"用法: analyze-repo.sh <github-url> [output-dir]"}
OUTPUT_DIR=${2:-"/tmp/skill-analysis"}

# 从 URL 提取 owner/repo
REPO_PATH=$(echo "$GITHUB_URL" | sed -E 's|https?://github\.com/||' | sed 's|\.git$||' | sed 's|/$||')
OWNER=$(echo "$REPO_PATH" | cut -d'/' -f1)
REPO=$(echo "$REPO_PATH" | cut -d'/' -f2)

echo "=== 项目分析 ==="
echo "仓库: $OWNER/$REPO"

mkdir -p "$OUTPUT_DIR"

# 1. 获取 GitHub 元数据
echo "[1/4] 获取 GitHub 元数据..."
METADATA=$(gh api "repos/$OWNER/$REPO" 2>/dev/null || echo '{}')

STARS=$(echo "$METADATA" | jq -r '.stargazers_count // 0')
DESCRIPTION=$(echo "$METADATA" | jq -r '.description // ""')
LANGUAGE=$(echo "$METADATA" | jq -r '.language // ""')
LICENSE=$(echo "$METADATA" | jq -r '.license.spdx_id // ""')
TOPICS=$(echo "$METADATA" | jq -r '[.topics[]?] | join(",")')
HOMEPAGE=$(echo "$METADATA" | jq -r '.homepage // ""')
DEFAULT_BRANCH=$(echo "$METADATA" | jq -r '.default_branch // "main"')

echo "  Stars: $STARS | Language: $LANGUAGE | License: $LICENSE"

# 2. Clone 到临时目录
echo "[2/4] 克隆仓库..."
CLONE_DIR="$OUTPUT_DIR/repo"
if [ -d "$CLONE_DIR" ]; then
    rm -rf "$CLONE_DIR"
fi
git clone --depth 1 "$GITHUB_URL" "$CLONE_DIR" 2>/dev/null

# 3. 扫描项目结构
echo "[3/4] 扫描项目结构..."
README_FILE=""
for f in README.md readme.md README.rst README.txt README; do
    if [ -f "$CLONE_DIR/$f" ]; then
        README_FILE="$f"
        break
    fi
done

HAS_DOCS="false"
if [ -d "$CLONE_DIR/docs" ] || [ -d "$CLONE_DIR/doc" ]; then
    HAS_DOCS="true"
fi

DOC_FILES=$(find "$CLONE_DIR" -maxdepth 2 -name "*.md" -not -path "*/\.*" | head -20 | sed "s|$CLONE_DIR/||g" | jq -R -s 'split("\n") | map(select(. != ""))')

# 检测依赖工具
REQUIRED_BINS="[]"
if [ -f "$CLONE_DIR/requirements.txt" ] || [ -f "$CLONE_DIR/setup.py" ] || [ -f "$CLONE_DIR/pyproject.toml" ]; then
    REQUIRED_BINS=$(echo '["python"]' | jq '.')
elif [ -f "$CLONE_DIR/package.json" ]; then
    REQUIRED_BINS=$(echo '["node", "npm"]' | jq '.')
elif [ -f "$CLONE_DIR/go.mod" ]; then
    REQUIRED_BINS=$(echo '["go"]' | jq '.')
elif [ -f "$CLONE_DIR/Cargo.toml" ]; then
    REQUIRED_BINS=$(echo '["cargo"]' | jq '.')
fi

# 检测项目类型
detect_project_type() {
    local dir="$1"

    # CLI 工具检测
    if [ -f "$dir/setup.py" ] && grep -q "entry_points\|console_scripts" "$dir/setup.py" 2>/dev/null; then
        echo "cli"
        return
    fi
    if [ -f "$dir/setup.cfg" ] && grep -q "entry_points\|console_scripts" "$dir/setup.cfg" 2>/dev/null; then
        echo "cli"
        return
    fi
    if [ -f "$dir/pyproject.toml" ] && grep -q "scripts\|console_scripts" "$dir/pyproject.toml" 2>/dev/null; then
        echo "cli"
        return
    fi
    if [ -f "$dir/package.json" ] && jq -e '.bin' "$dir/package.json" &>/dev/null; then
        echo "cli"
        return
    fi
    if [ -f "$dir/main.go" ] || ([ -d "$dir/cmd" ] && [ -f "$dir/go.mod" ]); then
        echo "cli"
        return
    fi

    # 框架检测
    if [ -f "$dir/setup.py" ] && grep -qE "middleware|plugin|extension|blueprint" "$dir/setup.py" 2>/dev/null; then
        echo "framework"
        return
    fi
    if [ -f "$dir/package.json" ] && jq -e '.keywords[]? | select(test("framework|middleware|plugin"))' "$dir/package.json" &>/dev/null; then
        echo "framework"
        return
    fi

    # DevOps 工具检测
    if ls "$dir"/*.yml "$dir"/*.yaml 2>/dev/null | head -1 | xargs grep -lq "ansible\|playbook\|tasks:" 2>/dev/null; then
        echo "devops"
        return
    fi
    if [ -f "$dir/Dockerfile" ] && [ -f "$dir/docker-compose.yml" -o -f "$dir/docker-compose.yaml" ]; then
        echo "webapp"
        return
    fi
    if ls "$dir"/*.tf &>/dev/null || [ -d "$dir/roles" ]; then
        echo "devops"
        return
    fi

    # Web 应用检测
    if [ -d "$dir/src" ] && ([ -d "$dir/public" ] || [ -d "$dir/static" ] || [ -d "$dir/templates" ]); then
        echo "webapp"
        return
    fi

    # 库（默认）
    if [ -f "$dir/setup.py" ] || [ -f "$dir/pyproject.toml" ] || [ -f "$dir/package.json" ] || [ -f "$dir/go.mod" ] || [ -f "$dir/Cargo.toml" ]; then
        echo "library"
        return
    fi

    echo "unknown"
}

PROJECT_TYPE=$(detect_project_type "$CLONE_DIR")
echo "  Type: $PROJECT_TYPE"

# 4. 输出 profile
echo "[4/4] 生成 project-profile.json..."
PROFILE="$OUTPUT_DIR/project-profile.json"
cat > "$PROFILE" <<ENDJSON
{
  "owner": "$OWNER",
  "repo": "$REPO",
  "url": "$GITHUB_URL",
  "stars": $STARS,
  "description": $(echo "$DESCRIPTION" | jq -R '.'),
  "language": "$LANGUAGE",
  "license": "$LICENSE",
  "topics": $(echo "$TOPICS" | jq -R 'split(",") | map(select(. != ""))'),
  "homepage": "$HOMEPAGE",
  "default_branch": "$DEFAULT_BRANCH",
  "readme_file": "$README_FILE",
  "has_docs": $HAS_DOCS,
  "doc_files": $DOC_FILES,
  "required_bins": $REQUIRED_BINS,
  "project_type": "$PROJECT_TYPE",
  "clone_dir": "$CLONE_DIR",
  "analyzed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
ENDJSON

echo ""
echo "✅ 分析完成！"
echo "Profile: $PROFILE"
echo "Clone: $CLONE_DIR"
