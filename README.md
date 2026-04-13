# GitHub Skill Distiller

[English](./README_EN.md) | 中文

**蒸馏 GitHub 项目为 AI Skill 技能并发布到开源社区**

## 项目简介

GitHub Skill Distiller 是一个 **AI 驱动的技能蒸馏框架**，能够自动将 GitHub 项目转化为标准化 AI Skill 技能，并一键发布到 ClawHub、GitHub 等开源社区。

**核心价值**：像蒸馏精华一样，从复杂的 GitHub 项目中提取核心能力，转化为简洁、可用、可发布的 AI 技能。

**蒸馏过程**（仅需 5 分钟）：
```
GitHub 项目 → 项目分析 → 能力提取 → 技能生成 → 质量验证 → 发布上线
   (输入)      (1分钟)    (核心)      (3分钟)     (10秒)     (30秒)
```

**实际案例**：
- [you-get 技能](https://clawhub.ai/skills/you-get)：从 56k stars 项目蒸馏为完整技能（5分钟）
- 输入：https://github.com/soimort/you-get
- 输出：SKILL.md + 使用指南 + 故障排查 + 配置示例（6个文件，1165行）

**时间对比**：
```
传统手动方式：调研(2-4h) + 编写(8-12h) + 验证(4-6h) + 发布(1-2h) = 20-30小时
自动蒸馏流程：分析(1min) + 提取(核心) + 生成(3min) + 验证(10s) + 发布(30s) = 5分钟
节省时间：    99%+
```

## 功能特性

**核心能力 - 技能蒸馏**：
- **项目分析蒸馏**：自动扫描 GitHub 项目结构，提取元数据、文档、配置
- **能力精华提取**：AI 理解项目核心功能，提取可执行的技能能力
- **技能标准生成**：生成符合 ClawHub/GitHub 标准的技能包
- **质量验证保障**：四维检查确保蒸馏质量（结构/格式/内容/完整性）
- **一键发布上线**：支持 ClawHub、GitHub Marketplace 双平台发布

**技术特性**：
- 🎯 **输入简单**：只需 GitHub URL
- ⚡ **速度极快**：5分钟完成全流程
- 🤖 **AI 驱动**：智能理解项目核心能力
- ✅ **质量保证**：自动化验证 + 标准化输出
- 🔧 **工具兼容**：支持 Claude Code、Codex、OpenCode 等主流 AI 工具
- 📦 **即开即用**：完整模板、脚本、示例项目

## 快速开始 - 开始蒸馏你的第一个技能

### 第一步：下载蒸馏器

```bash
# 方式1: 使用 git clone（推荐）
git clone https://github.com/CN-big-cabbage/github-skill-distiller.git
cd github-skill-distiller

# 方式2: 使用 GitHub CLI
gh repo clone CN-big-cabbage/github-skill-distiller
cd github-skill-distiller

# 验证下载成功
ls -la skills/generate-skill.md
```

### 第二步：安装蒸馏技能

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

### 第三步：开始蒸馏

#### 方式一：自动蒸馏（推荐，5分钟完成）

**在 Claude Code 中**:
```bash
# 安装后直接使用蒸馏命令
/generate-skill https://github.com/user/project

# 示例：蒸馏 you-get 项目为技能
/generate-skill https://github.com/soimort/you-get
```

**在 Codex / OpenCode / Cursor 中**:
```bash
# 描述蒸馏任务并引用技能
"请按照 generate-skill 的流程，蒸馏 https://github.com/user/project 为技能"
```

**蒸馏流程**:
```
GitHub项目 → 项目分析 → 能力提取 → 技能生成 → 质量验证 → 发布上线
  输入       1分钟      AI核心      3分钟      10秒      30秒
```

#### 方式二：手动蒸馏（学习模式，约1小时）

**1. 分析项目（提取项目精华）**
```bash
# 分析 GitHub 项目元数据和结构
./scripts/analyze-repo.sh https://github.com/user/project /tmp/my-skill

# 查看提取的项目精华
cat /tmp/my-skill/project-profile.json
```

**2. 创建技能框架（构建蒸馏容器）**
```bash
# 创建技能目录结构
./workflows/create-skill.sh my-skill

# 查看生成的框架
ls -la my-skill/
```

**3. 编辑内容（注入能力精华）**

参考 `cases/you-get/` 完整案例：
```bash
# 查看已蒸馏的技能示例
ls -la cases/you-get/

# 编辑你的技能主文件
vim my-skill/SKILL.md

# 添加使用指南
vim my-skill/guides/01-installation.md
vim my-skill/guides/02-quickstart.md

# 添加故障排查
vim my-skill/troubleshooting.md
```

**4. 验证质量（确保蒸馏纯度）**
```bash
# 四维质量检查
./workflows/validate-skill.sh my-skill

# 检查结果
# ✅ 文件结构完整
# ✅ frontmatter格式正确
# ✅ 占位符已替换
# ✅ 内容质量达标
```

**5. 发布技能（输出蒸馏成果）**
```bash
# 方式1: 一键推送发布
./scripts/push-and-publish.sh my-skill

# 方式2: 手动发布到 ClawHub
clawhub publish ./my-skill \
  --slug my-skill \
  --name "My Skill" \
  --version "1.0.0" \
  --changelog "Distilled from GitHub project"

# 方式3: 发布到 GitHub
cd my-skill
git init
git add .
git commit -m "feat: distilled skill from GitHub project"
git remote add origin git@github.com:USER/my-skill.git
git push -u origin main
gh release create v1.0.0
```

### 第四步：使用蒸馏后的技能（可选）

蒸馏完成并发布后，用户可以这样安装使用：

```bash
# 从 ClawHub 安装蒸馏后的技能
clawhub install my-skill

# 从 GitHub 克隆
git clone https://github.com/user/my-skill.git

# 查看技能文档
cat my-skill/SKILL.md
```

### 验证蒸馏成功

```bash
# 测试蒸馏流程
/generate-skill https://github.com/soimort/you-get

# 预期输出：
# ✓ 项目分析完成（提取项目精华）
# ✓ 技能框架创建成功（构建蒸馏容器）
# ✓ 能力注入完成（蒸馏核心能力）
# ✓ 质量验证通过（确保蒸馏纯度）
# ✓ 发布成功（输出蒸馏成果）
```

## 蒸馏成果展示

```
github-skill-distiller/             # GitHub Skill Distiller
├── skills/                           # 蒸馏核心引擎
│   └── generate-skill.md             # 蒸馏编排器（AI驱动）
├── scripts/                          # 自动化脚本
│   ├── analyze-repo.sh               # 项目分析（提取精华）
│   ├── push-and-publish.sh           # 发布上线
│   └── publish-you-get.sh            # you-get蒸馏案例
├── workflows/                        # 工作流
│   ├── create-skill.sh               # 创建蒸馏容器
│   ├── validate-skill.sh             # 质量验证（确保纯度）
│   └── publish-clawhub.sh            # ClawHub发布
├── templates/                        # 蒸馏模板
│   └── clawhub/
│       ├── SKILL.md.template         # 技能容器模板
│       ├── guide.md.template         # 指南模板
│       └── troubleshooting.md.template  # 故障排查模板
├── docs/                             # 方法论文档
│   ├── 00-overview.md                # 蒸馏总览
│   ├── 01-platform-research.md       # 平台研究
│   ├── 02-skill-design-principles.md # 设计原则
│   ├── 03-creation-workflow.md       # 蒸馏流程
│   ├── 04-testing-validation.md      # 测试验证
│   ├── 05-publishing-guide.md        # 发布指南
│   ├── 06-maintenance-strategy.md    # 维护策略
│   └── 07-case-study-kubeasz.md      # 案例分析
├── examples/                         # 示例项目
│   ├── hello-world/                  # 入门级蒸馏
│   ├── data-processor/               # 中级蒸馏
│   └── kubeasz-deploy/               # 生产级蒸馏
├── cases/                            # 蒸馏成果案例
│   ├── you-get/                      # CLI工具案例（you-get）
│   │   ├── SKILL.md                  # 蒸馏后的技能主文件
│   │   ├── guides/                   # 使用指南
│   │   ├── troubleshooting.md       # 故障排查
│   │   └── configs/                  # 配置示例
│   └── paper-checking/               # Web应用案例（论文查重）
├── checklists/                       # 检查清单
│   └── pre-creation-checklist.md    # 蒸馏前评估
└── resources/                        # 参考资料
    ├── platform-comparison.md       # 平台对比
    ├── skill-quality-metrics.md     # 质量指标
    └── common-patterns.md           # 常见模式
```

## 蒸馏价值

| 对比维度 | 自动蒸馏 | 手动蒸馏 | 传统方式 |
|---------|---------|---------|---------|
| 处理时间 | **5 分钟** | 1-2 小时 | 20-30 小时 |
| 技术门槛 | 零门槛 | 低门槛 | 高门槛 |
| 质量保证 | 自动验证 | 自动验证 | 手动验证 |
| 平台支持 | 双平台 | 双平台 | 单平台 |
| 核心技术 | **AI 提取精华** | 模板引导 | 手动编写 |
| 适合人群 | 所有人 | 学习者 | 专家 |

**推荐使用自动蒸馏**：输入 GitHub URL → 等待 5 分钟 → 获得纯净技能

## 蒸馏原理

GitHub Skill Distiller 采用 **提取-转化-加载（ETL）** 的蒸馏方法论：

**第一阶段：提取（Extract）**
```
GitHub 项目 → 项目扫描 → 元数据提取 → 文档分析 → 能力识别
             (结构)     (stars/语言)   (README)   (核心功能)
```

**第二阶段：转化（Transform）**
```
能力识别 → AI理解 → 技能设计 → 内容生成 → 标准化输出
          (核心)   (SKILL.md)  (guides)   (ClawHub格式)
```

**第三阶段：加载（Load）**
```
标准化输出 → 质量验证 → 平台适配 → 发布上线
             (纯度检查) (ClawHub/GitHub) (可用技能)
```

**蒸馏效果**：
- 输入：复杂的 GitHub 项目（数十个文件，数千行代码）
- 输出：纯净的 AI 技能（6个文件，聚焦核心能力）
- 压缩比：20-30倍（提取精华，去除冗余）

## 兼容工具

GitHub Skill Distiller 已适配主流 AI 编程工具：

| 工具 | 安装方式 | 蒸馏命令 |
|------|---------|---------|
| [Claude Code](https://claude.ai/claude-code) | `.claude/commands/` | `/generate-skill <url>` |
| [OpenAI Codex CLI](https://github.com/openai/codex) | `.codex/` | 描述任务 + 引用 prompt |
| [OpenCode](https://github.com/opencode-ai/opencode) | `.opencode/commands/` | 描述任务 + 引用 prompt |
| [Cursor](https://cursor.com) | `.cursor/rules/` | 描述任务 + 引用规则 |
| [Windsurf](https://windsurf.com) | `.windsurf/rules/` | 描述任务 + 引用规则 |

## 适用场景

**最适合蒸馏的项目**：
- ✅ 有明确用户价值的开源项目
- ✅ 有 README 和基础文档的项目
- ✅ 命令行工具或 API 项目
- ✅ 需要快速推广和分发的项目

**蒸馏成功案例**：
- [you-get](https://clawhub.ai/skills/you-get)：视频下载工具（56k stars）
- [kubeasz-deploy](https://github.com/CN-big-cabbage/kubeasz)：K8s部署工具

**不适合蒸馏的项目**：
- ❌ 完全无文档的项目
- ❌ 企业内部私有项目（无法开源）
- ❌ 纯图形界面应用（无 API/CLI）

## 文档导航

深入学习技能蒸馏方法论：

| 文档 | 说明 |
|------|------|
| [蒸馏总览](docs/00-overview.md) | 方法论简介和快速开始 |
| [平台研究](docs/01-platform-research.md) | ClawHub / GitHub Marketplace 对比 |
| [设计原则](docs/02-skill-design-principles.md) | 6 大核心要素 + 质量评估标准 |
| [蒸馏流程](docs/03-creation-workflow.md) | 提取-转化-加载完整流程 |
| [测试验证](docs/04-testing-validation.md) | 验证策略和检查清单 |
| [发布指南](docs/05-publishing-guide.md) | 双平台发布步骤 |
| [维护策略](docs/06-maintenance-strategy.md) | 版本迭代和用户反馈 |
| [案例分析](docs/07-case-study-kubeasz.md) | kubeasz 蒸馏案例 |

## 社区与支持

- **GitHub**: https://github.com/CN-big-cabbage/github-skill-distiller
- **Issues**: 问题反馈和功能建议
- **ClawHub**: https://clawhub.ai (发布平台)
- **成功案例**: [you-get 技能](https://clawhub.ai/skills/you-get)

## 许可证

[MIT License](LICENSE)

---

**GitHub Skill Distiller** - 蒸馏 GitHub 项目精华，转化为纯净 AI 技能 🎯
