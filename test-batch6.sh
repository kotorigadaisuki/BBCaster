#!/bin/bash
# test-batch6.sh — Boundary lengths, zero-width chars, emoji sequences, escape sequences

BASE_URL="http://localhost:3000"

send_msg() {
  local data="$1"
  local json="{\"data\":$(printf '%s' "$data" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')}"
  curl -s -X POST "$BASE_URL/post" -H "Content-Type: application/json" -d "$json" 2>&1
}

echo "--- BATCH 6 ---"

# Boundary: 1 char
send_msg 'A'
sleep 0.2

# Boundary: 255 chars (just under common buffer)
python3 -c "print('a'*255)" | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# Boundary: 256 chars (just over)
python3 -c "print('a'*256)" | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# Zero-width joiner + non-joiner
send_msg 'café$'\u200C''$'\u200D''fi'
sleep 0.2

# Emoji family (ZWJ sequence)
send_msg '👨‍👩‍👧‍👦'
sleep 0.2

# Flag emoji (regional indicators)
send_msg '🇺🇸🇯🇸🇦🇷🇬🇧'
sleep 0.2

# Skin tone modifier emoji
send_msg '👋🏻👋🏽👋🏿'
sleep 0.2

# Escape sequences literales (\n, \t, \r)
send_msg 'literal: \\n\\t\\r'
sleep 0.2

# String con NUL en medio (no al inicio ni al final)
printf 'before\x00after' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

# String con form feed y vertical tab
printf 'line1\x0cline2\x0bline3' | while IFS= read -r line; do send_msg "$line"; done
sleep 0.2

echo "--- FIN BATCH 6 ---"
