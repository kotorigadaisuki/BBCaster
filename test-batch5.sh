#!/bin/bash
# test-batch5.sh — Shell specials, BOM, LTR/RTL marks, URLs con chars raros

BASE_URL="http://localhost:3000"

send_msg() {
  local data="$1"
  local json="{\"data\":$(printf '%s' "$data" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')}"
  curl -s -X POST "$BASE_URL/post" -H "Content-Type: application/json" -d "$json" 2>&1
}

echo "--- BATCH 5 ---"

# Shell specials: $, !, `, \
send_msg 'Precio: $100.00! (descuento 20%)'
sleep 0.2

# BOM + LTR/RTL marks
printf 'Hello\xEF\xBB\xBFWorld' | while IFS= read -r -d '' line; do send_msg "$line"; done
sleep 0.2

# URL con chars raros
send_msg 'https://example.com/path?q=αβγ&lang=en#section-1'
sleep 0.2

# String con solo chars especiales
send_msg '!@#$%^&*()_+-=[]{}|;:<>?/'
sleep 0.2

# Multiline con \r\n mixed
printf 'line1\r\nline2\rline3\nline4' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# JSON inválido (parece JSON pero no lo es)
send_msg '{"key": "value", unquoted: true}'
sleep 0.2

# String con tabuladores y newlines mezclados
printf 'a\tb\nc\td\te\nf' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# Unicode: combining diacritics (e + ́ = é compuesto)
send_msg 'café\nnaïve\nrésumé\nÅngström'
sleep 0.2

# String con solo backslash
send_msg '\\\\\\\\'
sleep 0.2

# String con comillas simples y dobles mezcladas
send_msg "It's a \"test\" with 'quotes' and \"more\""
sleep 0.2

echo "--- FIN BATCH 5 ---"
