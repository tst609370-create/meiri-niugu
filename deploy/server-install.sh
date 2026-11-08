#!/usr/bin/env bash
# 在 103.185.248.205 上用 root 执行：部署/更新 每日牛股.vip 落地页（nginx 静态站 + HTTPS）
# 可重复执行：再跑一次 = 拉取最新页面。只新增独立的 server 块和独立证书，不动现有站点。
set -euo pipefail
D=xn--wgvo5ky7fvrq.vip            # 每日牛股.vip
W=www.$D
ROOT=/var/www/meiri-niugu
RAW=https://raw.githubusercontent.com/tst609370-create/meiri-niugu/main
MYIP=103.185.248.205
TS=$(date +%Y%m%d%H%M%S)

# 0. 前提：DNS 已指到本机，nginx 已在跑（与 wxkf02 脚本一致）
for h in "$D" "$W"; do
  ip=$(getent hosts "$h" 2>/dev/null | awk '{print $1}' | head -1 || true)
  [ "$ip" = "$MYIP" ] || { echo "DNS 还没生效：$h -> ${ip:-无}，先加 A 记录"; exit 1; }
done
command -v nginx >/dev/null || { echo "本机没有 nginx，已停止，未做任何修改"; exit 1; }
command -v certbot >/dev/null || { apt-get update -qq && apt-get install -y -qq certbot python3-certbot-nginx; }

# 1. 配置文件位置：优先 sites-available/enabled，否则 conf.d
if [ -d /etc/nginx/sites-enabled ]; then
  CONF=/etc/nginx/sites-available/meiri-niugu; LINK=/etc/nginx/sites-enabled/meiri-niugu
else
  CONF=/etc/nginx/conf.d/meiri-niugu.conf; LINK=
fi

# 已被别的站点占用就停（避免和现有配置抢同一个 server_name）
OTHER=$(grep -rlE "server_name[^;]*[[:space:]]($D|$W)[[:space:];]" /etc/nginx/sites-enabled /etc/nginx/conf.d 2>/dev/null \
        | xargs -r readlink -f | grep -vx "$CONF" || true)
[ -z "$OTHER" ] || { echo "这些配置已经用了 $D：$OTHER；已停止，未做任何修改"; exit 1; }

# 2. 拉取页面（先下到临时目录，成功再替换）
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
curl -fsSL "$RAW/index.html" -o "$TMP/index.html"
grep -q 'id="risk"' "$TMP/index.html" || { echo "下载的页面不完整，已停止"; exit 1; }
mkdir -p "$ROOT"; [ -f "$ROOT/index.html" ] && cp -a "$ROOT/index.html" "$ROOT/index.html.bak-$TS"
install -m 644 "$TMP/index.html" "$ROOT/index.html"

# 3. nginx server 块：首次写 HTTP 版，certbot 再自动加 443；已存在（含证书配置）则不覆盖
if [ ! -f "$CONF" ]; then
  cat > "$CONF" <<NGX
server {
    listen 80;
    listen [::]:80;
    server_name $D $W;
    root $ROOT;
    index index.html;
    location / { try_files \$uri \$uri/ /index.html; }
    location ~ /\. { deny all; }
    add_header X-Content-Type-Options nosniff;
}
NGX
  [ -n "$LINK" ] && ln -sf "$CONF" "$LINK"
  if ! nginx -t; then
    echo "nginx -t 未通过，已撤销新增配置"; rm -f "$CONF" ${LINK:+"$LINK"}; exit 1
  fi
  systemctl reload nginx
else
  cp -a "$CONF" "$CONF.bak-$TS"
fi

# 4. 独立证书（cert-name 单独命名，不影响 kf/wxkf02 等现有证书）
certbot --nginx --non-interactive --agree-tos --register-unsafely-without-email \
  --cert-name meiri-niugu --redirect --keep-until-expiring -d "$D" -d "$W"
nginx -t && systemctl reload nginx

for u in "https://$D/" "https://$W/"; do
  curl -fsS -o /dev/null -w "$u -> %{http_code}\n" "$u"
done
