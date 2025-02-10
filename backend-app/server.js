const express = require('express');
const prometheus = require('prom-client');


const app = express();
const port = 3003;
const cors = require('cors');
app.use(cors());

// Create a Registry to register metrics
const register = new prometheus.Registry();

// Enable default metrics (e.g., CPU, memory usage)
prometheus.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDurationMicroseconds = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10], // Buckets for response time ranges
});

const httpRequestCount = new prometheus.Counter({
  name: 'http_request_count',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
});

const httpErrorCount = new prometheus.Counter({
  name: 'http_error_count',
  help: 'Total number of HTTP errors',
  labelNames: ['method', 'route', 'status_code'],
});

// Register custom metrics
register.registerMetric(httpRequestDurationMicroseconds);
register.registerMetric(httpRequestCount);
register.registerMetric(httpErrorCount);

// Middleware to track request duration, count, and errors
app.use((req, res, next) => {
  const start = Date.now();
  const end = httpRequestDurationMicroseconds.startTimer();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000; // Convert to seconds
    const labels = {
      method: req.method,
      route: req.route ? req.route.path : req.path,
      status_code: res.statusCode,
    };

    httpRequestDurationMicroseconds.observe(labels, duration);
    httpRequestCount.inc(labels);

    if (res.statusCode >= 400) {
      httpErrorCount.inc(labels);
    }
  });

  next();
});

// Endpoint to expose metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Json endpoint
app.get('/api/hello', (req, res) => {
    res.json({ message: 'Hello World from Backend!' });
});

// Start the server
app.listen(port, () => {
    console.log(`Backend server is running on http://localhost:${port}`);
});