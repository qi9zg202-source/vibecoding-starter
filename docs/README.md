# Docs Guide

这个 starter 默认保留最小文档骨架。

新项目 clone 下来后，先运行：

```bash
./scripts/init_project.sh
```

初始化脚本会把项目名称和规则相关内容先写入基础文件，再进入后续开发。

推荐读取顺序：

1. `CLAUDE.md`
2. `AGENTS.md`
3. `docs/features/ai_task_console/design.md`
4. `docs/features/ai_task_console/MEMORY.md`
5. 当前任务相关代码文件

如果你在新项目里新增功能，建议按这个模式继续加文档：

```text
docs/features/<feature-name>/
  MEMORY.md
  design.md
  testing.md
```
