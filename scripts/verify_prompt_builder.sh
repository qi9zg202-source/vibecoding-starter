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
  const config = dom.window.VIBECODING_CONFIG || {};
  const projects = Array.isArray(config.projects) ? config.projects : [];
  const modes = Array.isArray(config.modes) ? config.modes : [];
  const defaultProject = projects.find((item) => item.key === config.defaultProjectKey) || projects[0] || { key: '', objects: [] };
  const defaultMode = modes.find((item) => item.key === config.defaultModeKey) || modes[0] || { key: '', skills: [], deliverables: [], instructions: [] };
  const repoProject = projects.find((item) => item.key === 'repo-root') || projects[0] || { key: '', objects: [] };
  const reviewMode = modes.find((item) => item.key === 'review') || { skills: [], deliverables: [] };
  const publishMode = modes.find((item) => item.key === 'github-publish') || { instructions: [] };
  const defaultObjects = Array.isArray(defaultProject.objects) ? defaultProject.objects : [];
  const repoObjects = Array.isArray(repoProject.objects) ? repoProject.objects : [];
  const expectedDefaultSelected = defaultObjects.filter((item) => item.defaultSelected).map((item) => item.text);
  const expectedRepoSelected = repoObjects.filter((item) => item.defaultSelected).map((item) => item.text);

  assert(document.querySelector('script[src="./vibecoding.config.js"]'), 'starter 页面未引入独立配置文件');
  assert(dom.window.VIBECODING_CONFIG_SOURCE === 'external', 'starter 外部配置未加载');
  assert(text(document.getElementById('hero-title')) === String(config.heroTitle || ''), 'starter 顶部标题未按配置渲染');
  assert(text(document.getElementById('task-console-page-title')) === String(config.consoleTitle || ''), 'starter 控制台标题错误');

  const articleOrder = Array.from(document.querySelectorAll('#task-console-card .section-grid > article')).map((node) => node.id);
  assert(articleOrder[0] === 'quick-guide-box', 'starter 推荐用法区块不在首位');
  assert(articleOrder[1] === 'project-switch-box', 'starter 工程区块顺序错误');
  assert(articleOrder[2] === 'task-mode-box', 'starter 模式区块顺序错误');
  assert(document.getElementById('advanced-output-box')?.open === false, 'starter 高级输出区不应默认展开');
  assert(document.getElementById('special-templates-box')?.open === false, 'starter 专项模板区不应默认展开');

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
  assert(defaultState.project === String(defaultProject.key || ''), 'starter 默认工程错误');
  assert(defaultState.mode === String(defaultMode.key || ''), 'starter 默认模式错误');
  expectedDefaultSelected.forEach((itemText) => {
    assert(defaultState.objects.some((item) => item.text === itemText && item.selected), `starter 默认对象错误: ${itemText}`);
  });
  (defaultMode.skills || []).forEach((skill) => {
    assert(defaultState.executionPrompt.includes(skill), `starter 默认模式缺少 skill: ${skill}`);
  });

  document.querySelector('[data-project-key="repo-root"]')?.click();
  await wait(0);
  const repoState = summarize();
  expectedRepoSelected.forEach((itemText) => {
    assert(repoState.objects.some((item) => item.text === itemText && item.selected), `starter repo-root 默认对象错误: ${itemText}`);
  });

  document.querySelector('[data-mode-key="review"]')?.click();
  await wait(0);
  const reviewState = summarize();
  (reviewMode.skills || []).forEach((skill) => {
    assert(reviewState.executionPrompt.includes(skill), `starter Review 未生成 skill: ${skill}`);
  });
  (reviewMode.deliverables || []).forEach((deliverable) => {
    assert(reviewState.deliverables.includes(deliverable), `starter Review 交付物错误: ${deliverable}`);
  });

  document.querySelector('[data-mode-key="github-publish"]')?.click();
  await wait(0);
  const publishState = summarize();
  (publishMode.instructions || []).forEach((line) => {
    assert(publishState.executionPrompt.includes(line), `starter GitHub Publish 输出缺少说明: ${line}`);
  });

  document.querySelector(`[data-project-key="${defaultProject.key}"]`)?.click();
  const extraDefaultObject = defaultObjects.find((item) => !item.defaultSelected);
  if (extraDefaultObject) {
    const extraRow = Array.from(document.querySelectorAll('#task-object-table .prompt-object-row')).find((row) => row.dataset.objectText === extraDefaultObject.text);
    extraRow?.click();
    await wait(0);
    const multiState = summarize();
    assert(multiState.executionPrompt.includes(extraDefaultObject.text), `starter 多选对象后 Execution Prompt 未同步: ${extraDefaultObject.text}`);
    assert(multiState.taskCard.includes(extraDefaultObject.text), `starter 多选对象后 Task Card 未同步: ${extraDefaultObject.text}`);
  }

  console.log('verify_prompt_builder: PASS');
})();
NODE
