from time import time
from prometheus_client import Counter, Histogram, REGISTRY, generate_latest

REQUEST_COUNT = Counter(
    'pdfservice_request_total',
    'Total number of HTTP requests made.',
    ['method', 'endpoint', 'code']
)
REQUEST_LATENCIES = Histogram(
    'pdfservice_request_latency_seconds',
    'The HTTP request latencies in seconds.',
    ['method', 'endpoint', 'code']
)

def log_response(method, path, status, start_time):
    REQUEST_LATENCIES.labels(
            method,
            path,
            status
    ).observe(time() - start_time)
    REQUEST_COUNT.labels(method, path, status).inc()

