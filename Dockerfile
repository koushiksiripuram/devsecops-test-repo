FROM python:3.12-slim-bookworm

WORKDIR /app

# Intentionally leaving extra tools (security smell)
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    build-essential \
    libjpeg-dev \
    zlib1g-dev \
    libffi-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Old-ish pip (still a finding, but works)
RUN python -m pip install --no-cache-dir pip==23.2.1

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/

EXPOSE 8000

WORKDIR /app/pygoat/

# Still running as root (intentional security issue)
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
