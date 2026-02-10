Testing notes

- The test suite spawns a local mock server used by integration tests. The mock server listens on port `3001` by default.
- Tests expect the app to route absolute API calls to the mock server. You can set the runtime API base in tests via `window.__API_BASE__`, or set the environment variable `API_BASE` / Vite env `VITE_API_BASE` for other environments.
- CI: `.github/workflows/react-ci.yml` installs dependencies and runs `npm test` in `react/`.
- If you run tests and see failures related to server startup, ensure port `3001` is free and that `node server.js` can start in `react/`.
