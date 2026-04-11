#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CURRENT_DIR_NAME="$(basename "$ROOT_DIR")"

PROJECT_NAME=""
DISPLAY_NAME=""
APP_DIR="app"
PRIMARY_OBJECT="http://localhost:3000"
SECONDARY_OBJECT="http://localhost:3000/dashboard"
REPORT_LANGUAGE="中文"
REMOTE_URL=""
PROJECT_NAME_FROM_ARG=0
DISPLAY_NAME_FROM_ARG=0
APP_DIR_FROM_ARG=0
PRIMARY_OBJECT_FROM_ARG=0
SECONDARY_OBJECT_FROM_ARG=0
REPORT_LANGUAGE_FROM_ARG=0
REMOTE_URL_FROM_ARG=0

usage() {
  cat <<'EOF'
用法：
  ./scripts/init_project.sh

可选参数：
  --project-name <name>       项目代号，例如 homeagent
  --display-name <name>       页面展示名称，例如 HomeAgent
  --app-dir <path>            主工程目录，默认 app
  --primary-object <value>    默认主对象，默认 http://localhost:3000
  --secondary-object <value>  默认第二对象，可空，默认 http://localhost:3000/dashboard
  --report-language <value>   汇报语言，默认 中文
  --remote <url>              可选，初始化后写入 git remote origin
  --help                      显示帮助
EOF
}

to_default_display_name() {
  node - "$1" <<'NODE'
const raw = String(process.argv[2] || '').trim();
if (!raw) {
  process.stdout.write('');
  process.exit(0);
}
const parts = raw
  .split(/[^a-zA-Z0-9]+/)
  .map((part) => part.trim())
  .filter(Boolean);
if (!parts.length) {
  process.stdout.write(raw);
  process.exit(0);
}
const display = parts.map((part) => part.charAt(0).toUpperCase() + part.slice(1)).join('');
process.stdout.write(display);
NODE
}

prompt_value() {
  local __var_name="$1"
  local __label="$2"
  local __default="${3-}"
  local __input=""
  if [ -n "$__default" ]; then
    printf "%s [%s]: " "$__label" "$__default"
  else
    printf "%s: " "$__label"
  fi
  if [ -t 0 ]; then
    read -r __input
  else
    __input=""
  fi
  if [ -z "$__input" ]; then
    __input="$__default"
  fi
  printf -v "$__var_name" '%s' "$__input"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-name)
      PROJECT_NAME="${2-}"
      PROJECT_NAME_FROM_ARG=1
      shift 2
      ;;
    --display-name)
      DISPLAY_NAME="${2-}"
      DISPLAY_NAME_FROM_ARG=1
      shift 2
      ;;
    --app-dir)
      APP_DIR="${2-}"
      APP_DIR_FROM_ARG=1
      shift 2
      ;;
    --primary-object)
      PRIMARY_OBJECT="${2-}"
      PRIMARY_OBJECT_FROM_ARG=1
      shift 2
      ;;
    --secondary-object)
      SECONDARY_OBJECT="${2-}"
      SECONDARY_OBJECT_FROM_ARG=1
      shift 2
      ;;
    --report-language)
      REPORT_LANGUAGE="${2-}"
      REPORT_LANGUAGE_FROM_ARG=1
      shift 2
      ;;
    --remote)
      REMOTE_URL="${2-}"
      REMOTE_URL_FROM_ARG=1
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "未知参数: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$PROJECT_NAME" ]; then
  if [ "$CURRENT_DIR_NAME" != "vibecoding-starter" ]; then
    PROJECT_NAME="$CURRENT_DIR_NAME"
  fi
  prompt_value PROJECT_NAME "项目代号（英文 / 目录名）" "$PROJECT_NAME"
fi

if [ -z "$PROJECT_NAME" ]; then
  echo "项目代号不能为空。" >&2
  exit 1
fi

if [ -z "$DISPLAY_NAME" ]; then
  DISPLAY_NAME="$(to_default_display_name "$PROJECT_NAME")"
  prompt_value DISPLAY_NAME "项目展示名称" "$DISPLAY_NAME"
fi

if [ -z "$DISPLAY_NAME" ]; then
  echo "项目展示名称不能为空。" >&2
  exit 1
fi

if [ "$APP_DIR_FROM_ARG" -eq 0 ]; then
  prompt_value APP_DIR "主工程目录" "$APP_DIR"
fi
if [ "$PRIMARY_OBJECT_FROM_ARG" -eq 0 ]; then
  prompt_value PRIMARY_OBJECT "默认主对象（页面 / URL / 文件）" "$PRIMARY_OBJECT"
