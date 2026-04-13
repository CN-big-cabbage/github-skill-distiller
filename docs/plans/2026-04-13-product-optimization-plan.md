# GitHub Skill Distiller 产品优化实施计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 提升生成质量、扩充案例库、优化 GitHub 元数据，为生态收录做准备

**Architecture:** 在 analyze-repo.sh 中增加项目类型识别输出到 project-profile.json，在 generate-skill.md 中增加分类型 prompt 策略和自评环节，将案例统一到 cases/ 目录，通过 GitHub API 设置元数据

**Tech Stack:** Shell (bash), Markdown, GitHub CLI (gh), jq

---

## Phase 1: 项目类型识别（analyze-repo.sh 增强）

### Task 1: 增加项目类型检测逻辑

**Files:**
- Modify: `scripts/analyze-repo.sh:57-67`

**Step 1: 在 analyze-repo.sh 的依赖检测之后，增加项目类型识别函数**

在 `# 检测依赖工具` 块之后（第67行后），插入类型检测逻辑：

```bash
# 检测项目类型
detect_project_type() {
    local dir="$1"
    
    # CLI 工具检测
    if [ -f "$dir/setup.py" ] && grep -q "entry_points\|console_scripts" "$dir/setup.py" 2>/dev/null; then
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
    if ls "$dir"/*.tf 2>/dev/null | head -1 &>/dev/null || [ -d "$dir/roles" ]; then
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
```

**Step 2: 在 project-profile.json 输出中添加 project_type 字段**

在 JSON 输出的 `"required_bins"` 行之后加入：

```json
  "project_type": "$PROJECT_TYPE",
```

**Step 3: 运行测试验证**

```bash
# 测试 CLI 工具识别
./scripts/analyze-repo.sh https://github.com/soimort/you-get /tmp/test-cli
cat /tmp/test-cli/project-profile.json | jq '.project_type'
# 预期: "cli"
```

**Step 4: Commit**

```bash
git add scripts/analyze-repo.sh
git commit -m "feat: add project type detection to analyze-repo.sh"
```

---

## Phase 2: 生成质量提升（generate-skill.md 增强）

### Task 2: 在 generate-skill.md 中增加分类型 prompt 策略

**Files:**
- Modify: `skills/generate-skill.md`
- Modify: `.claude/commands/generate-skill.md`（同步更新）

**Step 1: 在 Phase 1（项目分析）之后，Phase 2（生成技能内容）之前，插入类型适配章节**

在 `### Phase 2: 生成技能内容` 之前插入：

```markdown
### Phase 1.5: 类型适配策略

根据 project-profile.json 中的 `project_type` 字段选择对应的生成策略：

#### CLI 工具（project_type: "cli"）
- **SKILL.md 重点**: 命令速查表、常用参数组合、输出格式说明
- **guides 重点**: 按使用场景组织（如"下载视频"、"批量操作"），每个场景给出完整命令
- **troubleshooting 重点**: 参数错误、权限问题、环境变量配置

#### 库（project_type: "library"）
- **SKILL.md 重点**: API 参考、代码示例、返回值说明
- **guides 重点**: 集成到项目中的步骤、常用模式和最佳实践
- **troubleshooting 重点**: 导入错误、版本冲突、类型不匹配

#### 框架（project_type: "framework"）
- **SKILL.md 重点**: 架构概览、核心概念、扩展点
- **guides 重点**: 项目脚手架搭建、路由/中间件/插件配置
- **troubleshooting 重点**: 配置错误、插件兼容性、启动失败

#### Web 应用（project_type: "webapp"）
- **SKILL.md 重点**: 功能清单、部署选项、架构图
- **guides 重点**: 本地开发环境搭建、部署流程
- **troubleshooting 重点**: 端口冲突、依赖缺失、环境变量

#### DevOps 工具（project_type: "devops"）
- **SKILL.md 重点**: 架构图、组件关系、支持的平台
- **guides 重点**: 环境准备、集群部署、配置定制
- **troubleshooting 重点**: 网络问题、权限配置、版本兼容
```

**Step 2: 在 Phase 2 末尾增加自评环节**

在 `### Phase 3: 验证` 之前插入：

