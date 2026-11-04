#!/bin/bash
# test-batch8.sh — SQL injection-like, CSS, JS snippets, CDATA, emoji puro, combining chars

BASE_URL="http://localhost:3000"

send_msg() {
  local data="$1"
  local json="{\"data\":$(printf '%s' "$data" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')}"
  curl -s -X POST "$BASE_URL/post" -H "Content-Type: application/json" -d "$json" 2>&1
}

echo "--- BATCH 8 ---"

# SQL injection-like
send_msg "DROP TABLE users; --"
sleep 0.2

# CSS con properties
send_msg 'body { color: #ff0000; font-size: 16px; background: url("bg.png"); }'
sleep 0.2

# JS snippet con comillas y backticks
printf 'const msg = `Hello ${name}`;\nconsole.log(msg);' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# XML CDATA section
send_msg '<![CDATA[<script>alert("xss")</script>]]>'
sleep 0.2

# Emoji puro (solo emojis)
send_msg '😀😃😄😁😆😅🤣😂🙂🙃'
sleep 0.2

# Combining diacritics (e + combining acute accent = é compuesto)
printf 'e\xCC\x81' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# String con solo emoji de bandera (regional indicators)
send_msg '🇦🇷🇧🇷🇨🇦🇩🇪'
sleep 0.2

# String muy larga con mixed content (10000 chars)
python3 -c "print('a'*5000 + ' ' + 'b'*5000)" | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# String con solo control chars (no newlines, no tabs)
printf '\x01\x02\x03\x04\x05\x06\x07\x08' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# String con escape sequences literales (\n, \t, \r)
send_msg 'literal \n \t \r \0'
sleep 0.2

echo "--- FIN BATCH 8 ---"