fi
if [ "$SECONDARY_OBJECT_FROM_ARG" -eq 0 ]; then
  prompt_value SECONDARY_OBJECT "第二对象（可空）" "$SECONDARY_OBJECT"
fi
if [ "$REPORT_LANGUAGE_FROM_ARG" -eq 0 ]; then
  prompt_value REPORT_LANGUAGE "结果汇报语言" "$REPORT_LANGUAGE"
fi
if [ "$REMOTE_URL_FROM_ARG" -eq 0 ]; then
  prompt_value REMOTE_URL "新的 Git 远端地址（可空）" "$REMOTE_URL"
fi

export INIT_ROOT_DIR="$ROOT_DIR"
export INIT_PROJECT_NAME="$PROJECT_NAME"
export INIT_DISPLAY_NAME="$DISPLAY_NAME"
export INIT_APP_DIR="$APP_DIR"
export INIT_PRIMARY_OBJECT="$PRIMARY_OBJECT"
export INIT_SECONDARY_OBJECT="$SECONDARY_OBJECT"
export INIT_REPORT_LANGUAGE="$REPORT_LANGUAGE"

node <<'NODE'
const fs = require('fs');
const path = require('path');

const rootDir = process.env.INIT_ROOT_DIR;
const projectName = String(process.env.INIT_PROJECT_NAME || '').trim();
const displayName = String(process.env.INIT_DISPLAY_NAME || '').trim();
const appDir = String(process.env.INIT_APP_DIR || 'app').trim() || 'app';
const primaryObject = String(process.env.INIT_PRIMARY_OBJECT || '').trim();
const secondaryObject = String(process.env.INIT_SECONDARY_OBJECT || '').trim();
const reportLanguage = String(process.env.INIT_REPORT_LANGUAGE || '中文').trim() || '中文';

const repoRootPath = rootDir;
const appRootPath = path.join(rootDir, appDir);
const docsRoot = path.join(rootDir, 'docs', 'features', 'ai_task_console');

fs.mkdirSync(appRootPath, { recursive: true });
fs.mkdirSync(docsRoot, { recursive: true });

const detectType = (value) => {
  if (/^https?:\/\//i.test(value)) {
    return '页面';
  }
  if (/\.(html|md|js|ts|tsx|jsx|json|py|sh|css|scss)$/i.test(value) || value.startsWith('/') || value.includes(path.sep)) {
    return '文件';
  }
  return '对象';
};

const defaultObjects = [
  { type: detectType(primaryObject), text: primaryObject, defaultSelected: true },
];

if (secondaryObject) {
  defaultObjects.push({ type: detectType(secondaryObject), text: secondaryObject });
}

