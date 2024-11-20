from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)


@app.route("/")
def hello():
    return "Привет, это тест!"


if __name__ == '__main__':
    app.run(host="0.0.0.0", debug=False)
