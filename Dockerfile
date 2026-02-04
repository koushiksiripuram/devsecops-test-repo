FROM python:3.12-slim-bookworm

WORKDIR /app

# Intentionally oversized and unsafe runtime dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ⚠️ Old-but-compatible pip (works with Python 3.12)
# Security scanners will still flag this
RUN python -m pip install --no-cache-dir pip==23.2.1

# Install dependencies WITHOUT hashes (intentional supply-chain risk)
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY . /app/

EXPOSE 8000

# ❌ Running as root (intentional)
WORKDIR /app/pygoat/

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
