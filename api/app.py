# Minimal web API. The point of this project is the infrastructure around it,
# so the app stays small on purpose.
import json
import os
import socket

from azure.core.exceptions import ResourceExistsError
from azure.storage.queue import QueueClient
from flask import Flask, jsonify, request

app = Flask(__name__)

# The greeting comes from an environment variable so it can change without
# rebuilding the image. Kubernetes sets it from a ConfigMap. The default is
# used when the variable is not set (for example, plain docker run).
GREETING = os.environ.get("GREETING", "hello from the api")

# The queue client is created on first use, not at startup, so the API still
# starts (and passes its health checks) if the queue is briefly unavailable.
_queue = None


def get_queue():
    global _queue
    if _queue is None:
        # The connection string comes from a Kubernetes Secret as an
        # environment variable. It points at Azurite locally and at a real
        # Azure Storage Queue in the cloud; this code is the same for both.
        client = QueueClient.from_connection_string(
            os.environ["QUEUE_CONNECTION_STRING"], "jobs"
        )
        try:
            client.create_queue()
        except ResourceExistsError:
            pass  # the queue already exists, which is fine
        _queue = client
    return _queue


# Root route. Returns the greeting and the container's hostname, which inside
# Kubernetes is the pod name. Calling the Service repeatedly shows which pod
# answered, which makes load balancing visible.
@app.route("/")
def index():
    return jsonify(message=GREETING, pod=socket.gethostname())


# Health route. Kubernetes probes call this to decide whether the pod is alive
# and ready to receive traffic.
@app.route("/health")
def health():
    return jsonify(status="ok")


# Job route. Puts one message on the queue and returns immediately (202 =
# accepted for later processing). A worker pod picks the message up.
@app.route("/jobs", methods=["POST"])
def create_job():
    body = request.get_json(silent=True) or {}
    message = json.dumps({"task": body.get("task", "demo")})
    get_queue().send_message(message)
    return jsonify(status="queued", task=body.get("task", "demo")), 202


# Runs only when started directly (python app.py), not when imported.
# 0.0.0.0 means "listen on all network interfaces". Inside a container the
# default 127.0.0.1 only accepts connections from the container itself, so
# nothing outside it (including a Kubernetes Service) could reach the app.
# In the container, gunicorn imports the app instead and this block is unused.
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)