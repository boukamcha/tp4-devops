from flask import Flask, jsonify
from prometheus_flask_exporter import PrometheusMetrics
import os

app = Flask(__name__)
metrics = PrometheusMetrics(app)

@app.route('/')
def home():
    return jsonify({"message": "Hello from Flask DevOps App!", "status": "ok"})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    debug_mode = os.environ.get('FLASK_DEBUG', 'false').lower() == 'true'
    # Bind to localhost only, let Kubernetes handle external exposure
    host = os.environ.get('FLASK_HOST', '127.0.0.1')
    app.run(host=host, port=5000, debug=debug_mode)