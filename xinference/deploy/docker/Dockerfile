FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu20.04
ENV TZ=Asia/Shanghai DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl wget vim \
    python3 python3-dev python3-pip python3-venv \
    build-essential ca-certificates pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 升级 pip，保证识别新版 wheel
RUN python3 -m pip install --upgrade "pip>=23" setuptools wheel

# ① 强制只装 wheel；② xoscar 用 0.8.2+（已有 whl）
RUN pip install --no-cache-dir --only-binary :all: \
        "xoscar>=0.8.2" \
        "xinference==1.9.1" \
        "vllm==0.6.0" \
        torch==2.4.1+cu121 torchvision==0.19.1+cu121 torchaudio==2.4.1+cu121 \
        --extra-index-url https://download.pytorch.org/whl/cu121

# （可选）ONNX Runtime GPU
RUN pip install --no-cache-dir onnxruntime-gpu==1.18.0

WORKDIR /workspace
EXPOSE 9997
CMD ["xinference", "local", "--host", "0.0.0.0", "--port", "9997"]
