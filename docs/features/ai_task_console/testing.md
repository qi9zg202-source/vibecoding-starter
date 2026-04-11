# testing.md — AI 开发任务控制台

## 验证目标

验证 starter 控制台在以下维度正常工作：

1. 工程切换
2. 模式切换
3. 对象联动
4. 输出生成
5. 外部配置加载

## 执行方式

```bash
./scripts/verify_prompt_builder.sh
```

## 通过标准

1. 默认工程正确
2. 默认模式正确
3. 默认对象正确
4. `Execution Prompt` 正常生成
5. `Task Card` 正常生成
6. 高级输出默认折叠

## 初始化链路验证

除了控制台本身，还要验证 starter 初始化链路：

1. 在临时目录 clone 或复制 starter
2. 运行初始化脚本并传入新项目参数
3. 确认 `vibecoding.config.js` 已替换成新项目值
4. 确认 `README.md`、`CLAUDE.md`、`AGENTS.md` 已完成初始化
5. 再执行一次 `./scripts/verify_prompt_builder.sh`
6. 最终结果必须为 `PASS`
