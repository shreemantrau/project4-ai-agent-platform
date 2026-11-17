# Base image: a ready-made Linux image with Python 3.13 already installed.
# "slim" is a smaller variant without extra build tools, so the image is
# smaller and downloads faster. The version is pinned so every build starts
# from the same Python.
FROM python:3.13-slim

# Sets the working directory inside the image. It is created if missing, and
# every later instruction (COPY, RUN, CMD) runs from here, so files land in
# a predictable place instead of the root of the filesystem.
WORKDIR /app

# Copy only the dependency list first, before the app code. Docker caches
# each step as a layer; as long as requirements.txt is unchanged, the
# install step after this is reused from cache and is skipped, so rebuilds
# after a code-only change are fast.
COPY requirements.txt .

# Install the dependencies. --no-cache-dir stops pip from keeping its download
# cache inside the image, which keeps the image smaller.
RUN pip install --no-cache-dir -r requirements.txt

# Now copy the app code. It comes after the install so that code edits do not
# invalidate the cached install layer above.
COPY app.py worker.py gateway.py .

# Documents the port the app listens on. It does not publish the port by
# itself; publishing happens at run time (docker run -p) or through a
# Kubernetes Service.
EXPOSE 5000

# Create an unprivileged user and switch to it so the app does not run as
# root. If the app were ever compromised, the attacker gets a limited user.
RUN useradd --create-home appuser
USER appuser

# The command that starts when a container is created from the image.
# gunicorn is a production web server: it handles the stop signal Kubernetes
# sends, so the container shuts down cleanly instead of being force-killed
# after the grace period. "app:app" means the variable "app" in app.py.
# The list form runs gunicorn directly with no shell in between.
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]