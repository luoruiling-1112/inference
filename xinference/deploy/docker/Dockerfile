FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu20.04

# 安装基础依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl wget vim \
    python3 python3-dev python3-pip python3-venv \
    build-essential ca-certificates pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 升级 pip ≥23，确保优先使用 wheel
RUN python3 -m pip install --upgrade "pip>=23" setuptools wheel

# 先装 xoscar wheel，再装 xinference/vLLM/PyTorch，避开源码构建
RUN pip install --no-cache-dir \
        xoscar==0.3.2 \
        "xinference==1.9.1" \
        "vllm==0.6.0" \
        torch==2.4.1+cu121 torchvision==0.19.1+cu121 torchaudio==2.4.1+cu121 \
        --extra-index-url https://download.pytorch.org/whl/cu121

# （可选）ONNX Runtime GPU for CUDA 12.x
RUN pip install --no-cache-dir onnxruntime-gpu==1.18.0

# 工作目录
WORKDIR /workspace

# 暴露 Xinference 默认端口
EXPOSE 9997

# 默认启动命令
CMD ["xinference", "local", "--host", "0.0.0.0", "--port", "9997"]
