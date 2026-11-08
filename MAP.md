# MAP — 每日牛股落地页

> **2026-11-08 起线上已不用本静态页**：每日牛股.vip 改为 clawbot 微信客服（wxkf02）的长期码域名，nginx（/etc/nginx/sites-available/meiri-niugu）反代 127.0.0.1:3001，根路径 302 到 /connect/open 显示临时码；后台地址 kf.每日牛股.vip。本仓库保留作备用落地页。

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

## 部署（正式：香港1区 103.185.248.205）
- `deploy/server-install.sh`：服务器上 root 执行，从 GitHub raw 拉 index.html 到 /var/www/meiri-niugu，新增独立 nginx server 块（sites-available/meiri-niugu）和独立证书（cert-name meiri-niugu）。可重复执行，再跑一次即更新页面。同机还有 kf.每日牛股.vip（wxkf02 clawbot）、星海云支付，脚本不改它们。
- 单行命令版放在项目文件 servers/meiri-niugu-deploy.cmd.txt
- DNS：@ 和 www 的 A 记录 → 103.185.248.205
- 改页面后的发布：推 main → 服务器重跑脚本
- 仓库里的 CNAME 是 GitHub Pages 备用方案，当前未启用
