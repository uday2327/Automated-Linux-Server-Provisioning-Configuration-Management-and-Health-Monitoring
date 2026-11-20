# Application

A small Express service in `server.js` exposes `/health`, `/api/status`, and Prometheus-format `/metrics`. `npm test` exercises the endpoints. The runtime dependency is declared in `package.json`; a lock file is not yet present. Syntax checks passed, but tests could not run because Express is not installed locally.
