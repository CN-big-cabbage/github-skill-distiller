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

> 完整流程：Phase 1 → Phase 1.5 → Phase 2 → Phase 2.5 → **Phase 3a（评分）→ Phase 3b（修复）→ Phase 3c（决策）** → Phase 4（验证）→ Phase 5（用户确认）→ Phase 6（发布）

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

### Phase 3a: 结构评分

对 `/tmp/skill-gen-<repo-name>/skill/` 目录执行 6 项检查，计算质量分数。

**评分规则（满分 100）：**

**检查 1 — SKILL.md frontmatter（10 分）**
读取 SKILL.md，检查开头是否有 `---` 包裹的 frontmatter，且含 `name` 和 `description` 字段。
→ 满足：+10；不满足：issues 记录 "SKILL.md 缺少 name/description frontmatter"

**检查 2 — 必需段落（20 分）**
检查 SKILL.md 是否含：描述类段落（含"描述"/"概述"/"介绍"/"Overview"之一的 `##` 标题）、用法类段落（含"用法"/"使用"/"Usage"之一）、示例类段落（含"示例"/"快速"/"Example"之一）。
→ 3 项全有：+20；缺 1 项：+10；缺 2 项以上：+0；缺失项记入 issues

**检查 3 — guides/ 内容（20 分）**
检查 guides/ 目录下是否有文件，且最大文件行数 ≥ 100。
→ 有文件且 ≥ 100 行：+20；有文件但 ≥ 50 行且 < 100 行：+10，issues 记录 "guides/ 文件内容不足 100 行"；无文件：+0，issues 记录 "guides/ 目录为空"

**检查 4 — troubleshooting 条目（20 分）**
读取 troubleshooting.md，统计 `###` 开头的条目数。
→ ≥ 3 条：+20；2 条：+10，issues 记录 "troubleshooting 只有 2 条"；< 2 条：+0，issues 记录 "troubleshooting 严重不足"
特殊情况：如果项目 README < 50 行（极简项目），≥ 2 条即得满分，记录 WARNING 而非 issue。

**检查 5 — 真实命令（15 分）**
检查 SKILL.md 和 guides/ 中的代码块，不含 `<your-xxx>` / `<placeholder>` / `<repo>` 格式占位符。
→ 无占位符：+15；有占位符：+0，issues 记录 "示例含 <placeholder> 格式，需替换为真实命令"

**检查 6 — 无冗余占位符文本（15 分）**
全文搜索纯文本中的未填写标记：`TBD`、`TODO`、`待补充`，以及独立出现（不在 `< >` 尖括号内）的 `xxx`。
检查 5 已覆盖 `<your-xxx>` 等代码块占位符，本检查仅针对正文叙述性文本中的遗留标记。
→ 无：+15；有：+0，issues 记录 "发现占位符文本"及其位置

**输出评分结果（在执行 generate-skill 流程时输出）：**

```
质量评分: {score}/100
{score >= 70 时显示 "✅ 通过质量门"，否则显示 "❌ 未通过质量门（需修复）"}
问题列表:
- {issue 1}
- {issue 2}
（无问题时显示"无"）
```

如果 score ≥ 70，直接跳到 Phase 5（用户确认）。
如果 score < 70，记录 `iteration = 1`，进入 Phase 3b。

### Phase 3b: AI 定向修复（第 {iteration} 轮）

针对 Phase 3a 输出的每个 issue，执行定向修复，不修改评分已通过的段落：

**issue: "SKILL.md 缺少 name/description frontmatter"**
→ 在 SKILL.md 文件开头添加：
```
---
name: <从项目名推断，小写连字符格式>
description: <从项目 GitHub description 字段提取，不超过 80 字>
version: "0.1.0"
---
```

**issue: "SKILL.md 缺少 XX 段落"**
→ 参考 `cases/you-get/SKILL.md` 中对应段落的结构，结合当前项目信息补写该段落，追加到 SKILL.md 末尾适当位置。

**issue: "guides/ 目录为空" 或 "guides/ 文件内容不足"**
→ 基于项目 README 和 Phase 1.5 的类型策略，补写或扩充 `guides/01-installation.md`，确保 ≥ 100 行，包含完整安装步骤和至少一条可验证命令（如 `$ tool --version`）。

**issue: "troubleshooting 只有 N 条" 或 "troubleshooting 严重不足"**
→ 结合 project-profile.json 中的 `project_type`，在 troubleshooting.md 补写问题条目至 ≥ 3 条（极简项目 ≥ 2 条）。每条格式：
```markdown
### <问题标题>

**症状**: <描述用户看到的现象>

**解决**:
```bash
<修复命令>
```
```

**issue: "示例含 <placeholder> 格式"**
→ 查找所有 `<xxx>` 格式占位符，用项目 README 或文档中的真实值替换；若 README 中无对应真实值则删除该示例行。

**issue: "发现占位符文本"**
→ 定位所有 TBD/TODO/xxx/待补充 文本并删除；如该位置内容空缺，用项目真实信息填充。

修复完成后，进入 Phase 3c。

### Phase 3c: 重评与决策

重新执行 Phase 3a 的全部 6 项检查，得到新的 score 和 issues。

**决策逻辑：**

- **score ≥ 70**：
  输出：
  ```
  ✅ 质量门通过（第 {iteration} 轮修复后）
  最终得分: {score}/100
  ```
  继续进入 Phase 5（用户确认）。

- **score < 70 且 iteration < 2**：
  将 iteration 加 1，输出本轮得分，回到 Phase 3b 进行下一轮修复。

- **score < 70 且 iteration = 2（已完成 2 轮修复）**：
  输出：
  ```
  ⚠️  经过 2 轮修复，质量分仍为 {score}/100（未达到 70 分阈值）

  剩余问题：
  - {issue 1}
  - {issue 2}

  是否仍要继续发布？(y/n)
  ```
  等待用户输入：
  - 输入 `y`：继续进入 Phase 5（用户确认）
  - 输入 `n`：终止，输出"已终止。请手动修复上述问题后重新运行 /generate-skill"

### Phase 4: 验证

运行增强版验证脚本：
```bash
./workflows/validate-skill.sh /tmp/skill-gen-<repo-name>/skill
```

如果验证失败，自动修复问题后重新验证。

### Phase 5: 用户确认

展示生成结果摘要给用户：
- 列出所有生成的文件及行数
- 显示 SKILL.md 的前 30 行作为预览
- 询问用户是否满意，是否需要调整

**这是唯一的暂停点。** 等待用户确认后再继续。

### Phase 6: 推送并发布

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
