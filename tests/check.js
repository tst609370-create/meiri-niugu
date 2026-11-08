// 最小检查：页面能加载、关键区块存在、手机宽度无横向滚动、含风险提示
const { chromium } = require('playwright');
const path = require('path');
(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: 375, height: 800 } });
  const errs = []; p.on('pageerror', e => errs.push(e.message));
  await p.goto('file://' + path.resolve(__dirname, '../index.html'));
  for (const id of ['what', 'sample', 'join', 'risk']) if (!(await p.$('#' + id))) throw new Error('缺少 #' + id);
  if (!(await p.textContent('#risk')).includes('不构成任何投资建议')) throw new Error('缺风险提示');
  const sw = await p.evaluate(() => document.documentElement.scrollWidth);
  if (sw > 375) throw new Error('手机宽度横向溢出 ' + sw);
  if (errs.length) throw new Error(errs.join('\n'));
  await p.screenshot({ path: process.argv[2] || '/tmp/mobile.png', fullPage: true });
  await p.setViewportSize({ width: 1280, height: 800 });
  await p.screenshot({ path: (process.argv[2] || '/tmp/mobile.png').replace('.png', '-desktop.png') });
  console.log('OK'); await b.close();
})().catch(e => { console.error(e.message); process.exit(1); });
