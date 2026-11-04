#!/bin/bash
# test-sse.sh — Hard testing of SSEEvents messages

BASE_URL="http://localhost:3000"
LOG_FILE="/tmp/sse-test-output.log"
ERRORS=0

echo "=== SSEvents Hard Test ===" > "$LOG_FILE"
echo "Fecha: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

send_msg() {
  local data="$1"
  local result
  # Use printf to build valid JSON, avoiding quoting issues
  local json="{\"data\":$(printf '%s' "$data" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')}"
  result=$(curl -s -X POST "$BASE_URL/post" -H "Content-Type: application/json" -d "$json" 2>&1)
  echo "[$(date '+%H:%M:%S')] envía: $data" >> "$LOG_FILE"
  echo "    → $result" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"
}

# --- Batch 1: Caracteres especiales y HTML ---
echo "📋 BATCH 1: Caracteres especiales y HTML" >> "$LOG_FILE"

send_msg '<script>alert("XSS")</script>'
send_msg '<div class="test">tag anidado con comillas simples y dobles</div>'
send_msg $'Línea 1\nLínea 2 con\ttabulador\nLínea 3'
send_msg '`código inline` y ```bloque```'
send_msg '🔤🔢🔣🎨🏁🇺🇸🇯🇸🇦🇷🇬🇧🇪🇳🇸🇪🇹🇰'
send_msg '<b>negrita</b> <i>cursiva</i> <u>subrayado</u> <s>tachado</s>'
send_msg 'Cadena muy larga: '
send_msg '   '
send_msg 'null byte \x00 test'
send_msg 'backslash\\end'
send_msg 'quote"and"more"quotes'
send_msg 'emoji 🎉🎊🎈🎁🎀🎗🎞🎟'
send_msg '<img src=x onerror=alert(1)>'
send_msg '<style>body{color:red}</style>'
send_msg 'áéíóúüñçÀÉÍÓÚÜÑÇ'

echo "" >> "$LOG_FILE"
echo "=== Búsqueda de errores ===" >> "$LOG_FILE"
grep -i "error" "$LOG_FILE" >> /dev/null 2>&1 && ERRORS=$((ERRORS+1))

if [ $ERRORS -eq 0 ]; then
  echo "✅ PASSED — No se encontraron errores en el batch 1"
else
  echo "❌ FAILED — Se encontraron errores:"
  grep -i "error" "$LOG_FILE"
fi

# --- Batch 2: Strings vacías, nulas, muy largas y caracteres de control ---
echo "" >> "$LOG_FILE"
echo "📋 BATCH 2: Strings vacías, nulas, muy largas y caracteres de control" >> "$LOG_FILE"

send_msg ''
send_msg $'\x00\x01\x02\x03'
send_msg $'\x1f\x20\x7f'
send_msg $'\u{0000}\u{00FF}'
send_msg 'A'$(python3 -c "print('X'*9999)")''
send_msg $'\n\n\n\n\n'
send_msg $'\t\t\t\t\t'
send_msg $'\r\r\r\r\r'
send_msg 'normal'
send_msg '  espacios  '

echo "" >> "$LOG_FILE"
echo "=== Búsqueda de errores ===" >> "$LOG_FILE"
grep -i "error" "$LOG_FILE" >> /dev/null 2>&1 && ERRORS=$((ERRORS+1))

if [ $ERRORS -eq 0 ]; then
  echo "✅ PASSED — No se encontraron errores en el batch 2"
else
  echo "❌ FAILED — Se encontraron errores:"
  grep -i "error" "$LOG_FILE"
fi

# --- Batch 3: SQL-like, Markdown, JSON anidado y strings con comillas escapadas ---
echo "" >> "$LOG_FILE"
echo "📋 BATCH 3: SQL-like, Markdown, JSON anidado y strings con comillas escapadas" >> "$LOG_FILE"

send_msg "SELECT * FROM users WHERE name='O''Brien'"
send_msg "# Heading\n**bold**\n- list item\n```code block```"
send_msg '{"key": "value", "nested": {"a": 1, "b": [1,2,3]}}'
send_msg 'Cadena con \"comillas\" escapadas y \'comillas simples\''
send_msg 'Path: C:\Users\Admin\Documents\file.txt'
send_msg 'URL: https://example.com/path?query=value&lang=es#anchor'
send_msg 'Regex: ^[a-z]{3}\d{2}@[a-z]+\.com$'
send_msg 'Base64: SGVsbG8gV29ybGQ='
send_msg '<a href="http://example.com">link</a>'
send_msg 'Math: E = mc², α + β = γ, ∑(i=1→n)'

echo "" >> "$LOG_FILE"
echo "=== Búsqueda de errores ===" >> "$LOG_FILE"
grep -i "error" "$LOG_FILE" >> /dev/null 2>&1 && ERRORS=$((ERRORS+1))

if [ $ERRORS -eq 0 ]; then
  echo "✅ PASSED — No se encontraron errores en el batch 3"
else
  echo "❌ FAILED — Se encontraron errores:"
  grep -i "error" "$LOG_FILE"
fi

echo "" >> "$LOG_FILE"
echo "=== Fin del test ===" >> "$LOG_FILE"
cat "$LOG_FILE"
