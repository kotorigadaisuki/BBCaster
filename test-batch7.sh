#!/bin/bash
# test-batch7.sh — BOM, combinación de line endings, hex binario, strings con backslash en medio

BASE_URL="http://localhost:3000"

send_msg() {
  local data="$1"
  local json="{\"data\":$(printf '%s' "$data" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')}"
  curl -s -X POST "$BASE_URL/post" -H "Content-Type: application/json" -d "$json" 2>&1
}

echo "--- BATCH 7 ---"

# BOM al inicio + RTL text
printf '\xEF\xBB\xBFمرحبا بالعالم' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# BOM al final
printf 'Hello World\xEF\xBB\xBF' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# Mix de \n, \r\n, \r
printf 'a\r\nb\rc\nd' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# Hex binario con espacios
send_msg 'DE AD BE EF 00 11 22 33 44 55 66 77 88 99 AA BB CC DD EE FF'
sleep 0.2

# String con backslash al inicio, medio y fin
send_msg '\\start\\middle\\end'
sleep 0.2

# JSON-like inválido (comillas mal cerradas)
send_msg '{"key": "value", "another": "missing closing quote'
sleep 0.2

# String con solo espacios (no tabs, no newlines)
send_msg '   '
sleep 0.2

# String con solo newlines
printf '\n\n\n\n' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# Emoji con skin tone + modifier
send_msg '👋🏻👋🏽👋🏿🤝🏻🤝🏽🤝🏿'
sleep 0.2

# String con comillas escapadas en múltiples niveles
send_msg "He said \"It's a \"test\"\" and she replied 'ok'"
sleep 0.2

echo "--- FIN BATCH 7 ---"
