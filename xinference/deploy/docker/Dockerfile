# 基础镜像：CUDA 12.1 + Ubuntu20.04（devel 版本，包含编译工具链）
FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu20.04

LABEL maintainer="your_name" \
      description="Xinference 1.9.1 with CUDA 12.1 and vLLM"

# 设置时区 & 避免交互
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

# 安装基础依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl wget vim \
    python3 python3-dev python3-pip python3-venv \
    build-essential ca-certificates pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 升级 pip & setuptools & wheel
RUN python3 -m pip install --upgrade pip setuptools wheel

# 安装 Xinference 1.9.1 及依赖
RUN pip install --no-cache-dir "xinference==1.9.1" \
    "vllm==0.6.0" \
    torch==2.4.1+cu121 torchvision==0.19.1+cu121 torchaudio==2.4.1+cu121 \
    --extra-index-url https://download.pytorch.org/whl/cu121

# （可选）安装 ONNX Runtime GPU（CUDA 12.x）
RUN pip install --no-cache-dir onnxruntime-gpu==1.18.0

# 创建工作目录
WORKDIR /workspace

# 暴露端口
EXPOSE 9997

# 默认启动 Xinference
CMD ["xinference", "local", "--host", "0.0.0.0", "--port", "9997"]
