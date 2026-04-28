# Quality Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `generate-skill.md` 生成流程的 Phase 2.5 之后插入 Phase 3（质量闭环），实现自动评分 + 最多 2 轮 AI 定向修复 + 阈值决策。

**Architecture:** 只修改 `skills/generate-skill.md` 一个文件。在现有 Phase 2.5（内容自评）末尾追加 Phase 3a（结构评分）、Phase 3b（AI 定向修复）、Phase 3c（重评决策）三个指令块，并将原有 Phase 3/4/5 重编号为 Phase 4/5/6。

**Tech Stack:** Markdown 指令（Claude 执行），无脚本新增，无依赖变更。

---

## 文件改动映射

| 文件 | 操作 | 说明 |
|------|------|------|
| `skills/generate-skill.md` | Modify | 插入 Phase 3a/3b/3c 指令块，重编号原 Phase 3→4、4→5、5→6 |

---

## Task 1: 在 Phase 2.5 末尾插入 Phase 3a（结构评分）

**Files:**
- Modify: `skills/generate-skill.md`（在第 110 行 Phase 2.5 结束处后插入）

- [ ] **Step 1: 确认插入位置**

阅读 `skills/generate-skill.md` 第 102-119 行，确认 Phase 2.5 结束于第 110 行，Phase 3（原验证脚本）从第 111 行开始。

- [ ] **Step 2: 插入 Phase 3a 评分指令块**

在第 110 行（Phase 2.5 最后一行 `4. **可执行性检查**...`）之后、原 `### Phase 3: 验证` 之前，插入以下内容：

```markdown

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
检查 guides/ 目录下是否有文件，且最大文件行数 ≥ 50。
→ 有文件且 ≥ 50 行：+20；有文件但 < 50 行：+10，issues 记录 "guides/ 文件内容不足 50 行"；无文件：+0，issues 记录 "guides/ 目录为空"

**检查 4 — troubleshooting 条目（20 分）**
读取 troubleshooting.md，统计 `###` 开头的条目数。
→ ≥ 3 条：+20；2 条：+10，issues 记录 "troubleshooting 只有 2 条"；< 2 条：+0，issues 记录 "troubleshooting 严重不足"
特殊情况：如果项目 README < 50 行（极简项目），≥ 2 条即得满分，记录 WARNING 而非 issue。

**检查 5 — 真实命令（15 分）**
检查 SKILL.md 和 guides/ 中的代码块，不含 `<your-xxx>` / `<placeholder>` / `<repo>` 格式占位符。
→ 无占位符：+15；有占位符：+0，issues 记录 "示例含 <placeholder> 格式，需替换为真实命令"

**检查 6 — 无冗余占位符文本（15 分）**
全文搜索 `TBD`、`TODO`、`xxx`、`待补充`。
→ 无：+15；有：+0，issues 记录 "发现占位符文本"及其位置

**输出评分结果：**
```
质量评分: {score}/100
{score >= 70 ? "✅ 通过质量门" : "❌ 未通过质量门（需修复）"}
问题列表:
- {issue 1}
- {issue 2}
（无问题时显示"无"）
```

如果 score ≥ 70，直接跳到 Phase 4（用户确认）。
如果 score < 70，记录 `iteration = 1`，进入 Phase 3b。
```

- [ ] **Step 3: 确认插入无误**

读取修改后的文件，确认 Phase 3a 块出现在 Phase 2.5 结束处之后，原 Phase 3（validate-skill.sh）之前。

---

## Task 2: 插入 Phase 3b（AI 定向修复）

**Files:**
- Modify: `skills/generate-skill.md`（Phase 3a 末尾之后）

- [ ] **Step 1: 插入 Phase 3b 指令块**

紧接 Phase 3a 内容之后插入：

```markdown

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

**issue: "guides/ 目录为空" 或 "guides/ 文件内容不足 50 行"**
→ 基于项目 README 和 Phase 1.5 的类型策略，补写或扩充 `guides/01-installation.md`，确保 ≥ 50 行，包含完整安装步骤和至少一条可验证命令（如 `$ tool --version`）。

**issue: "troubleshooting 只有 N 条" 或 "troubleshooting 严重不足"**
→ 结合 project-profile.json 中的 `project_type`，在 troubleshooting.md 补写问题条目直到 ≥ 3 条（极简项目 ≥ 2 条）。每条格式：
```
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
```

- [ ] **Step 2: 确认插入位置正确**

确认 Phase 3b 紧跟 Phase 3a 之后，且在 Phase 3c 之前（Phase 3c 还未添加）。

---

## Task 3: 插入 Phase 3c（重评与决策）

**Files:**
- Modify: `skills/generate-skill.md`（Phase 3b 末尾之后）

- [ ] **Step 1: 插入 Phase 3c 指令块**

紧接 Phase 3b 内容之后插入：

