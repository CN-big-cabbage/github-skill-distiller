# Skill Creation Methodology

[English](./README_EN.md) | 中文

完整的 AI 技能创建方法论框架，帮助开发者将 GitHub 项目转换为 AI 技能并发布到开源社区。

## 项目简介

传统方式创建 AI 技能需要 20-30 小时，本方法论采用**快速迭代式**，将时间压缩到 **5-6 小时**，节省 75% 的时间。

核心理念：**给定一个 GitHub URL，自动分析项目、生成技能、验证质量、推送发布**。

## 功能特性

- **一键生成**: 输入 GitHub URL，自动分析项目并生成完整技能包
- **智能分析**: 自动提取项目元数据（stars、语言、依赖、文档结构）
- **AI 驱动内容生成**: 基于项目文档智能生成 SKILL.md、使用指南、故障排查
- **自动化验证**: 文件结构、frontmatter、占位符、内容质量四维检查
- **双平台发布**: 支持 ClawHub + GitHub Marketplace
- **多工具兼容**: 支持 Claude Code、Codex、OpenCode 等主流 AI 编程工具
- **完整方法论**: 8 个核心文档覆盖从调研到维护的全生命周期
- **可复用模板**: SKILL.md、指南、故障排查模板开箱即用
- **参考示例**: 3 个难度梯度的示例项目 + 1 个生产级案例（you-get）

## 快速开始

### 第一步：下载项目

```bash
# 方式1: 使用 git clone（推荐）
git clone https://github.com/CN-big-cabbage/skill-creation-methodology.git
cd skill-creation-methodology

# 方式2: 使用 GitHub CLI
gh repo clone CN-big-cabbage/skill-creation-methodology
cd skill-creation-methodology

# 验证下载成功
ls -la skills/generate-skill.md
```

### 第二步：安装技能

根据你使用的 AI 编程工具，选择对应的安装方式：

#### Claude Code 安装

```bash
# 项目级安装（仅当前项目可用）
mkdir -p .claude/commands
cp skills/generate-skill.md .claude/commands/generate-skill.md

# 或全局安装（所有项目可用）
mkdir -p ~/.claude/commands
cp skills/generate-skill.md ~/.claude/commands/generate-skill.md

# 验证安装
ls -la .claude/commands/generate-skill.md  # 项目级
ls -la ~/.claude/commands/generate-skill.md  # 全局
```

#### OpenAI Codex CLI 安装

```bash
# 项目级安装
mkdir -p .codex
cp skills/generate-skill.md .codex/generate-skill.md

# 或全局安装
cat skills/generate-skill.md >> ~/.codex/instructions.md

# 验证安装
cat .codex/generate-skill.md | head -10
```

#### OpenCode 安装

```bash
# 安装到 OpenCode 指令目录
mkdir -p .opencode/commands
cp skills/generate-skill.md .opencode/commands/generate-skill.md

# 验证安装
ls -la .opencode/commands/generate-skill.md
```

#### Cursor / Windsurf 安装

```bash
# Cursor 安装
mkdir -p .cursor/rules
cp skills/generate-skill.md .cursor/rules/generate-skill.md

# Windsurf 安装
mkdir -p .windsurf/rules
cp skills/generate-skill.md .windsurf/rules/generate-skill.md

# 验证安装
ls -la .cursor/rules/generate-skill.md
```

#### 其他 AI 工具

对于其他工具，直接将 `skills/generate-skill.md` 内容作为 prompt 使用。

### 第三步：使用技能

#### 方式一：自动生成（推荐，5分钟完成）

**在 Claude Code 中**:
```bash
# 安装后直接使用命令
/generate-skill https://github.com/user/project

# 示例：为 you-get 项目生成技能
/generate-skill https://github.com/soimort/you-get
```

**在 Codex / OpenCode / Cursor 中**:
```bash
# 描述任务并引用技能
"请按照 generate-skill 的流程，为 https://github.com/user/project 生成技能"
```

**自动完成流程**:
```
项目分析 → AI内容生成 → 质量验证 → 用户确认 → 推送发布
  1分钟      3分钟        1分钟      交互      1分钟
```

#### 方式二：手动流程（学习模式，约1小时）

**1. 分析项目**
```bash
# 分析 GitHub 项目元数据和结构
./scripts/analyze-repo.sh https://github.com/user/project /tmp/my-skill

# 查看生成的项目配置
cat /tmp/my-skill/project-profile.json
```

**2. 创建技能框架**
```bash
# 创建技能目录结构
./workflows/create-skill.sh my-skill

# 查看生成的框架
ls -la my-skill/
```

**3. 编辑内容**

参考 `you-get/` 完整案例：
```bash
# 查看示例技能结构
ls -la you-get/

# 编辑你的技能主文件
vim my-skill/SKILL.md

# 添加使用指南
vim my-skill/guides/01-installation.md
vim my-skill/guides/02-quickstart.md

# 添加故障排查
vim my-skill/troubleshooting.md
```

**4. 验证质量**
```bash
# 四维质量检查
./workflows/validate-skill.sh my-skill

# 检查结果
# ✅ 文件结构完整
# ✅ frontmatter格式正确
# ✅ 占位符已替换
# ✅ 内容质量达标
```