```markdown
### Phase 2.5: 内容自评

生成所有文件后，执行一轮交叉检查：

1. **事实核查**: 对照项目 README 和文档，确认所有命令、参数、输出示例是否真实存在，删除任何编造内容
2. **覆盖度检查**: 确认项目的核心功能是否都已覆盖，补充遗漏的重要功能
3. **类型匹配检查**: 确认生成内容是否符合该项目类型的侧重点（参考 Phase 1.5）
4. **可执行性检查**: 确认每个命令示例是否可以直接复制执行，参数是否完整
```

**Step 3: 同步更新 .claude/commands/generate-skill.md**

将 `skills/generate-skill.md` 的内容完整复制到 `.claude/commands/generate-skill.md`。

**Step 4: Commit**

```bash
git add skills/generate-skill.md .claude/commands/generate-skill.md
git commit -m "feat: add type-specific prompt strategies and self-review to generate-skill"
```

---

## Phase 3: 案例库重组

### Task 3: 创建 cases/ 目录并迁移现有案例

**Files:**
- Create: `cases/` 目录
- Move: `you-get/` → `cases/you-get/`
- Move: `paper-checking/` → `cases/paper-checking/`
- Modify: `README.md`（更新路径引用）

**Step 1: 创建 cases/ 目录并迁移**

```bash
mkdir -p cases
git mv you-get cases/you-get
git mv paper-checking cases/paper-checking
```

**Step 2: 更新 README.md 中对 you-get/ 和 paper-checking/ 的所有引用**

将 `you-get/` 替换为 `cases/you-get/`，将 `paper-checking/` 替换为 `cases/paper-checking/`。

**Step 3: 更新 generate-skill.md 中对 you-get/ 的引用**

将 `skills/generate-skill.md` 和 `.claude/commands/generate-skill.md` 中 `you-get/` 替换为 `cases/you-get/`。

**Step 4: 验证引用正确**

```bash
grep -rn "you-get/" --include="*.md" --include="*.sh" . | grep -v "cases/you-get" | grep -v ".git/"
# 预期: 无输出（所有引用已更新）
```

**Step 5: Commit**

```bash
git add -A
git commit -m "refactor: consolidate skill cases into cases/ directory"
```

### Task 4: 在 README 中添加案例展示章节

**Files:**
- Modify: `README.md`

**Step 1: 在"快速开始"章节之后，"项目结构"章节之前，添加案例展示**

```markdown
## 案例展示

| 项目 | 类型 | Stars | 技能链接 |
|------|------|-------|---------|
| [you-get](https://github.com/soimort/you-get) | CLI 工具 | 50k+ | [cases/you-get](cases/you-get/) |
| [paper-checking](案例来源) | Web 应用 | - | [cases/paper-checking](cases/paper-checking/) |

> 更多案例持续添加中...使用 `/generate-skill <github-url>` 生成你自己的技能！
```

