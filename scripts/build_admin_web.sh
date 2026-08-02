#!/usr/bin/env bash
# Admin panelin web build'ini alır ve admin panelde hiç kullanılmayan ama
# Flutter'ın pubspec bağımlılığı olduğu için otomatik kopyaladığı asset'leri
# (mobil-only icon fontları, görseller) build çıktısından temizler.
#
# Neden gerekli: Flutter web build'i, --tree-shake-icons ile yalnızca kendi
# yerleşik MaterialIcons/CupertinoIcons fontlarını kullanım analizine göre
# küçültür. Üçüncü parti paket fontları (hugeicons, iconly, feather_icons)
# pubspec.yaml'da bağımlılık olarak durduğu sürece -- admin kodu onları hiç
# import etmese bile -- tam boyutlarıyla build/web'e kopyalanır. Bu paketler
# admin panelde hiç kullanılmadığı için (yalnızca mobil ekranlarda kullanılır)
# build sonrası güvenle silinebilir.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter build web --release -t lib/main_admin.dart --tree-shake-icons --no-source-maps

echo "== Admin panelde kullanılmayan paket fontları temizleniyor (hugeicons, iconly, feather_icons) =="
rm -rf build/web/assets/packages/hugeicons build/web/assets/packages/iconly build/web/assets/packages/feather_icons

python3 - <<'PY'
import json

path = "build/web/assets/FontManifest.json"
with open(path) as f:
    manifest = json.load(f)

unused_prefixes = ("packages/hugeicons/", "packages/iconly/", "packages/feather_icons/")
filtered = [entry for entry in manifest if not entry["family"].startswith(unused_prefixes)]

with open(path, "w") as f:
    json.dump(filtered, f)

print(f"FontManifest.json: {len(manifest)} -> {len(filtered)} font ailesi")
PY

echo "== Admin panelde kullanılmayan mobil asset'ler temizleniyor (images, lottie) =="
rm -rf build/web/assets/assets/images build/web/assets/assets/lottie
find build/web -name ".DS_Store" -delete

echo "== Build tamamlandı =="
du -sh build/web
ls -la build/web/main.dart.js
