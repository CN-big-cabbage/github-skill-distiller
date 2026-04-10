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
- **完整方法论**: 8 个核心文档覆盖从调研到维护的全生命周期
- **可复用模板**: SKILL.md、指南、故障排查模板开箱即用
- **参考示例**: 3 个难度梯度的示例项目 + 1 个生产级案例（you-get）

## 项目结构

```
skill-creation-methodology/
├── skills/                          # Claude Code Skills
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

在 Claude Code 中安装 `generate-skill` 技能后，一条命令完成全流程：

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
