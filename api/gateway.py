import os
import time

from flask import Flask, jsonify, request

app = Flask(__name__)

# Injected from the Kubernetes Secret by the Deployment YAML
MODEL_API_KEY = os.environ["MODEL_API_KEY"]


@app.get("/health")
def health():
    return "ok"


@app.post("/generate")
def generate():
    task = request.get_json(force=True).get("task", "")

    # Stand-in for the real model call: this is where the key will be
    # sent as a header to the provider's HTTPS API.
    time.sleep(2)
    reply = f"(fake model reply) I received: {task}"

    return jsonify({"reply": reply})