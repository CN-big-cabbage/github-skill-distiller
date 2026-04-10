---
name: generate-skill
description: 从 GitHub URL 自动生成技能并发布。使用方法：/generate-skill <github-url>
---

# 自动技能生成

你将根据用户提供的 GitHub URL，自动完成技能创建的全流程。

## 输入

用户提供一个 GitHub 仓库 URL，例如：
```
/generate-skill https://github.com/soimort/you-get
```

## 全流程

### Phase 1: 项目分析

1. 运行分析脚本：
```bash
./scripts/analyze-repo.sh <github-url> /tmp/skill-gen-<repo-name>
```

2. 读取生成的 `/tmp/skill-gen-<repo-name>/project-profile.json`
3. 读取克隆仓库的 README 文件（路径在 profile 的 clone_dir + readme_file 中）
4. 如果 has_docs 为 true，浏览 docs/ 目录获取更多上下文

### Phase 2: 生成技能内容

在 `/tmp/skill-gen-<repo-name>/skill/` 目录下生成以下文件：

#### 2.1 生成 SKILL.md

参考 `you-get/SKILL.md` 的质量标准，生成包含以下内容的 SKILL.md：

- **frontmatter**: name, description, version(0.1.0), metadata(openclaw requires, emoji, homepage)
- **技能概述**: 说明技能帮助谁完成什么，列出 3-5 个核心场景
- **使用流程**: AI 引导的步骤（4-6 步）
- **关键章节导航**: 链接到 guides/ 和 troubleshooting.md
- **AI 助手能力**: 6-8 条 AI 可执行的具体能力
- **核心功能**: 功能清单（用 ✅ 标记）
- **快速示例**: 3-5 个常用命令示例
- **安装要求**: 列出依赖
- **项目链接**: GitHub、官网、文档

#### 2.2 生成 guides/

根据项目复杂度生成 1-3 个 guide 文件：

- `guides/01-installation.md` — 安装指南（必须）
- `guides/02-quickstart.md` — 快速开始（必须）
- `guides/03-advanced-usage.md` — 高级用法（复杂项目）

每个 guide 必须包含：
- 适用场景说明
- 分节目标
- AI 执行说明标注（哪些命令 AI 可以自动执行）
- 期望结果说明
- 完成确认检查清单
- 下一步引导

#### 2.3 生成 troubleshooting.md

生成 6-10 个常见问题，按类别分组：
- 安装问题（2-3 个）
- 使用问题（2-4 个）
- 网络/环境问题（2-3 个）

每个问题包含：难度标记、排查步骤、常见原因（含概率）、多个解决方案

### Phase 3: 验证

运行增强版验证脚本：
```bash
./workflows/validate-skill.sh /tmp/skill-gen-<repo-name>/skill
```

如果验证失败，自动修复问题后重新验证。

### Phase 4: 用户确认

展示生成结果摘要给用户：
- 列出所有生成的文件及行数
- 显示 SKILL.md 的前 30 行作为预览
- 询问用户是否满意，是否需要调整

**这是唯一的暂停点。** 等待用户确认后再继续。

### Phase 5: 推送并发布

用户确认后，运行：
```bash
./scripts/push-and-publish.sh /tmp/skill-gen-<repo-name>/skill
```

最后向用户报告：
- GitHub 仓库地址
- ClawHub 发布地址（如可用）

## 质量标准

参考项目中 `you-get/` 目录的技能质量：
- SKILL.md: 80+ 行，内容充实
- guides/: 每个文件 100+ 行，包含具体命令和期望输出
- troubleshooting.md: 200+ 行，问题覆盖全面

## 注意事项

- 所有生成内容使用中文
- 命令示例必须来自项目真实文档，不能编造
- AI 执行说明要准确标注哪些步骤 AI 可以自动完成
- 如果项目 stars < 100 或无 README，提醒用户但不阻止
