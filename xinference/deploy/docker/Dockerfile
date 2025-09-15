# 基础镜像：CUDA 12.1 + Ubuntu20.04
FROM nvidia/cuda:12.1.105-base-ubuntu20.04

# 设置时区 & 避免交互
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 基础依赖
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 3.10（不安装系统 pip，避免冲突）
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-dev python3.10-venv && \
    rm -rf /var/lib/apt/lists/*

# 安装最新 pip / setuptools / wheel
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    python3.10 -m pip install --upgrade pip setuptools wheel

# 设置默认 python 和 pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.10 1

# 安装 xinference==1.9.1
RUN pip install --no-cache-dir "xinference==1.9.1"

# 默认启动命令
CMD ["xinference", "launch", "--host", "0.0.0.0", "--port", "9997"]
