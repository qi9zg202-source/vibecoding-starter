# Vibecoding Starter

这是一个可直接复用的 Vibecoding 起步仓库。

它的目标不是只给你一个 Prompt 页面，而是给你一套可以持续复用的开发流程：

1. 用 `index.html` 收集本次任务
2. 自动生成标准执行 Prompt 和 Task Card
3. 用 `CLAUDE.md` / `AGENTS.md` 固定长期规则
4. 用 `skills/` 固定执行方法
5. 用验证脚本先检查控制台本身是否正常

如果你要新建一个完全新的项目，推荐做法不是复制旧业务仓库，而是从这个 starter 开始。

## 仓库里有什么

1. `index.html`
   AI 开发任务控制台。你在这里选择工程、模式、任务对象，并生成执行 Prompt。

2. `vibecoding.config.js`
   控制台配置入口。项目名称、工程列表、任务对象、默认模式，主要都在这里改。

3. `CLAUDE.md`
   固定开发纪律，比如先 plan、先更新设计文档和测试文档、再实现、最后验证。

4. `AGENTS.md`
   对外汇报口径。用于约束 AI 最终如何向你汇报结果。

5. `skills/`
   通用执行技能，例如任务卡执行、设计审查、页面交付验证。

6. `docs/features/ai_task_console/`
   控制台自己的设计、测试、记忆文档。

7. `scripts/verify_prompt_builder.sh`
   本地验证脚本。用来确认这个控制台本身没有被改坏。

## 推荐使用方式

最稳的方式是：

1. 先把这个仓库 clone 到本地
2. 直接把 clone 下来的目录命名成你的新项目名
3. 改 `vibecoding.config.js`
4. 改 `CLAUDE.md`
5. 改 `AGENTS.md`
6. 运行验证脚本
7. 打开 `index.html`
8. 用 `Design+Build` 发出第一个真实任务

## 完整示例：新项目名称叫 `homeagent`

下面给你一套可以直接照着敲的示例。

### 第一步：clone 这个 starter 到本地，并直接命名成新项目目录

在 shell 里执行：

```bash
PROJECT_NAME=homeagent
git clone git@github.com:qi9zg202-source/vibecoding-starter.git "$PROJECT_NAME"
cd "$PROJECT_NAME"
```

如果你习惯 HTTPS，也可以这样：

```bash
PROJECT_NAME=homeagent
git clone https://github.com/qi9zg202-source/vibecoding-starter.git "$PROJECT_NAME"
cd "$PROJECT_NAME"
```

执行完后，你本地就会得到一个新的项目目录：

```text
homeagent/
```

### 第二步：如果这是一个新的独立项目，把远端仓库地址改成你自己的

如果你准备把它变成一个真正的新项目，而不是继续连着 starter 仓库开发，建议马上改远端：

```bash
git remote remove origin
git remote add origin git@github.com:<your-account>/homeagent.git
```

如果你的 GitHub 上还没有这个仓库，就先去 GitHub 新建一个空仓库，再执行上面的命令。

### 第三步：修改项目配置

先改：

```text
vibecoding.config.js
```

你至少要改这些地方：

1. `pageTitle`
2. `consoleTitle`
3. `consoleIntro`
4. `defaultProjectKey`
5. `projects`
6. `projects[].objects`

对于 `homeagent`，你可以先按这个方向改：

- 把页面标题从 `Vibecoding Starter AI 开发任务控制台` 改成 `HomeAgent AI 开发任务控制台`
- 把默认工程名从 `Vibecoding Starter` 改成 `HomeAgent`
- 把默认任务对象从示例里的 `http://localhost:3000` / `http://localhost:3000/admin` 改成你自己的页面、URL 或文件路径

例如，如果你的新项目准备先做两个页面对象：

- `http://localhost:3000`
- `http://localhost:3000/dashboard`

就把默认对象改成这两个真实目标。

### 第四步：修改开发规则

再改：

```text
CLAUDE.md
```

这里放的是你项目自己的长期固定规则。

例如，`homeagent` 可以在这里写：

- 先 plan
- plan 后先更新设计文档和测试文档
- 再做实现
- 页面必须实际打开验证
- 没有验证不算完成

### 第五步：修改对外汇报口径

再改：

```text
AGENTS.md
```

这里决定 AI 最后怎么对你汇报。

例如你可以规定：

- 用中文汇报
- 只讲结果、验证、剩余风险
- 不要输出过多实现细节

### 第六步：执行一次本地验证

在项目根目录执行：

```bash
./scripts/verify_prompt_builder.sh
```

第一次执行时，脚本会自动准备它需要的运行依赖。正常情况下，最后你会看到：

```text
verify_prompt_builder: PASS
```

只看到 `PASS` 还不够，建议你再确认一遍有没有异常报错输出。

### 第七步：打开任务控制台

直接在浏览器打开：

```text
index.html
```

打开后，你会看到这几个主区块：

1. 工程
2. 执行模式
3. 任务卡
4. 固定协议
5. Execution Prompt

### 第八步：发出第一个真实任务

建议第一次直接用：

- 工程：`HomeAgent`
- 模式：`Design+Build`

任务卡可以先这样填：

**本次任务**

```text
初始化 HomeAgent 首页结构，先搭出主导航、工作区和设置入口。
```

**不要改动**

```text
先不要接入真实接口，不要做登录系统。
```

**验收标准**

```text
页面可以打开；首页结构清楚；主流程可点击；本地验证通过。
```

然后复制右侧生成的 `Execution Prompt`，直接发给 AI。

## 你真正需要改的，通常只有这几类

新项目启动时，通常只需要优先改下面这些文件：

1. `vibecoding.config.js`
2. `CLAUDE.md`
3. `AGENTS.md`
4. 项目自己的业务代码
5. 项目自己的设计文档和测试文档

控制台页面本身、技能结构、验证脚本，通常不用一开始就重写。

## 建议的启动顺序

如果你以后反复创建新项目，建议一直按这个顺序来：

1. `git clone` 这个 starter
2. 用新项目名作为目录名
3. 改远端仓库地址
4. 改配置文件
5. 改项目规则
6. 跑一次验证
7. 打开控制台
8. 用 `Design+Build` 发第一条任务

## 验证命令

项目根目录执行：

```bash
./scripts/verify_prompt_builder.sh
```

## 一句话理解这套 starter

这不是一个“Prompt 收藏页”模板。

它是一个新项目起步骨架：你 clone 下来，改成自己的项目配置，然后就可以直接开始按 Vibecoding 流程做 design & build。
