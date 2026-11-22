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

if (require.main === module) {
  const port = Number(process.env.APP_PORT || 3000);
  app.listen(port, "0.0.0.0", () => {
    console.log(`Health application listening on port ${port}`);
  });
}

module.exports = app;
