const express = require("express");
const { EventEmitter } = require("events");

const app = express();
const emitter = new EventEmitter();

// Middleware to parse JSON bodies
app.use(express.json());

// SSE endpoint - clients connect here to receive events
app.get("/events", (req, res) => {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });

  // Send initial connection message
  res.write("event: connected\n");
  res.write(`data: ${JSON.stringify({ ts: new Date().toISOString(), txt: "Connected to SSE", show: true })}\n\n`);

  // Handle client disconnect
  req.on("close", () => {
    emitter.removeListener("broadcast", onBroadcast);
    res.end();
  });

  const onBroadcast = (msg) => {
    res.write(`event: message\n`);
    res.write(`data: ${JSON.stringify({ ts: msg.ts, txt: msg.txt, show: msg.show })}\n\n`);
  };

  emitter.on("broadcast", onBroadcast);
});

// POST endpoint - receive a message and broadcast to all SSE clients
app.post("/post", (req, res) => {
  const { txt, show } = req.body;

  if (!txt) {
    return res.status(400).json({ error: "Field 'txt' is required" });
  }

  // Broadcast the message to all connected SSE clients
  emitter.emit("broadcast", {
    ts: new Date().toISOString(),
    txt,
    show: show !== undefined ? !!show : true,
  });

  res.json({ status: "ok", message: "Event broadcasted" });
});

const os = require("os");
const path = require("path");

// Serve static files from public/
app.use("/public", express.static(path.join(__dirname, "public")));

// Serve the index.html at the root path (no cache) with embedded interfaces
app.get("/", (req, res) => {
  let html = fs.readFileSync(path.join(__dirname, "index.html"), "utf8");

  // Build interfaces HTML - filter by host coverage + always include localhost
  const interfaces = os.networkInterfaces();
  let ifaceHtml = "";

  function coversHost(host, ip) {
    if (host === "0.0.0.0") return true;
    // Check if IP is in the same subnet as host
    const hostParts = host.split(".");
    const ipParts = ip.split(".");
    for (let i = 0; i < hostParts.length; i++) {
      if (hostParts[i] !== ipParts[i]) return false;
    }
    return true;
  }

  for (const [name, addresses] of Object.entries(interfaces)) {
    for (const addr of addresses) {
      if (addr.family === "IPv4") {
        const url = `http://${addr.address}:${PORT}`;
        // Always include localhost
        if (addr.address === "127.0.0.1") {
          ifaceHtml += `<div class="iface-row"><span class="iface-name">${name}</span><a href="${url}" target="_blank" class="iface-link">${url}</a><button class="iface-qr-btn" data-url="${url}">📷</button></div>\n`;
        } else if (!addr.internal && coversHost(HOST, addr.address)) {
          ifaceHtml += `<div class="iface-row"><span class="iface-name">${name}</span><a href="${url}" target="_blank" class="iface-link">${url}</a><button class="iface-qr-btn" data-url="${url}">📷</button></div>\n`;
        }
      }
    }
  }

  // Replace placeholder with actual interfaces
  html = html.replace(
    '<!-- INTERFACES_PLACEHOLDER -->',
    ifaceHtml || '<p class="empty">No se encontraron interfaces</p>'
  );

  res.send(html);
});

const fs = require("fs");
const configPath = path.join(__dirname, "config.json");
let config;
try {
  config = JSON.parse(fs.readFileSync(configPath, "utf8"));
} catch (e) {
  console.error("⚠️ No se pudo leer config.json, usando valores por defecto.");
  config = { host: "0.0.0.0", port: 3000 };
}
const HOST = process.env.HOST || (config.host || "0.0.0.0");
const PORT = process.env.PORT || (config.port || 3000);
app.listen(PORT, HOST, () => {
  console.log(`BBCaster server running on http://localhost:${PORT}`);
});
