#!/usr/bin/env bash
set -euo pipefail

echo "==> public/ temizleniyor"
rm -rf public
mkdir -p public

echo "==> landing kopyalanıyor"
cp -R web_landing/. public/

echo "==> admin paneli derleniyor (base-href=/admin/)"
flutter build web -t lib/main_admin.dart --release --base-href /admin/

echo "==> admin public/admin/ altına kopyalanıyor"
mkdir -p public/admin
cp -R build/web/. public/admin/

echo "==> app-ads.txt kök kontrolü"
test -f public/app-ads.txt || cp web/app-ads.txt public/app-ads.txt

echo "==> deploy"
firebase deploy --only hosting

echo "==> bitti: https://xaiuygulama.web.app"
