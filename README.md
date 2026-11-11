# BBCaster

Broadcast de mensajes en tiempo real vía **Server-Sent Events (SSE)**.

## ¿Qué hace?

- Recibe mensajes por `POST /post` con `{ "txt": "...", "show": true/false }`
- El servidor agrega automáticamente `ts` (ISO timestamp) al broadcast SSE
- Los retransmite a todos los clientes conectados a `GET /events`
- UI web con input, checkbox "Show" y botón enviar
- El checkbox cambia el tipo del input a `password` (oculta caracteres mientras escribís)
- Mensajes con `show: false` se muestran como asteriscos (`****`)
- Click en un mensaje → copia el texto real al portapapeles + destello rosa

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