```markdown

### Phase 3c: 重评与决策

重新执行 Phase 3a 的全部 6 项检查，得到新的 score 和 issues。

**决策逻辑：**

- **score ≥ 70**：
  ```
  ✅ 质量门通过（第 {iteration} 轮修复后）
  最终得分: {score}/100
  ```
  继续进入 Phase 4（用户确认）。

- **score < 70 且 iteration < 2**：
  将 iteration 加 1，输出本轮得分，回到 Phase 3b 进行下一轮修复。

- **score < 70 且 iteration = 2（已完成 2 轮修复）**：
  ```
  ⚠️  经过 2 轮修复，质量分仍为 {score}/100（未达到 70 分阈值）

  剩余问题：
  - {issue 1}
  - {issue 2}

  是否仍要继续发布？(y/n)
  ```
  等待用户输入：
  - 输入 `y`：继续进入 Phase 4
  - 输入 `n`：终止，输出"已终止。请手动修复上述问题后重新运行 /generate-skill"
```

- [ ] **Step 2: 确认三个子 Phase 顺序**

读取 generate-skill.md，确认顺序为：Phase 2.5 → Phase 3a → Phase 3b → Phase 3c → (原 Phase 3)。

---

## Task 4: 重编号原有 Phase 3/4/5 → Phase 4/5/6

**Files:**
- Modify: `skills/generate-skill.md`

- [ ] **Step 1: 将原 `### Phase 3: 验证` 改为 `### Phase 4: 验证`**

找到内容：
```
### Phase 3: 验证
```
替换为：
```
### Phase 4: 验证
```

- [ ] **Step 2: 将原 `### Phase 4: 用户确认` 改为 `### Phase 5: 用户确认`**

找到内容：
```
### Phase 4: 用户确认
```
替换为：
```
### Phase 5: 用户确认
```
同时更新 Phase 3c 决策逻辑中对"Phase 4（用户确认）"的引用，改为"Phase 5（用户确认）"。

- [ ] **Step 3: 将原 `### Phase 5: 推送并发布` 改为 `### Phase 6: 推送并发布`**

找到内容：
```
### Phase 5: 推送并发布
```
替换为：
```
### Phase 6: 推送并发布
```

- [ ] **Step 4: 更新全流程说明**

在文件顶部 `## 全流程` 小节下，更新流程说明，确认包含：
Phase 1 → 1.5 → 2 → 2.5 → **3a → 3b → 3c** → 4 → 5 → 6

- [ ] **Step 5: 确认编号无遗漏**

```bash
grep -n "### Phase" skills/generate-skill.md
```

期望输出包含 Phase 1、1.5、2、2.5、3a、3b、3c、4、5、6，无重复编号。

---

## Task 5: 手动验证 — 正常流程（cases/you-get）

**Files:** 无文件改动，仅验证

- [ ] **Step 1: 用 you-get 触发完整流程**

在 Claude Code 中运行：
```
/generate-skill https://github.com/soimort/you-get
```
观察 Phase 3a 是否输出评分结果，格式为：
```
质量评分: XX/100
✅ 通过质量门
问题列表:
无
```

- [ ] **Step 2: 确认得分 ≥ 70**

you-get 是高质量案例（SKILL.md 95 行，troubleshooting.md 432 行，guides/ 3 个文件各 178-229 行），预期得分应为 90-100。若低于 70，检查评分逻辑是否误判。

---

## Task 6: 手动验证 — 低分触发修复（模拟缺失 troubleshooting）

**Files:** 无文件改动，仅验证

- [ ] **Step 1: 临时删除 troubleshooting 条目模拟低分**

生成完技能文件后，在 Phase 2.5 和 Phase 3a 之间暂停，手动删除 `/tmp/skill-gen-xxx/skill/troubleshooting.md` 中除 1 条以外的所有 `###` 条目。

- [ ] **Step 2: 确认 Phase 3a 检测到问题**

期望输出：
```
质量评分: 50/100
❌ 未通过质量门（需修复）
问题列表:
- troubleshooting 严重不足（当前 1 条，需 ≥ 3 条）
```

- [ ] **Step 3: 确认 Phase 3b 触发补写**

观察 Claude 是否自动补写了 troubleshooting 条目，并且使用了正确的 project_type（you-get 应为 cli）。

- [ ] **Step 4: 确认 Phase 3c 重评通过**

Phase 3c 重评后，troubleshooting 条目应 ≥ 3，得分应恢复至 ≥ 70。

---

## Task 7: 提交

**Files:**
- Modify: `skills/generate-skill.md`

- [ ] **Step 1: 确认只有 generate-skill.md 变更**

```bash
git diff --name-only
```

期望输出：
```
skills/generate-skill.md
```

- [ ] **Step 2: 提交**

```bash
git add skills/generate-skill.md
git commit -m "feat: add quality gate (Phase 3a/3b/3c) to generate-skill workflow"
```
