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
  res.write(`data: ${JSON.stringify({ message: "Connected to SSE" })}\n\n`);

  // Handle client disconnect
  req.on("close", () => {
    emitter.removeListener("broadcast", onBroadcast);
    res.end();
  });

  const onBroadcast = (msg) => {
    res.write(`event: message\n`);
    res.write(`data: ${JSON.stringify(msg)}\n\n`);
  };

  emitter.on("broadcast", onBroadcast);
});

// POST endpoint - receive a message and broadcast to all SSE clients
app.post("/post", (req, res) => {
  const { data } = req.body;

  if (!data) {
    return res.status(400).json({ error: "Field 'data' is required" });
  }

  // Broadcast the message to all connected SSE clients
  emitter.emit("broadcast", {
    timestamp: new Date().toISOString(),
    data: data,
  });

  res.json({ status: "ok", message: "Event broadcasted" });
});

const path = require("path");

// Serve the index.html at the root path (no cache)
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"), { cache: false });
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
