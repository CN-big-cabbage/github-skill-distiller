# 自动化技能生成设计方案

**日期**: 2026-04-10
**状态**: 已批准

## 目标

给定一个 GitHub URL，自动分析项目、生成技能、推送 GitHub 并发布到 ClawHub。

## 使用方式

```bash
/generate-skill https://github.com/soimort/you-get
```

## 架构

```
输入: GitHub URL
  │
  ▼
[Phase 1] scripts/analyze-repo.sh
  - gh api 获取元数据 (stars, description, language, topics)
  - clone 到 /tmp，扫描 README + docs/ 结构
  - 输出 project-profile.json
  │
  ▼
[Phase 2] Claude AI 生成内容 (Skill 核心逻辑)
  - 读取 profile + 源项目文档
  - 生成: SKILL.md, guides/*.md, troubleshooting.md
  - 以 you-get/ 的质量为标准
  │
  ▼
[Phase 3] workflows/validate-skill.sh (增强版)
  - 文件完整性 + 无占位符 + frontmatter 格式 + 最小字数
  │
  ▼
[Phase 4] 用户审阅确认 ← 唯一暂停点
  │
  ▼
[Phase 5] scripts/push-and-publish.sh
  - gh repo create skill-<name> --public
  - git init + commit + push
  - clawhub publish (可用时)
```

## 输出

- 每个技能创建为独立 GitHub 仓库（如 `skill-you-get`）
- 全自动流程，仅在发布前暂停让用户确认

## 文件清单

| 文件 | 类型 | 作用 |
|------|------|------|
| `skills/generate-skill.md` | 新增 | Claude Code Skill 主文件 |
| `scripts/analyze-repo.sh` | 新增 | GitHub 项目分析脚本 |
| `scripts/push-and-publish.sh` | 新增 | 推送+发布脚本 |
| `templates/clawhub/guide.md.template` | 新增 | 指导文档模板 |
| `templates/clawhub/troubleshooting.md.template` | 新增 | 故障排查模板 |
| `workflows/validate-skill.sh` | 增强 | 增强验证脚本 |

## 设计决策

1. **Skill 是 orchestrator**：调用脚本完成机械工作，自己负责 AI 内容生成
2. **project-profile.json 是衔接点**：脚本产出结构化数据，AI 基于数据生成内容
3. **模板提供骨架，AI 填充血肉**：根据项目特征生成有价值的内容
4. **发布前确认**：展示生成结果摘要，用户确认后才 push + publish
