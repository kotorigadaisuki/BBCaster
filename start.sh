#!/usr/bin/env bash
#
# BBCaster — arranque automático
#
# 1. Instala nvm si no existe
# 2. Instala Node.js en la versión de .nvmrc si no existe
# 3. Corre el servidor con npm start

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NVM_DIR="$HOME/.nvm"

# --- 1. Instalar nvm si no existe ---
if ! command -v nvm &>/dev/null; then
  if [ ! -d "$NVM_DIR" ]; then
    echo "→ Instalando nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi
fi

# Source nvm
export NVM_DIR="$NVM_DIR"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# --- 2. Instalar Node.js si no existe ---
REQUIRED_NODE=$(cat "$SCRIPT_DIR/.nvmrc")
echo "→ Node requerido: v$REQUIRED_NODE"

if ! nvm ls | grep -q "v$REQUIRED_NODE"; then
  echo "→ Instalando Node.js v$REQUIRED_NODE..."
  nvm install "$REQUIRED_NODE"
fi

nvm use "$REQUIRED_NODE"
nvm alias default "$REQUIRED_NODE"

# --- 3. Instalar dependencias y correr el servidor ---
cd "$SCRIPT_DIR"
npm install
npm start
