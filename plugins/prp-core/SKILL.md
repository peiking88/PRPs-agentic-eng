---
name: prp-core
version: 2.4.0
description: "PRP (Prompt-Rigorous-Protocol) core plugin providing structured workflow from PRD to PR. Includes /prp-prd, /prp-plan, /prp-implement, /prp-ralph autonomous loop, and multi-agent review commands."
user-invocable: false
---

# PRP Core

PRP 提供从需求到 PR 的结构化工作流。

## 命令一览

| 命令                     | 说明              |
| ------------------------ | ----------------- |
| `/prp-prd`               | 交互式 PRD 生成器 |
| `/prp-plan`              | 创建实施计划      |
| `/prp-implement`         | 执行计划并验证    |
| `/prp-issue-investigate` | 分析 GitHub Issue |
| `/prp-issue-fix`         | 执行修复          |
| `/prp-research-team`     | 设计研究团队      |
| `/prp-commit`            | 智能提交          |
| `/prp-pr`                | 创建 PR           |
| `/prp-review`            | PR 代码审查       |
| `/prp-review-agents`     | 多 Agent PR 审查  |
| `/prp-debug`             | 调试修复          |
| `/prp-ralph`             | 自主实施循环      |
| `/prp-ralph-cancel`      | 取消 Ralph 循环   |
| `/prp-codebase-question` | 代码库问答        |
