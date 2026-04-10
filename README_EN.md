# Skill Creation Methodology

[中文](./README.md) | English

A complete AI skill creation methodology framework that helps developers convert GitHub projects into AI skills and publish them to the open-source community.

## Introduction

Creating AI skills traditionally takes 20-30 hours. This methodology adopts a **rapid iteration approach**, reducing the time to **5-6 hours** — a 75% time saving.

Core concept: **Given a GitHub URL, automatically analyze the project, generate skills, validate quality, and publish.**

## Features

- **One-Click Generation**: Input a GitHub URL to automatically analyze and generate a complete skill package
- **Intelligent Analysis**: Automatically extracts project metadata (stars, language, dependencies, doc structure)
- **AI-Driven Content Generation**: Generates SKILL.md, guides, and troubleshooting docs based on project documentation
- **Automated Validation**: Four-dimensional checks — file structure, frontmatter, placeholders, and content quality
- **Dual-Platform Publishing**: Supports ClawHub + GitHub Marketplace
- **Complete Methodology**: 8 core documents covering the full lifecycle from research to maintenance
- **Reusable Templates**: Ready-to-use templates for SKILL.md, guides, and troubleshooting
- **Reference Examples**: 3 graduated example projects + 1 production-grade case study (you-get)

## Project Structure

```
skill-creation-methodology/
├── skills/                          # Claude Code Skills
│   └── generate-skill.md            # Core: auto skill generation orchestrator
├── scripts/                         # Automation scripts
│   ├── analyze-repo.sh              # GitHub project analysis (metadata + structure scan)
│   ├── push-and-publish.sh          # Push to GitHub + publish to ClawHub
│   └── publish-you-get.sh           # you-get publishing script
├── workflows/                       # Workflow scripts
│   ├── create-skill.sh              # Quick skill scaffolding
│   ├── validate-skill.sh            # Skill quality validation (enhanced)
│   └── publish-clawhub.sh           # ClawHub publishing flow
├── templates/                       # Reusable templates
│   └── clawhub/
│       ├── SKILL.md.template        # Main skill file template
│       ├── guide.md.template        # Usage guide template
│       └── troubleshooting.md.template  # Troubleshooting template
├── docs/                            # Core methodology documents
│   ├── 00-overview.md               # Overview
│   ├── 01-platform-research.md      # Platform research
│   ├── 02-skill-design-principles.md # Design principles
│   ├── 03-creation-workflow.md      # Creation workflow
│   ├── 04-testing-validation.md     # Testing & validation
│   ├── 05-publishing-guide.md       # Publishing guide
│   ├── 06-maintenance-strategy.md   # Maintenance strategy
│   └── 07-case-study-kubeasz.md     # Case study
├── examples/                        # Example projects
│   ├── hello-world/                 # Beginner example
│   ├── data-processor/              # Intermediate example
│   └── kubeasz-deploy/              # Production-grade example
├── you-get/                         # Complete skill case study (you-get)
│   ├── SKILL.md                     # Main skill file
│   ├── guides/                      # Guides (installation / quickstart / advanced)
│   ├── troubleshooting.md           # Troubleshooting (10 common issues)
│   └── configs/                     # Configuration examples
├── checklists/                      # Checklists
│   └── pre-creation-checklist.md    # Pre-creation assessment
└── resources/                       # Reference materials
    ├── platform-comparison.md       # Platform comparison
    ├── skill-quality-metrics.md     # Quality metrics
    └── common-patterns.md           # Common design patterns
```

## Quick Start

### Option 1: Auto-Generate (Recommended)

After installing the `generate-skill` skill in Claude Code, complete the entire flow with one command:

```bash
/generate-skill https://github.com/user/project
```

Automatically: Project Analysis → AI Content Generation → Quality Validation → User Confirmation → Push & Publish

### Option 2: Manual Flow

#### 1. Analyze Project (1 min)

```bash
./scripts/analyze-repo.sh https://github.com/user/project /tmp/my-skill
```

Outputs `project-profile.json` with project metadata and structure information.

#### 2. Scaffold Skill (1 min)

```bash
./workflows/create-skill.sh my-skill
```

#### 3. Fill Content (3-4 hours)

Refer to the complete case study in the `you-get/` directory and edit the generated template files.

#### 4. Validate Quality (1 min)

```bash
./workflows/validate-skill.sh my-skill
```

Four-dimensional checks: File Structure → Frontmatter → Placeholders → Content Quality

#### 5. Push & Publish (1 min)

```bash
./scripts/push-and-publish.sh my-skill
```

Automatically creates a GitHub repository and pushes code. Publishes to ClawHub when the CLI is available.

## Value Proposition

| Dimension | This Approach | Traditional |
|-----------|--------------|-------------|
| Creation Time | 5-6 hours | 20-30 hours |
| Learning Curve | Rapid iteration | Learn-then-do |
| Quality Assurance | Automated validation | Manual checks |
| Platform Coverage | Dual-platform templates | Single-platform |
| Content Generation | AI-powered | Manual writing |

## Use Cases

- Convert GitHub projects into publishable skills
- Learn the skill creation methodology
- Multi-platform skill publishing
- Rapidly validate skill ideas

## Documentation

| Document | Description |
|----------|-------------|
| [Overview](docs/00-overview.md) | Methodology introduction and quick start |
| [Platform Research](docs/01-platform-research.md) | ClawHub / GitHub Marketplace comparison |
| [Design Principles](docs/02-skill-design-principles.md) | 6 core elements + quality assessment |
| [Creation Workflow](docs/03-creation-workflow.md) | Phase 0-5 rapid iteration process |
| [Testing & Validation](docs/04-testing-validation.md) | Validation strategies and checklists |
| [Publishing Guide](docs/05-publishing-guide.md) | Dual-platform publishing steps |
| [Maintenance Strategy](docs/06-maintenance-strategy.md) | Version iteration and user feedback |
| [Case Study](docs/07-case-study-kubeasz.md) | kubeasz production-grade case study |

## License

[MIT License](LICENSE)