const consoleConfig = {
  heroTitle: displayName,
  heroNote: `这里是 ${displayName} 的 AI 开发任务控制台。当前仓库已经完成初始化，可以直接开始发任务。`,
  pageTitle: `${displayName} AI 开发任务控制台`,
  consoleTitle: 'AI 开发任务控制台',
  consoleIntro: `这里用于收集 ${displayName} 的本次任务变量，并生成可直接交给 AI 的执行入口。`,
  quickGuideTitle: '你现在就这样用',
  quickGuideSteps: [
    { title: '1. 选工程', description: '先切到当前要工作的工程。' },
    { title: '2. 选模式', description: '默认先用 Design+Build；只审查时再切 Review。' },
    { title: '3. 填任务卡', description: '至少填本次任务、不要改什么、验收标准。' },
    { title: '4. 复制 Execution Prompt', description: '直接复制主输出发给 AI。' },
  ],
  projectSwitchNote: '切换工程后，任务对象会自动跟着切换。',
  modeSwitchNote: '不同模式会生成不同的执行 Prompt、Task Card 和交付物。',
  taskConsoleNote: '这里只填写本次任务变量，固定规则保持只读。',
  controlProtocolNote: '固定协议只展示，不和本次任务输入混写。',
  executionPromptNote: '这是主输出，直接复制发给 AI。',
  fixedProtocolLines: [
    '所有设计实现都先 plan。',
    'plan 完成后先更新设计文档和测试文档。',
    '再进行实现，并在完成后做实际验证。',
  ],
  baseExecutionPrefix: `所有开发遵循项目规范,先读取仓库根目录的 CLAUDE.md。\n所有设计实现都先 plan，plan 后先更新设计文档和测试文档，再进行实现。\n除非遇到不可逆操作、缺少关键输入、或存在重大风险，否则中间不要打断任务。`,
  standards: [],
  defaultProjectKey: 'main-app',
  defaultModeKey: 'design-build',
  projects: [
    {
      key: 'repo-root',
      name: '仓库根目录',
      switchText: `切换到工程 到:${repoRootPath}`,
      objects: [
        { type: '文件', text: path.join(repoRootPath, 'index.html'), defaultSelected: true },
        { type: '文档', text: path.join(repoRootPath, 'docs', 'features', 'ai_task_console', 'design.md') },
        { type: '文档', text: path.join(repoRootPath, 'docs', 'features', 'ai_task_console', 'testing.md') },
      ],
    },
    {
      key: 'main-app',
      name: displayName,
      switchText: `切换到工程 到:${appRootPath}`,
      objects: defaultObjects,
    },
  ],
  modes: [
    {
      key: 'review',
      label: 'Review',
      summary: '只做审查，不直接实现。',
      skills: ['design-review'],
      instructions: [
        '先审查当前设计和任务定义。',
        '明确指出不清楚、不专业或不利于交付的地方。',
        '给出下一版重构建议。',
        '不要直接开始实现。',
      ],
      deliverables: ['review_report', 'redesign_recommendation'],
    },
    {
      key: 'design-build',
      label: 'Design+Build',
      summary: '完整执行：plan -> 文档 -> 实现 -> 验证。',
      skills: ['task-card-executor', 'ui-delivery-verifier（页面 / 交互任务）'],
      instructions: [
        '先基于任务卡输出 plan。',
        '先更新设计文档和测试文档。',
        '再进行实现；如果方案调整，先同步文档。',
        '完成后执行验证，并更新 MEMORY.md。',
      ],
      deliverables: ['design_doc', 'test_doc', 'implementation', 'verification', 'memory_record'],
    },
    {
      key: 'docs-only',
      label: 'Docs Only',
      summary: '只更新文档，不进行代码实现。',
      skills: ['task-card-executor'],
      instructions: [
        '先输出 plan，但只围绕文档和规范更新。',
        '只更新设计文档、测试文档和 MEMORY.md。',
        '不要进行代码实现。',
      ],
      deliverables: ['design_doc', 'test_doc', 'memory_record'],
    },
    {
      key: 'github-publish',
      label: 'GitHub Publish',
      summary: '只做发布收尾。',
      skills: ['task-card-executor'],
      instructions: [
        '确认当前变更已经完成验证。',
        '提交并推送当前变更。',
        '执行主分支收敛，并保持本地与 GitHub 一致。',
      ],
      deliverables: ['git_commit', 'git_push', 'main_sync', 'publish_verification'],
    },
  ],
};

const reportLanguageLine = reportLanguage.includes('英')
  ? 'Use English in the final response.'
  : '请用中文汇报最终结果。';

const readme = `# ${displayName}

这个仓库已经由 \`vibecoding-starter\` 完成初始化。

## 当前初始化结果

1. 项目代号：\`${projectName}\`
2. 项目展示名称：\`${displayName}\`
3. 主工程目录：\`${appDir}\`
4. 默认主对象：\`${primaryObject}\`
${secondaryObject ? `5. 第二对象：\`${secondaryObject}\`\n` : ''}${secondaryObject ? '6' : '5'}. 结果汇报语言：\`${reportLanguage}\`

## 第一次使用

1. 初始化脚本已经自动完成控制台验证。

2. 打开：

\`\`\`text
index.html
\`\`\`

3. 在控制台里：
   - 工程选 \`${displayName}\`
   - 模式选 \`Design+Build\`
   - 填写任务卡
   - 复制 \`Execution Prompt\`
   - 直接发给 AI

## 如果你想重新初始化

执行：

\`\`\`bash
./scripts/init_project.sh
\`\`\`

脚本结束前会自动再执行一次：

\`\`\`bash
./scripts/verify_prompt_builder.sh
\`\`\`

## 建议的第一条任务

\`\`\`text
为 ${displayName} 建立第一版首页结构，并补主导航、工作区和设置入口。
\`\`\`
`;

const claude = `# CLAUDE.md — ${displayName}

## 项目初始化信息

1. 项目代号：${projectName}
2. 项目展示名称：${displayName}
3. 仓库根目录：${repoRootPath}
4. 主工程目录：${appRootPath}

## 固定规则

1. 所有设计实现都先 plan
2. plan 后先更新设计文档和测试文档
3. 再进行代码实现
4. 页面或 UI 任务必须实际打开验证
5. 除非遇到不可逆操作、缺少关键输入或重大风险，否则不中断任务

## 完成标准

1. 功能完成
2. 设计文档已更新
3. 测试文档已更新
4. 已完成验证
5. 已向用户汇报结果与剩余风险
`;

