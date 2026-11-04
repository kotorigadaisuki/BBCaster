# BBCaster

Broadcast de mensajes en tiempo real vía **Server-Sent Events (SSE)**.

## ¿Qué hace?

- Recibe mensajes por `POST /post` con `{ "data": "..." }`
- Los retransmite a todos los clientes conectados a `GET /events`
- UI web con input, botón enviar, y mensajes que expiran en 15s
- Click en un mensaje → copia al portapapeles + destello rosa

## Requisitos

- Node.js ≥ 24

## Instalación

```bash
# Clonar el repo
git clone <repo-url>
cd BBCaster

# Opcional: usar el script de arranque automático
./start.sh
```

`start.sh` hace automáticamente:

1. Instala **nvm** si no existe
2. Instala **Node.js v24** (lee `.nvmrc`)
3. Corre `npm install` y `npm start`

## Arranque manual

```bash
# Con nvm instalado
nvm use 24
npm start

# O directamente (si ya tenés Node ≥ 24)
node index.js
```

El servidor escucha en `http://localhost:3000`.

## Configuración

Editá `config.json` para cambiar puerto e IP:

```json
{
  "host": "0.0.0.0",
  "port": 3000
}
```

## Desarrollo

- `index.js` → backend Express + EventEmitter
- `index.html` → UI con CSS + JS vanilla
- `config.json` → puerto e IP de escucha
- `.nvmrc` → versión de Node requerida (v24)
- `start.sh` → script de arranque automático


