#FROM nvidia/cuda:12.1.0-runtime-ubuntu20.04

LABEL maintainer="your_name" \
      description="Xinference 1.9.1 with CUDA 12.1 and vLLM"

# -----------------------
# 1. 基础环境
# -----------------------
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    git \
    curl \
    vim \
    wget \
    libibverbs-dev \
    && rm -rf /var/lib/apt/lists/*

# -----------------------
# 2. Python 3.10
# -----------------------
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y \
    python3.10 python3.10-dev python3.10-venv python3-pip \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && python3 -m pip install --upgrade pip setuptools wheel

# -----------------------
# 3. CUDA 相关依赖
# -----------------------
ENV PATH="/usr/local/cuda/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

# -----------------------
# 4. AI 加速库
# -----------------------
RUN pip install --no-cache-dir \
    accelerate \
    hf_transfer \
    "modelscope!=1.15.0" \
    tabulate tqdm requests

# flashinfer (CUDA 12.1, Torch 2.3, Python 3.10)
RUN pip install --no-cache-dir \
    https://github.com/flashinfer-ai/flashinfer/releases/download/v0.0.9/flashinfer-0.0.9+cu121torch2.3-cp310-cp310-linux_x86_64.whl

# llama-cpp-python (CUDA 12.4 轮子, 兼容 12.1 驱动)
RUN pip install --no-cache-dir "llama-cpp-python>=0.2.82" -i https://abetlen.github.io/llama-cpp-python/whl/cu124

# -----------------------
# 5. Xinference 1.9.1
# -----------------------
WORKDIR /opt/xinference
RUN pip install --no-cache-dir "xinference==1.9.1"

# -----------------------
# 6. 入口
# -----------------------
EXPOSE 9997
ENTRYPOINT ["xinference", "launch", "--host", "0.0.0.0", "--port", "9997"]
