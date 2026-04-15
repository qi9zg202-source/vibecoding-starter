#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RUNTIME_DIR="$ROOT_DIR/.runtime/verify_prompt_builder"

mkdir -p "$RUNTIME_DIR"

if [ ! -d "$RUNTIME_DIR/node_modules/jsdom" ]; then
  npm install --prefix "$RUNTIME_DIR" --no-save jsdom@22.1.0 >/dev/null
fi

export ROOT_DIR

node <<'NODE'
const fs = require('fs');
const path = require('path');
const { JSDOM } = require(path.join(process.env.ROOT_DIR, '.runtime/verify_prompt_builder/node_modules/jsdom'));

const filePath = path.join(process.env.ROOT_DIR, 'index.html');
const html = fs.readFileSync(filePath, 'utf8');
const dom = new JSDOM(html, {
  runScripts: 'dangerously',
  resources: 'usable',
  url: 'file://' + filePath,
  pretendToBeVisual: true,
  beforeParse(window) {
    window.navigator.clipboard = { writeText: async () => {} };
    window.document.execCommand = () => true;
  },
});

const wait = (ms) => new Promise((resolve) => dom.window.setTimeout(resolve, ms));

const assert = (condition, message) => {
  if (!condition) {
    throw new Error(message);
  }
};

(async () => {
  await wait(150);
  const { document } = dom.window;
  const text = (node) => (node ? String(node.textContent || '').trim() : '');

  assert(document.querySelector('script[src="./vibecoding.config.js"]'), 'starter 页面未引入独立配置文件');
  assert(dom.window.VIBECODING_CONFIG_SOURCE === 'external', 'starter 外部配置未加载');
  assert(text(document.getElementById('task-console-page-title')) === 'AI 开发任务控制台', 'starter 控制台标题错误');

  const articleOrder = Array.from(document.querySelectorAll('#task-console-card .section-grid > article')).map((node) => node.id);
  assert(articleOrder[0] === 'quick-guide-box', 'starter 推荐用法区块不在首位');
  assert(articleOrder[1] === 'project-switch-box', 'starter 工程区块顺序错误');
  assert(articleOrder[2] === 'task-mode-box', 'starter 模式区块顺序错误');
  assert(document.getElementById('advanced-output-box')?.open === false, 'starter 高级输出区不应默认展开');
  assert(document.getElementById('special-templates-box')?.open === false, 'starter 专项模板区不应默认展开');
  assert(text(document.getElementById('control-protocol-box')).includes('自动提 pull request'), 'starter 固定协议缺少自动提 PR / merge 要求');

  const summarize = () => ({
    project: document.querySelector('#project-switch-box .prompt-line-btn.is-selected')?.dataset.projectKey || '',
    mode: document.querySelector('#task-mode-box .prompt-line-btn.is-selected')?.dataset.modeKey || '',
    objects: Array.from(document.querySelectorAll('#task-object-table .prompt-object-row')).map((row) => ({
      text: text(row.children[2]),
      selected: row.classList.contains('is-selected'),
    })),
    executionPrompt: text(document.getElementById('execution-prompt-output')),
    taskCard: text(document.getElementById('task-card-output')),
    deliverables: text(document.getElementById('deliverables-output')),
  });

  const defaultState = summarize();
  assert(defaultState.project === 'main-app', 'starter 默认工程错误');
  assert(defaultState.mode === 'design-build', 'starter 默认模式错误');
  assert(defaultState.objects.some((item) => item.text === 'http://localhost:3000' && item.selected), 'starter 默认对象错误');
  assert(defaultState.executionPrompt.includes('task-card-executor'), 'starter Design+Build 未生成 task-card-executor');

  document.querySelector('[data-project-key="repo-root"]')?.click();
  await wait(0);
  const repoState = summarize();
  assert(repoState.objects.some((item) => item.text.endsWith('/index.html') && item.selected), 'starter repo-root 默认对象错误');

  document.querySelector('[data-mode-key="review"]')?.click();
  await wait(0);
  const reviewState = summarize();
  assert(reviewState.executionPrompt.includes('design-review'), 'starter Review 未生成 design-review');
  assert(reviewState.deliverables.includes('review_report'), 'starter Review 交付物错误');

  document.querySelector('[data-mode-key="github-publish"]')?.click();
  await wait(0);
  const publishState = summarize();
  assert(publishState.executionPrompt.includes('主分支收敛'), 'starter GitHub Publish 输出缺少主分支收敛');
  assert(publishState.executionPrompt.includes('本地恢复启动所有服务'), 'starter GitHub Publish 输出缺少服务恢复固定约束');
  assert(publishState.executionPrompt.includes('自动提 pull request'), 'starter GitHub Publish 输出缺少自动提 PR / merge 要求');
  assert(publishState.taskCard.includes('本地恢复启动所有服务'), 'starter GitHub Publish Task Card 缺少服务恢复固定约束');
  assert(publishState.taskCard.includes('自动提 pull request'), 'starter GitHub Publish Task Card 缺少自动提 PR / merge 要求');

  document.querySelector('[data-project-key="main-app"]')?.click();
  const adminRow = Array.from(document.querySelectorAll('#task-object-table .prompt-object-row')).find((row) => row.dataset.objectText === 'http://localhost:3000/admin');
  adminRow?.click();
  await wait(0);
  const multiState = summarize();
  assert(multiState.executionPrompt.includes('http://localhost:3000/admin'), 'starter 多选对象后 Execution Prompt 未同步');
  assert(multiState.taskCard.includes('http://localhost:3000/admin'), 'starter 多选对象后 Task Card 未同步');

  console.log('verify_prompt_builder: PASS');
})();
NODE
