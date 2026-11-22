const express = require("express");
const os = require("os");

const app = express();
const startedAt = Date.now();
let healthRequestCount = 0;

app.get("/metrics", (_request, response) => {
  const uptimeSeconds = Math.floor((Date.now() - startedAt) / 1000);
  response
    .type("text/plain")
    .send(
      [
        "# HELP app_health_requests_total Total number of health endpoint requests.",
        "# TYPE app_health_requests_total counter",
        `app_health_requests_total ${healthRequestCount}`,
        "# HELP app_uptime_seconds Application process uptime in seconds.",
        "# TYPE app_uptime_seconds gauge",
        `app_uptime_seconds ${uptimeSeconds}`,
        "# HELP app_info Application build information.",
        "# TYPE app_info gauge",
        'app_info{service="aws-health-app"} 1',
        "",
      ].join("\n"),
    );
});

app.get("/", (_request, response) => {
  response.json({
    service: "aws-health-app",
    status: "ok",
    host: os.hostname(),
  });
});

app.get("/health", (_request, response) => {
  healthRequestCount += 1;
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
