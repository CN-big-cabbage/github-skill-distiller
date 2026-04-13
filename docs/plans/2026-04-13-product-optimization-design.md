# GitHub Skill Distiller 产品优化与曝光率提升设计

**日期**: 2026-04-13
**方案**: 产品力优先（方案 A）
**核心策略**: 先提升工具质量和案例库，再申请生态收录

---

## 第1节：生成质量提升 — 项目类型适配

### 现状问题

当前 generate-skill.md 对所有项目使用同一套 prompt 模板，导致不同类型项目生成效果参差不齐。

### 方案

引入**项目类型识别 + 分类型 prompt 策略**：

#### 1.1 analyze-repo.sh 增加类型识别

自动判断项目类型：

- **CLI 工具** — 检测 entry_points、bin 字段、argparse/click 等
- **Python/JS 库** — 检测 setup.py/package.json 中无 bin，有 API 文档
- **框架** — 检测插件系统、中间件模式
- **Web 应用** — 检测前端资源、docker-compose
- **DevOps 工具** — 检测 Ansible/Terraform/K8s 配置

#### 1.2 generate-skill.md 增加分类型指引

| 项目类型 | SKILL.md 侧重 | guides 侧重 | troubleshooting 侧重 |
|---------|-------------|------------|-------------------|
| CLI 工具 | 命令速查、常用参数 | 命令行用法场景 | 参数错误、权限问题 |
| 库 | API 参考、代码示例 | 集成到项目中 | 导入错误、版本冲突 |
| 框架 | 架构概览、扩展点 | 项目脚手架搭建 | 配置错误、插件兼容 |
| Web 应用 | 功能清单、部署选项 | 部署和配置 | 端口冲突、依赖缺失 |
| DevOps | 架构图、组件关系 | 环境准备和部署 | 网络问题、权限配置 |

#### 1.3 生成后自评环节

AI 生成内容后，对照项目真实文档做一轮交叉检查，删除编造内容，补充遗漏要点。

---

## 第2节：案例库扩充策略

### 目标

从 2 个案例扩充到 8-10 个，覆盖 5 种项目类型。

### 选择标准

- Stars >= 1k（知名度背书）
- 文档完善（README 质量高）
- 类型互补（每种类型至少 1-2 个）
- 语言多样（Python、Go、JS、Shell 等）

### 候选方向

| 类型 | 候选项目示例 | 理由 |
|------|------------|------|
| CLI 工具 | httpie、tldr、fzf | 命令行工具代表，用户基数大 |
| Python 库 | requests、rich | API 导向，文档优秀 |
| 框架 | FastAPI、Gin | 不同语言的框架代表 |
| Web 应用 | Streamlit 示例项目 | 展示前端类技能生成 |
| DevOps | kubeasz、lazydocker | 运维类代表 |

### 组织方式

- 统一放在 `cases/` 目录下（如 `cases/httpie/`、`cases/rich/`）
- 将现有 `you-get/` 和 `paper-checking/` 迁移到 `cases/`
- README 增加"案例展示"章节

### 正循环

每新增案例验证类型适配 prompt，形成"生成 → 检验 → 调优"循环。

---

## 第3节：GitHub 项目元数据与可发现性优化

### 3.1 Topics 标签

```
claude-code, ai-skills, skill-generator, github-automation,
claude, ai-tools, llm, prompt-engineering, developer-tools,
clawhub, ai-workflow, code-generation
```

### 3.2 Repository Description

```
Distill GitHub projects into ready-to-publish AI skills in 5 minutes. Supports Claude Code, Codex, Cursor & more.
```

### 3.3 README Badges

```
[License: MIT] [GitHub Stars] [Skills Generated: 10+] [Supported Tools: 5]
```

### 3.4 社交预览图

1280x640 封面图，展示核心流程：
```
GitHub Repo → Distill → AI Skill → Publish
```

通过 GitHub Settings → Social Preview 设置。

### 3.5 GitHub Actions CI

- 对 `cases/` 下所有技能运行 `validate-skill.sh`
- README 中展示 CI passing badge

### 3.6 Release 与 Tags

每次案例库重大更新发布版本（v1.0、v1.1...），利用 Releases 页面作为流量入口。

---

## 第4节：生态收录路径

### 前提

第1-3节完成后再执行。

### 路径 1：Awesome 列表收录

| 列表 | 收录理由 | 要求 |
|------|---------|------|
| awesome-claude-code | 直接相关，核心生态 | 实际可用的 Claude Code 技能 |
| awesome-ai-tools | 泛 AI 工具类 | 英文 README、足够 stars |
| awesome-prompt-engineering | prompt 工程相关 | 展示 prompt 策略设计 |

**策略：**
- 提交 PR 前先 star 仓库，阅读贡献指南
- 突出差异化：唯一端到端自动生成 + 发布的技能框架
- 附 3-5 个高质量案例链接

### 路径 2：ClawHub 官方推荐

- 发布 8+ 个由本工具生成的技能
- 联系团队展示"上游生产力工具"价值
- 争取文档或首页提及

### 路径 3：AI 工具文档引用

- 前提：stars 达到 50-100+
- 向 Claude Code 社区提交使用案例
- 在相关 Issue/Discussion 中分享

### 节奏安排

```
第1-2周：完成第1-3节（质量 + 案例 + 元数据）
第3周：  提交 awesome-claude-code PR
第4周：  ClawHub 批量发布 + 联系团队
持续：   社区互动积累 stars
```
