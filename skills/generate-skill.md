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

### Phase 2: 生成技能内容

在 `/tmp/skill-gen-<repo-name>/skill/` 目录下生成以下文件：

#### 2.1 生成 SKILL.md

参考 `cases/you-get/SKILL.md` 的质量标准，生成包含以下内容的 SKILL.md：

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

### Phase 2.5: 内容自评

生成所有文件后，执行一轮交叉检查：

1. **事实核查**: 对照项目 README 和文档，确认所有命令、参数、输出示例是否真实存在，删除任何编造内容
2. **覆盖度检查**: 确认项目的核心功能是否都已覆盖，补充遗漏的重要功能
3. **类型匹配检查**: 确认生成内容是否符合该项目类型的侧重点（参考 Phase 1.5）
4. **可执行性检查**: 确认每个命令示例是否可以直接复制执行，参数是否完整

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

参考项目中 `cases/you-get/` 目录的技能质量：
- SKILL.md: 80+ 行，内容充实
- guides/: 每个文件 100+ 行，包含具体命令和期望输出
- troubleshooting.md: 200+ 行，问题覆盖全面

## 注意事项

- 所有生成内容使用中文
- 命令示例必须来自项目真实文档，不能编造
- AI 执行说明要准确标注哪些步骤 AI 可以自动完成
- 如果项目 stars < 100 或无 README，提醒用户但不阻止
