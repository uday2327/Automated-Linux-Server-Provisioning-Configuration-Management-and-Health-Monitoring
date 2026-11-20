const express = require("express");
const os = require("os");

const app = express();
const startedAt = Date.now();

app.get("/", (_request, response) => {
  response.json({
    service: "aws-health-app",
    status: "ok",
    host: os.hostname(),
  });
});

app.get("/health", (_request, response) => {
  response.json({
    status: "ok",
    uptime_seconds: Math.floor((Date.now() - startedAt) / 1000),
  });
});

app.get("/api/status", (_request, response) => {
  response.json({
    status: "healthy",
    uptime_seconds: Math.floor((Date.now() - startedAt) / 1000),
  });
});

app.get("/metrics", (_request, response) => {
  const uptime = process.uptime();
  const memory = process.memoryUsage();
  response.type("text/plain").send([
    "# HELP app_uptime_seconds Application process uptime.",
    "# TYPE app_uptime_seconds gauge",
    `app_uptime_seconds ${uptime.toFixed(3)}`,
    "# HELP app_memory_bytes Resident application memory.",
    "# TYPE app_memory_bytes gauge",
    `app_memory_bytes ${memory.rss}`,
  ].join("\n") + "\n");
});

if (require.main === module) {
  const port = Number(process.env.APP_PORT || 3000);
  app.listen(port, "0.0.0.0", () => {
    console.log(`Health application listening on port ${port}`);
  });
}

module.exports = app;
