# Vibecoding Starter

这是一个可直接复用的 Vibecoding 起步仓库。

它的目标不是让你 clone 下来后再手动改一串文件，而是：

1. clone 到本地
2. 执行一次初始化脚本
3. 输入项目名、展示名、默认对象、远端仓库这些必要变量
4. 让脚本一次性把配置和规则文件写好
5. 然后直接开始用控制台发任务

## 现在的正确使用方式

不要再按“手动修改 `vibecoding.config.js`、`CLAUDE.md`、`AGENTS.md`”的方式启动新项目。

现在的标准流程是：

1. `git clone` starter 到本地
2. 进入新项目目录
3. 运行 `./scripts/init_project.sh`
4. 按提示输入项目初始化信息
5. 运行 `./scripts/verify_prompt_builder.sh`
6. 打开 `index.html`
7. 用 `Design+Build` 发第一条真实任务

## 这份骨架包含什么

1. `index.html`
   AI 开发任务控制台

2. `vibecoding.config.js`
   控制台配置入口

3. `CLAUDE.md`
   固定开发纪律

4. `AGENTS.md`
   对外汇报口径

5. `skills/`
   通用执行技能

6. `docs/features/ai_task_console/`
   控制台设计、测试、记忆文档

7. `scripts/init_project.sh`
   新项目初始化脚本

8. `scripts/verify_prompt_builder.sh`
   控制台本地验证脚本

## 完整示例：新项目名称叫 `homeagent`

下面这套就是推荐的实际用法。

### 第一步：clone 到本地，并直接用新项目名作为目录名

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

### 第二步：执行初始化脚本

执行：

```bash
./scripts/init_project.sh
```

然后脚本会问你几项必要信息。

例如，`homeagent` 这次初始化可以这样输入：

```text
项目代号（英文 / 目录名） [homeagent]: homeagent
项目展示名称 [Homeagent]: HomeAgent
主工程目录 [app]: app
默认主对象（页面 / URL / 文件） [http://localhost:3000]: http://localhost:3000
第二对象（可空） [http://localhost:3000/dashboard]: http://localhost:3000/dashboard
结果汇报语言 [中文]: 中文
新的 Git 远端地址（可空） []: git@github.com:qi9zg202-source/homeagent.git
```

### 第三步：初始化脚本会自动做什么

脚本执行完成后，会自动完成这些事：

1. 写入新的 `vibecoding.config.js`
2. 写入新的 `README.md`
3. 写入新的 `CLAUDE.md`
4. 写入新的 `AGENTS.md`
5. 写入控制台文档骨架
6. 创建主工程目录（默认是 `app/`）
7. 如果你填了远端仓库地址，就把 `origin` 改成新的仓库地址

也就是说，这一步之后，不应该还要求你再手动去改这些基础文件。

### 第四步：执行验证

初始化完成后，立刻执行：

```bash
./scripts/verify_prompt_builder.sh
```

正常情况下，你会看到：

```text
verify_prompt_builder: PASS
```

这个验证现在会读取当前项目自己的配置，不再写死 starter 默认值。

### 第五步：打开控制台

直接在浏览器打开：

```text
index.html
```

打开后，控制台已经会是 `HomeAgent` 的默认状态，不需要你再手改配置文件。

### 第六步：发出第一条真实任务

建议第一次直接这样用：

- 工程：`HomeAgent`
- 模式：`Design+Build`

任务卡可以先填：

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

## 如果你想完全无交互执行

也可以直接把参数一次传完：

```bash
./scripts/init_project.sh \
  --project-name homeagent \
  --display-name HomeAgent \
  --app-dir app \
  --primary-object http://localhost:3000 \
  --secondary-object http://localhost:3000/dashboard \
  --report-language 中文 \
  --remote git@github.com:qi9zg202-source/homeagent.git
```

这样脚本会直接完成初始化，不再逐项提问。

## 新项目的正确启动顺序

以后你每次新建项目，都建议固定按这个顺序：

1. `git clone` 这个 starter
2. 进入新项目目录
3. 跑 `./scripts/init_project.sh`
4. 跑 `./scripts/verify_prompt_builder.sh`
5. 打开 `index.html`
6. 用 `Design+Build` 发第一条任务

## 一句话理解现在这套 starter

这已经不是“clone 下来以后手动散改很多文件”的模板了。

它现在的正确定位是：**先执行初始化脚本，脚本把新项目基础配置写好，然后你直接开始 design & build。**
