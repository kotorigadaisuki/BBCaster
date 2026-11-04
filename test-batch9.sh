#!/bin/bash
# test-batch9.sh — Mensajes combinados (JSON + emoji + BOM + long string en uno solo)

BASE_URL="http://localhost:3000"

send_msg() {
  local data="$1"
  local json="{\"data\":$(printf '%s' "$data" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')}"
  curl -s -X POST "$BASE_URL/post" -H "Content-Type: application/json" -d "$json" 2>&1
}

echo "--- BATCH 9: CONSOLIDACIÓN FINAL ---"

# JSON con emoji + BOM + string larga en un solo mensaje
python3 -c "
import json, sys
msg = '\xEF\xBB\xBF{\"emoji\": \"👨‍👩‍👧‍👦\", \"long\": \"a\" * 10000, \"nested\": {\"deep\": [1,2,3]}}'
print(msg)
" | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# XML con CDATA + emoji + multilinea
printf '<root>\n<item>🎉🎊</item>\n<![CDATA[<script>xss</script>]]>\n</root>' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# SQL con emoji + comillas escapadas + long string
send_msg "SELECT '🔥' AS emoji, 'O'\''Brien' AS name, 'x' * 5000 AS long_text FROM users WHERE id = 1"
sleep 0.2

# CSS con emoji + unicode + BOM al inicio
printf '\xEF\xBB\xBFbody { color: #ff0000; content: "🎨"; }' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# JS snippet con backticks + emoji + long string
printf 'const msg = `🚀 ${name} - ${"x".repeat(5000)}`;\nconsole.log(msg);' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# CSV con comillas, emojis, multilinea y BOM
printf '\xEF\xBB\xBF"name","emoji","notes"\n"John","🎉","line1\nline2"' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# Regex con emoji + unicode + long pattern
send_msg '^(?P<emoji>🔥|💧|⭐)(?P<text>[a-z]{1000})@(?P<domain>[a-z]+\.[a-z]{2,})$'
sleep 0.2

# String vacía con BOM (solo BOM, sin contenido)
printf '\xEF\xBB\xBF' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

echo "--- FIN BATCH 9 ---"
