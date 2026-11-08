# MAP — 每日牛股落地页

- 域名：每日牛股.vip（punycode：`xn--wgvo5ky7fvrq.vip`）
- 类型：纯静态单页，无构建步骤

## 目录
| 文件 | 作用 |
|---|---|
| index.html | 整个落地页（样式、内容内联） |
| CNAME | GitHub Pages 自定义域名（punycode 写法） |
| tests/check.js | Playwright 最小检查：区块存在、风险提示、375px 无横向溢出、无 JS 报错 |

## 常见改动
- 改文案：index.html 中 `.hero`（首屏）、`#what`（每期内容）、`#sample`（示例表）
- 改订阅入口：`#joinBtn` 的 href（客服链接 / 二维码图）
- 风险提示：`#risk`，不要删
- 主色：`:root` 的 `--red`

## 运行 / 验证
- 本地预览：`python3 -m http.server` 后打开 http://localhost:8000
- 检查：`node tests/check.js`（输出 OK 即通过）

## 部署
- GitHub Pages：仓库 Settings → Pages → main 分支根目录；DNS 加 CNAME 指向 `tst609370-create.github.io`
- 或任意服务器 nginx/Caddy 静态目录，DNS 加 A 记录
