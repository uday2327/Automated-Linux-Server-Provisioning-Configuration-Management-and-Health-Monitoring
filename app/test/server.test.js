const test = require("node:test");
const assert = require("node:assert/strict");

const app = require("../server");
const http = require("node:http");

function listen() {
  return new Promise((resolve) => {
    const server = http.createServer(app).listen(0, "127.0.0.1", () => resolve(server));
  });
}

test("root endpoint returns service status", async () => {
  const server = await listen();
  try {
    const address = server.address();
    const response = await fetch(`http://127.0.0.1:${address.port}/`);
    assert.equal(response.status, 200);
    assert.equal((await response.json()).status, "ok");
  } finally {
    server.close();
  }
});

test("health endpoint returns JSON status", async () => {
  const server = await listen();
  try {
    const address = server.address();
    const response = await fetch(`http://127.0.0.1:${address.port}/health`);
    assert.equal(response.status, 200);
    assert.equal((await response.json()).status, "ok");
  } finally {
    server.close();
  }
});

test("status endpoint returns healthy status", async () => {
  const server = await listen();
  try {
    const address = server.address();
    const response = await fetch(`http://127.0.0.1:${address.port}/api/status`);
    assert.equal(response.status, 200);
    assert.equal((await response.json()).status, "healthy");
  } finally {
    server.close();
  }
});

test("metrics endpoint returns Prometheus text", async () => {
  const server = await listen();
  try {
    const address = server.address();
    const response = await fetch(`http://127.0.0.1:${address.port}/metrics`);
    assert.equal(response.status, 200);
    assert.match(response.headers.get("content-type") || "", /^text\/plain/);
    assert.match(await response.text(), /app_uptime_seconds \d+/);
  } finally {
    server.close();
  }
});

