# Quality Gate Design — GitHub Skill Distiller

**Date:** 2026-04-28
**Topic:** 生成后自动质量评分与修复闭环
**Status:** Approved

## 背景

当前 `generate-skill.md` 在 Phase 2.5 做了简单自评，但没有量化评分，也没有低质量时的自动修复机制。用完即扔，用户无法判断生成的技能是否可用。

## 目标

在生成完成后立刻自动评分，低于阈值时自动修复弱项段落，无需用户介入，最终保证发布质量。

## 整体流程

```
Phase 2.5（已有）→ Phase 3a：结构评分 → Phase 3b：AI 定向修复 → Phase 3c：重评 → 发布 / 报告
```

## Phase 3a：结构评分（规则，无 API 消耗）

对生成的技能文件检查 6 个维度：

| 检查项 | 分值 |
|--------|------|
| SKILL.md 存在且 frontmatter 含 name/description | 10 |
| 必需段落齐全（## 描述 / ## 用法 / ## 示例） | 20 |
| guides/ 至少 1 个文件 ≥ 50 行 | 20 |
| troubleshooting 至少 3 个 ### 条目 | 20 |
| 示例块含真实可运行命令（非 `<placeholder>` 形式） | 15 |
| 全文无占位符文本（TBD / TODO / xxx） | 15 |

**满分 100，阈值 70。** 低于 70 进入 Phase 3b。

输出格式：
```json
{ "score": 75, "issues": ["troubleshooting 只有 1 条", "guides/ 文件为空"] }
```

## Phase 3b：AI 定向修复

只对失分段落重写，不动合格内容。针对每个失分项构造独立修复 prompt，例如：

> "troubleshooting 段落只有 1 条，需要补充到至少 3 条。结合项目类型（{project_type}）和已有 README 内容，补写 2 条真实场景的故障排查条目，直接替换原有段落。"

修复后重跑 Phase 3a，**最多循环 2 次**。

## Phase 3c：重评与决策

```
iteration = 0
while score < 70 and iteration < 2:
    修复失分段落
    重新评分
    iteration++

if score >= 70 → 继续发布
else → 输出剩余问题清单，询问是否强制发布
```

## 边界情况

| 情况 | 处理方式 |
|------|---------|
| 项目 README 极简（< 50 行） | troubleshooting 可降为 2 条，记录警告而非失败 |
| 2 轮后仍 < 70 | 输出失分清单 + 当前得分，询问是否跳过质量门 |
| 修复引入新占位符 | 第二轮评分自动检测，触发第二次修复 |
| 用户只生成不发布 | 质量门正常跑，最后跳过发布，输出评分报告 |

## 改动范围

**只改动一个文件**：`skills/generate-skill.md`，在现有 Phase 2.5 末尾追加 Phase 3 指令块。不新增脚本，不改现有逻辑。

## 验证方式

用现有 cases 手动跑验证：

1. `cases/you-get` 跑全流程，确认 Phase 3 输出分数
2. 故意删掉 troubleshooting 段落，确认触发修复
3. `cases/fastapi`（已知误判为 cli）确认修复 prompt 使用正确的 project_type
