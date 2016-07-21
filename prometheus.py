from werkzeug.wrappers import Response
from functools import wraps
from prometheus_client import Counter, Histogram, REGISTRY, generate_latest
from time import time

REQUEST_COUNT = Counter(
    'pdfservice_request_total',
    'desciption',
    ['method', 'endpoint', 'code']
)
REQUEST_LATENCIES = Histogram(
    'pdfservice_request_latency_seconds',
    'desciption',
    ['method', 'endpoint', 'code']
)

def prometheus_metrics(metrics_path):
    def prometheus_metrics_decorator(f):
        @wraps(f)
        def f_wrapper(request):
            start_time = time()

            if request.method == 'GET' and request.path == metrics_path:
                status = 200
                REQUEST_LATENCIES.labels(
                    request.method, request.path, status
                ).observe(time() - start_time)

                REQUEST_COUNT.labels(request.method, request.path, status).inc()
                return Response(generate_latest(REGISTRY), status=status)

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

