import json
import os
import signal
import time
import urllib.request

from azure.core.exceptions import ResourceExistsError
from azure.storage.queue import QueueClient

# Set in the Deployment YAML; the Service name resolves inside the cluster
GATEWAY_URL = os.environ.get("GATEWAY_URL", "http://gateway")

running = True


def stop(signum, frame):
    global running
    print("stop signal received, finishing the current job", flush=True)
    running = False


signal.signal(signal.SIGTERM, stop)
signal.signal(signal.SIGINT, stop)


def call_gateway(task):
    body = json.dumps({"task": task}).encode()
    req = urllib.request.Request(
        f"{GATEWAY_URL}/generate",
        data=body,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read())["reply"]


client = QueueClient.from_connection_string(
    os.environ["QUEUE_CONNECTION_STRING"], "jobs"
)
try:
    client.create_queue()
except ResourceExistsError:
    pass

print("worker started", flush=True)

while running:
    got_message = False
    for msg in client.receive_messages(max_messages=1, visibility_timeout=30):
        got_message = True
        job = json.loads(msg.content)
        print("processing", job, flush=True)
        try:
            reply = call_gateway(job["task"])
        except Exception as err:
            print("gateway error, job will retry:", err, flush=True)
            continue
        print("done:", reply, flush=True)
        client.delete_message(msg)
    if not got_message:
        time.sleep(1)