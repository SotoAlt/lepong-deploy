# lepong inference server — CPU-only PyTorch + FastAPI WebSocket.
# 13M-param JEPA encoder/predictor + tiny state head. Lightweight.
FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*

# torch CPU wheel (no CUDA, no torchvision) keeps the image small.
RUN pip install --no-cache-dir \
        --index-url https://download.pytorch.org/whl/cpu \
        torch==2.4.1 \
    && pip install --no-cache-dir \
        fastapi==0.115.6 \
        uvicorn[standard]==0.34.0 \
        websockets \
        numpy \
        pillow \
        h5py

COPY server/ server/
COPY model/ model/
COPY client/ client/

EXPOSE 8791

ENV PYTHONUNBUFFERED=1

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS http://localhost:8791/health || exit 1

CMD ["python3", "-m", "server.infer", \
     "--checkpoint", "/app/checkpoints/jepa_pong_statehead_occ_aug.pt", \
     "--port", "8791", \
     "--host", "0.0.0.0"]