**Step 2: 更新项目结构树中 you-get/ → cases/**

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add cases showcase section to README"
```

---

## Phase 4: 批量生成案例（6-8 个新案例）

### Task 5: 依次为候选项目生成技能

**Files:**
- Create: `cases/httpie/` — CLI 工具案例
- Create: `cases/rich/` — Python 库案例
- Create: `cases/fastapi/` — 框架案例
- Create: `cases/lazydocker/` — DevOps 工具案例
- Create: 其他 2-4 个案例（根据生成质量调整选择）

**Step 1: 为每个候选项目运行 generate-skill**

按以下顺序逐个生成，每个生成后检查质量：

```bash
# CLI 工具
/generate-skill https://github.com/httpie/cli

# Python 库
/generate-skill https://github.com/Textualize/rich

# 框架
/generate-skill https://github.com/fastapi/fastapi

# DevOps
/generate-skill https://github.com/jesseduffield/lazydocker
```

**Step 2: 每个案例生成后，将输出移动到 cases/ 目录**

```bash
cp -r /tmp/skill-gen-<repo>/skill/ cases/<repo-name>/
```

**Step 3: 运行验证**

```bash
./workflows/validate-skill.sh cases/<repo-name>
```

**Step 4: 更新 README 案例展示表格**

每添加一个案例，在表格中增加一行。

**Step 5: 每完成 2-3 个案例，集中 commit 一次**

```bash
git add cases/<name1> cases/<name2>
git commit -m "feat: add <name1> and <name2> skill cases"
```

---

## Phase 5: GitHub 元数据优化

### Task 6: 设置 GitHub Topics 和 Description

**Step 1: 通过 gh CLI 设置**

```bash
gh repo edit CN-big-cabbage/github-skill-distiller \
  --description "Distill GitHub projects into ready-to-publish AI skills in 5 minutes. Supports Claude Code, Codex, Cursor & more." \
  --add-topic claude-code \
  --add-topic ai-skills \
  --add-topic skill-generator \
  --add-topic github-automation \
  --add-topic claude \
  --add-topic ai-tools \
  --add-topic llm \
  --add-topic prompt-engineering \
  --add-topic developer-tools \
  --add-topic clawhub \
  --add-topic ai-workflow \
  --add-topic code-generation
```

**Step 2: 验证**

```bash
gh repo view CN-big-cabbage/github-skill-distiller --json description,repositoryTopics
```

### Task 7: 添加 README Badges

**Files:**
- Modify: `README.md`
- Modify: `README_EN.md`

**Step 1: 在 README.md 标题下方添加 badges**

```markdown
# GitHub Skill Distiller

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/CN-big-cabbage/github-skill-distiller?style=social)](https://github.com/CN-big-cabbage/github-skill-distiller)
[![Skills Generated](https://img.shields.io/badge/Skills_Generated-10%2B-brightgreen)](cases/)
[![Supported Tools](https://img.shields.io/badge/Supported_Tools-5-blue)](#兼容工具)
```

**Step 2: 在 README_EN.md 中添加相同 badges**

**Step 3: Commit**

```bash
git add README.md README_EN.md
git commit -m "docs: add badges to README"
```

### Task 8: 添加 GitHub Actions CI

**Files:**
- Create: `.github/workflows/validate-skills.yml`

**Step 1: 创建 CI 配置**

```yaml
name: Validate Skills

on:
  push:
    paths:
      - 'cases/**'
      - 'workflows/validate-skill.sh'
  pull_request:
    paths:
      - 'cases/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate all skill cases
        run: |
          FAIL=0
          for dir in cases/*/; do
            echo "--- Validating $dir ---"
            if ! ./workflows/validate-skill.sh "$dir"; then
              FAIL=1
            fi
          done
          exit $FAIL
```

**Step 2: 在 README badges 中添加 CI badge**

```markdown
[![Validate Skills](https://github.com/CN-big-cabbage/github-skill-distiller/actions/workflows/validate-skills.yml/badge.svg)](https://github.com/CN-big-cabbage/github-skill-distiller/actions)
```

**Step 3: Commit**

```bash
git add .github/workflows/validate-skills.yml README.md README_EN.md
git commit -m "ci: add GitHub Actions workflow for skill validation"
```

### Task 9: 创建首个 GitHub Release

**Step 1: 确保所有改动已推送**

```bash
git push origin main
```

**Step 2: 创建 Release**

```bash
gh release create v1.0.0 \
  --title "v1.0.0 - First Release" \
  --notes "$(cat <<'EOF'
## GitHub Skill Distiller v1.0.0

Distill GitHub projects into ready-to-publish AI skills in 5 minutes.

### Features
- One-command skill generation from any GitHub URL
- Project type detection (CLI, library, framework, webapp, devops)
- Type-specific content generation strategies
- Automated quality validation
- Dual-platform publishing (ClawHub + GitHub)
- 10+ skill cases included

### Supported Tools
- Claude Code
- OpenAI Codex CLI
- OpenCode
- Cursor
- Windsurf

### Skill Cases
See the `cases/` directory for generated skill examples covering CLI tools, libraries, frameworks, and DevOps tools.
EOF
)"
```

**Step 3: 验证**

```bash
gh release view v1.0.0
```

---

## Phase 6: 生态收录准备（第3-4周执行）

### Task 10: 提交 awesome-claude-code PR

**前提**: Stars >= 5, 案例 >= 8

**Step 1: Fork awesome-claude-code 仓库**

```bash
gh repo fork <awesome-claude-code-repo> --clone
```

**Step 2: 在合适的分类下添加条目**

```markdown
- [GitHub Skill Distiller](https://github.com/CN-big-cabbage/github-skill-distiller) - Distill GitHub projects into ready-to-publish AI skills in 5 minutes
```

**Step 3: 提交 PR，描述中附上 3-5 个案例链接**

### Task 11: 在 ClawHub 批量发布案例技能

**Step 1: 对 cases/ 下每个案例运行 push-and-publish.sh**

```bash
for dir in cases/*/; do
    name=$(basename "$dir")
    ./scripts/push-and-publish.sh "$dir" "skill-$name"
done
```

**Step 2: 记录所有发布的技能 URL**

**Step 3: 联系 ClawHub 团队展示成果**