const agents = reportLanguage.includes('英')
  ? `# AGENTS.md — ${displayName}

When reporting results back to the user:

1. ${reportLanguageLine}
2. Explain what changed in plain language.
3. Explain what was verified.
4. Call out any remaining risk or follow-up.

Execution rules:

1. Keep the actual work fully technical.
2. Verify changes before reporting back.
3. Do not hand back an unverified first draft.
4. Only stop for user input when there is a real blocker.
`
  : `# AGENTS.md — ${displayName}

向用户汇报时：

1. ${reportLanguageLine}
2. 用直接、清楚的自然语言说明做了什么
3. 说明已经验证了什么
4. 说明剩余风险或后续事项

执行规则：

1. 实际工作过程保持技术化和严格
2. 汇报前先验证
3. 不要把未经验证的初稿交回给用户
4. 只有遇到真实阻塞才停下来问用户
`;

const docsGuide = `# Docs Guide — ${displayName}

这是 ${displayName} 的默认文档骨架。

推荐读取顺序：

1. \`CLAUDE.md\`
2. \`AGENTS.md\`
3. \`docs/features/ai_task_console/design.md\`
4. \`docs/features/ai_task_console/MEMORY.md\`
5. 当前任务相关代码文件

如果你在新项目里新增功能，建议按这个模式继续加文档：

\`\`\`text
docs/features/<feature-name>/
  MEMORY.md
  design.md
  testing.md
\`\`\`
`;

const designDoc = `# design.md — ${displayName} AI 开发任务控制台

## 目标

这个仓库的首页不是营销页，而是 ${displayName} 的任务控制台。

它负责：

1. 选择当前工程
2. 选择执行模式
3. 填写任务卡
4. 生成 \`Execution Prompt\`
5. 生成结构化 \`Task Card\`

## 当前默认对象

1. ${primaryObject}
${secondaryObject ? `2. ${secondaryObject}\n` : ''}
## 初始化说明

当前仓库已经通过 \`./scripts/init_project.sh\` 完成初始化。
后续如果需要调整默认对象、展示名或主工程目录，应优先重新执行初始化脚本，避免手动散改多个文件。
`;

const testingDoc = `# testing.md — ${displayName} AI 开发任务控制台

## 验证目标

验证当前项目控制台在以下维度正常工作：

1. 工程切换
2. 模式切换
3. 对象联动
4. 输出生成
5. 外部配置加载

## 执行方式

\`\`\`bash
./scripts/verify_prompt_builder.sh
\`\`\`

## 通过标准

1. 默认工程正确
2. 默认模式正确
3. 默认对象正确
4. \`Execution Prompt\` 正常生成
5. \`Task Card\` 正常生成
6. 高级输出默认折叠
`;

const memoryDoc = `# MEMORY.md — ${displayName} AI 开发任务控制台

## 当前状态

- 当前仓库已经完成 starter 初始化
- 已写入新的项目名称、展示名称和默认对象
- 已保留通用 skills
- 已保留控制台自检脚本

## 下一步

1. 跑一次 \`./scripts/verify_prompt_builder.sh\`
2. 打开 \`index.html\`
3. 用真实任务跑一次 \`Design+Build\`
`;

const write = (relativePath, content) => {
  fs.writeFileSync(path.join(rootDir, relativePath), content, 'utf8');
};

write(
  'vibecoding.config.js',
  `window.VIBECODING_CONFIG = ${JSON.stringify(consoleConfig, null, 2)};\n\nwindow.VIBECODING_CONFIG_SOURCE = 'external';\n`,
);
write('README.md', readme);
write('CLAUDE.md', claude);
write('AGENTS.md', agents);
write(path.join('docs', 'README.md'), docsGuide);
write(path.join('docs', 'features', 'ai_task_console', 'design.md'), designDoc);
write(path.join('docs', 'features', 'ai_task_console', 'testing.md'), testingDoc);
write(path.join('docs', 'features', 'ai_task_console', 'MEMORY.md'), memoryDoc);
NODE

if [ -n "$REMOTE_URL" ] && git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git -C "$ROOT_DIR" remote get-url origin >/dev/null 2>&1; then
    git -C "$ROOT_DIR" remote set-url origin "$REMOTE_URL"
  else
    git -C "$ROOT_DIR" remote add origin "$REMOTE_URL"
  fi
fi

echo "开始执行初始化后的自动验证..."
"$ROOT_DIR/scripts/verify_prompt_builder.sh"

echo "初始化完成。"
echo "项目代号: $PROJECT_NAME"
echo "项目展示名称: $DISPLAY_NAME"
echo "主工程目录: $APP_DIR"
echo "默认主对象: $PRIMARY_OBJECT"
if [ -n "$SECONDARY_OBJECT" ]; then
  echo "第二对象: $SECONDARY_OBJECT"
fi
if [ -n "$REMOTE_URL" ]; then
  echo "远端仓库: $REMOTE_URL"
fi
echo "自动验证已完成。下一步可以直接打开 index.html 开始发任务。"
