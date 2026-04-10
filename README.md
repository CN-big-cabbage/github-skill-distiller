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

## 安装技能

`generate-skill` 是自动生成技能的核心编排器，需要安装到你的 AI 编程工具中才能使用 `/generate-skill` 命令。

### Claude Code

```bash
# 项目级安装（仅当前项目可用）
mkdir -p .claude/commands
cp skills/generate-skill.md .claude/commands/generate-skill.md

# 全局安装（所有项目可用）
mkdir -p ~/.claude/commands
cp skills/generate-skill.md ~/.claude/commands/generate-skill.md
```

安装后在 Claude Code 中使用：
```bash
/generate-skill https://github.com/user/project
```

### OpenAI Codex CLI

```bash
# 将技能内容追加到项目指令文件
mkdir -p .codex
cp skills/generate-skill.md .codex/generate-skill.md

# 或追加到全局指令
cat skills/generate-skill.md >> ~/.codex/instructions.md
```

在 Codex 中使用时，直接描述任务即可：
```
请按照 generate-skill 的流程，为 https://github.com/user/project 生成技能
```

### OpenCode

```bash
# 将技能复制到 OpenCode 的指令目录
mkdir -p .opencode/commands
cp skills/generate-skill.md .opencode/commands/generate-skill.md
```

### Cursor / Windsurf

```bash
# Cursor：添加到项目规则
mkdir -p .cursor/rules
cp skills/generate-skill.md .cursor/rules/generate-skill.md

# Windsurf：添加到项目规则
mkdir -p .windsurf/rules
cp skills/generate-skill.md .windsurf/rules/generate-skill.md
```

### 通用方式

对于其他 AI 编程工具，可以直接将 `skills/generate-skill.md` 的内容作为 prompt 提供给 AI，并配合项目中的脚本使用。

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

## 快速开始

### 方式一：自动生成（推荐）

安装技能后（参见 [安装技能](#安装技能)），一条命令完成全流程：

```bash
/generate-skill https://github.com/user/project
```

自动完成：项目分析 → AI 内容生成 → 质量验证 → 用户确认 → 推送发布

### 方式二：手动流程

#### 1. 分析项目（1 分钟）

```bash
./scripts/analyze-repo.sh https://github.com/user/project /tmp/my-skill
```

输出 `project-profile.json`，包含项目元数据和结构信息。

#### 2. 创建框架（1 分钟）

```bash
./workflows/create-skill.sh my-skill
```

#### 3. 填充内容（3-4 小时）

参考 `you-get/` 目录的完整案例，编辑生成的模板文件。

#### 4. 验证质量（1 分钟）

```bash
./workflows/validate-skill.sh my-skill
```

四维检查：文件结构 → frontmatter → 占位符 → 内容质量

#### 5. 推送发布（1 分钟）

```bash
./scripts/push-and-publish.sh my-skill
```

自动创建 GitHub 仓库并推送，ClawHub CLI 可用时同步发布。

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
