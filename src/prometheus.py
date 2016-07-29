from werkzeug.wrappers import Response
from functools import wraps
from prometheus_client import Counter, Histogram, REGISTRY, generate_latest
from time import time

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

def prometheus_metrics(metrics_port, metrics_path, monitor_endpoints):
    monitor_endpoints = set([metrics_path] + list(monitor_endpoints))
    def prometheus_metrics_decorator(f):
        @wraps(f)
        def f_wrapper(request):
            # Create metrics only for specific endpoints to not flood
            # prometheus with dynamically created labels.
            if request.path not in monitor_endpoints:
                return f(request)

            start_time = time()
            # Only respond to /metrics requests via dedicated metrics port
            request_port = int(request.environ.get('SERVER_PORT', '-1'))
            if request_port == metrics_port and \
                    request.path == metrics_path and \
                    request.method == 'GET':
                response = Response(generate_latest(REGISTRY), status=200)
            else:
                with REQUEST_COUNT.labels(request.method, request.path, 500).count_exceptions():
                    response = f(request)

            REQUEST_COUNT.labels(
                request.method,
                request.path,
                response.status_code
            ).inc()
            REQUEST_LATENCIES.labels(
                request.method,
                request.path,
                response.status_code
            ).observe(time() - start_time)

            return response
        return f_wrapper
    return prometheus_metrics_decorator

