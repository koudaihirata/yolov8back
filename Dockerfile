FROM python:3.9-slim-buster AS builder

ENV PYTHONUSERBASE=/app/__pypackages__

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential=12.6 \
        libgl1-mesa-glx=18.3.6-2+deb10u1 \
        libglib2.0-0=2.58.3-2+deb10u6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --target=__pypackages__ -r requirements.txt

COPY . .

FROM gcr.io/distroless/python3-debian12:debug

ENV PYTHONUSERBASE=/app/__pypackages__

WORKDIR /app

COPY --from=builder /app/__pypackages__ /app/__pypackages__
COPY --from=builder /app /app

USER nonroot

EXPOSE 5001

ENTRYPOINT ["sh", "-c", "python -uB -m gunicorn app:app -b :${PORT:-5001}"]