**5. 发布技能**
```bash
# 方式1: 一键推送发布
./scripts/push-and-publish.sh my-skill

# 方式2: 手动发布到 ClawHub
clawhub publish ./my-skill \
  --slug my-skill \
  --name "My Skill" \
  --version "1.0.0" \
  --changelog "Initial release"

# 方式3: 发布到 GitHub
cd my-skill
git init
git add .
git commit -m "feat: add my-skill"
git remote add origin git@github.com:USER/my-skill.git
git push -u origin main
gh release create v1.0.0
```

### 第四步：安装生成的技能（可选）

生成技能后，用户可以这样安装使用：

```bash
# 从 ClawHub 安装
clawhub install my-skill

# 从 GitHub 克隆
git clone https://github.com/user/my-skill.git

# 查看技能文档
cat my-skill/SKILL.md
```

### 验证安装成功

```bash
# 测试技能生成
/generate-skill https://github.com/soimort/you-get

# 预期输出：
# ✓ 项目分析完成
# ✓ 技能框架创建成功
# ✓ 内容生成完成
# ✓ 质量验证通过
# ✓ 发布成功
```

## 项目结构

```
skill-creation-methodology/
├── skills/                          # AI 技能文件
│   └── generate-skill.md            # 核心：自动技能生成编排器
├── scripts/                         # 自动化脚本
│   ├── analyze-repo.sh              # GitHub 项目分析（元数据 + 结构扫描）
│   ├── push-and-publish.sh          # 推送 GitHub + 发布 ClawHub
│   └── publish-you-get.sh           # you-get 发布脚本
├── workflows/                       # 工作流脚本
│   ├── create-skill.sh              # 技能框架快速创建
│   ├── validate-skill.sh            # 技能质量验证（增强版）
│   └── publish-clawhub.sh           # ClawHub 发布流程
├── templates/                       # 可复用模板
│   └── clawhub/
│       ├── SKILL.md.template        # 技能主文件模板
│       ├── guide.md.template        # 使用指南模板
│       └── troubleshooting.md.template  # 故障排查模板
├── docs/                            # 核心方法论文档
│   ├── 00-overview.md               # 总览
│   ├── 01-platform-research.md      # 平台研究
│   ├── 02-skill-design-principles.md # 设计原则
│   ├── 03-creation-workflow.md      # 创建流程
│   ├── 04-testing-validation.md     # 测试验证
│   ├── 05-publishing-guide.md       # 发布指南
│   ├── 06-maintenance-strategy.md   # 维护策略
│   └── 07-case-study-kubeasz.md     # 案例分析
├── examples/                        # 示例项目
│   ├── hello-world/                 # 入门级示例
│   ├── data-processor/              # 中级示例
│   └── kubeasz-deploy/              # 生产级示例
├── you-get/                         # 完整技能案例（you-get）
│   ├── SKILL.md                     # 技能主文件
│   ├── guides/                      # 使用指南（安装/快速开始/高级用法）
│   ├── troubleshooting.md           # 故障排查（10 个常见问题）
│   └── configs/                     # 配置示例
├── checklists/                      # 检查清单
│   └── pre-creation-checklist.md    # 创建前评估
└── resources/                       # 参考资料
    ├── platform-comparison.md       # 平台对比
    ├── skill-quality-metrics.md     # 质量指标
    └── common-patterns.md           # 常见设计模式
```

## 核心价值

| 对比维度 | 本方案 | 传统方式 |
|---------|--------|---------|
| 创建时间 | 5-6 小时 | 20-30 小时 |
| 学习曲线 | 快速迭代式 | 先学后做式 |
| 质量保证 | 自动化验证 | 手动验证 |
| 平台覆盖 | 双平台模板 | 单平台经验 |
| 内容生成 | AI 智能生成 | 手动编写 |

## 兼容工具

| 工具 | 安装方式 | 使用方式 |
|------|---------|---------|
| [Claude Code](https://claude.ai/claude-code) | `.claude/commands/` | `/generate-skill <url>` |
| [OpenAI Codex CLI](https://github.com/openai/codex) | `.codex/` | 描述任务 + 引用 prompt |
| [OpenCode](https://github.com/opencode-ai/opencode) | `.opencode/commands/` | 描述任务 + 引用 prompt |
| [Cursor](https://cursor.com) | `.cursor/rules/` | 描述任务 + 引用规则 |
| [Windsurf](https://windsurf.com) | `.windsurf/rules/` | 描述任务 + 引用规则 |

## 适用场景

- GitHub 项目转技能发布
- 学习技能创建方法论
- 多平台技能发布
- 快速验证技能想法

## 文档导航

| 文档 | 说明 |
|------|------|
| [总览](docs/00-overview.md) | 方法论简介和快速开始 |
| [平台研究](docs/01-platform-research.md) | ClawHub / GitHub Marketplace 对比 |
| [设计原则](docs/02-skill-design-principles.md) | 6 大核心要素 + 质量评估标准 |
| [创建流程](docs/03-creation-workflow.md) | Phase 0-5 快速迭代流程 |
| [测试验证](docs/04-testing-validation.md) | 验证策略和检查清单 |
| [发布指南](docs/05-publishing-guide.md) | 双平台发布步骤 |
| [维护策略](docs/06-maintenance-strategy.md) | 版本迭代和用户反馈 |
| [案例分析](docs/07-case-study-kubeasz.md) | kubeasz 生产级案例 |

## 许可证

[MIT License](LICENSE)
