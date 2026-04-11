window.VIBECODING_CONFIG = {
  pageTitle: '你的项目名 AI 开发任务控制台',
  consoleTitle: 'AI 开发任务控制台',
  consoleIntro: '这里用于收集本次任务变量，并生成可直接交给 AI 的执行入口。',
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
  baseExecutionPrefix: `所有开发遵循项目规范,先读取仓库根目录的 CLAUDE.md。
所有设计实现都先 plan，plan 后先更新设计文档和测试文档，再进行实现。
除非遇到不可逆操作、缺少关键输入、或存在重大风险，否则中间不要打断任务。`,
  standards: [],
  defaultProjectKey: 'main-app',
  defaultModeKey: 'design-build',
  projects: [
    {
      key: 'repo-root',
      name: '仓库根目录',
      switchText: '切换到工程 到:/absolute/path/to/your-project',
      objects: [
        { type: '文件', text: '/absolute/path/to/your-project/index.html', defaultSelected: true },
        { type: '文档', text: '/absolute/path/to/your-project/docs/features/ai_task_console/design.md' },
        { type: '文档', text: '/absolute/path/to/your-project/docs/features/ai_task_console/testing.md' },
      ],
    },
    {
      key: 'main-app',
      name: '主工程',
      switchText: '切换到工程 到:/absolute/path/to/your-project/app',
      objects: [
        { type: '页面', text: 'http://localhost:3000', defaultSelected: true },
        { type: '页面', text: 'http://localhost:3000/admin' },
      ],
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

window.VIBECODING_CONFIG_SOURCE = 'external';
