FROM python:3.12-slim-bookworm

# set work directory
WORKDIR /app

# dependencies for psycopg2 (intentionally leaving extra tools installed)
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    build-essential \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Intentionally using old pip version (security scanners will flag this)
RUN python -m pip install --no-cache-dir pip==22.0.4

# Install dependencies without hash checking
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# copy project
COPY . /app/

EXPOSE 8000

# ❌ Still bad practice — DB migrations during image build removed so build succeeds
# but will still be risky if done at container start instead

WORKDIR /app/pygoat/

# ❌ Running as root (left intentionally for security testing)
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
