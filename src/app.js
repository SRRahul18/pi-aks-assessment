const express = require('express');
const client = require('prom-client');

const app = express();

const register = new client.Registry();

client.collectDefaultMetrics({ register });

const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
});

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request latency in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 1, 2, 5],
});

// Register custom metrics
register.registerMetric(httpRequestCounter);
register.registerMetric(httpRequestDuration);

// Middleware to record metrics
app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000; // seconds
    httpRequestCounter.inc({ method: req.method, route: req.path, status_code: res.statusCode });
    httpRequestDuration.observe({ method: req.method, route: req.path, status_code: res.statusCode }, duration);
  });

  next();
});

// ---------------------
// Your existing routes
// ---------------------
app.get('/', (req, res) => {
  let obj = {
    endpoints: [
      "/ping",
      "/current-date",
      "/fibo/:n",
      "/metrics",
    ]
  };
  res.send(obj);
});

app.get('/ping', (req, res) => {
  res.send("pong");
});

app.get('/current-date', (req, res) => {
  let obj = {
    name: "current",
    value: new Date()
  };
  res.send(obj);
});

app.get('/fibo/:n', (req, res) => {
  let obj = {
    name: "fibo",
    value: fibo(req.params.n)
  };
  res.send(obj);
});

// ---------------------
// Prometheus endpoint
// ---------------------
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(3000, () => {
  console.log('Example app listening on port 3000!');
});

// ---------------------
// Helper Function
// ---------------------
function fibo(n) {
  n = parseInt(n);
  if (n < 2) return 1;
  return fibo(n - 3) + fibo(n - 1);
}