# ===============  1. 基础 CUDA 12.1 运行环境  ===============
FROM nvidia/cuda:12.1.0-runtime-ubuntu20.04

# ---------------  2. 统一环境变量（与日志完全一致） ---------------
ENV NVARCH=x86_64
ENV NVIDIA_REQUIRE_CUDA="cuda>=12.1 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471 brand=tesla,driver>=525,driver<526 brand=unknown,driver>=525,driver<526 brand=nvidia,driver>=525,driver<526 brand=nvidiartx,driver>=525,driver<526 brand=geforce,driver>=525,driver<526 brand=geforcertx,driver>=525,driver<526 brand=quadro,driver>=525,driver<526 brand=quadrortx,driver>=525,driver<526 brand=titan,driver>=525,driver<526 brand=titanrtx,driver>=525,driver<526"
ENV NV_CUDA_CUDART_VERSION=12.1.55-1
ENV NV_CUDA_COMPAT_PACKAGE=cuda-compat-12-1
ENV CUDA_VERSION=12.1.0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

# ---------------  3. 系统基础 + 编译工具 + CUDA 12.1 依赖（一次搞定） ---------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        ca-certificates \
        gnupg2 \
        curl \
        git \
        vim \
        procps \
        libgl1 \
        ffmpeg \
        libibverbs-dev \
        ccache \
        software-properties-common && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/${NVARCH}/3bf863cc.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/${NVARCH} /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        cuda-cudart-12-1=${NV_CUDA_CUDART_VERSION} \
        ${NV_CUDA_COMPAT_PACKAGE} && \
    echo "/usr/local/nvidia/lib"     >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf && \
    ldconfig && \
    rm -rf /var/lib/apt/lists/*

# ===============  4. Python 3.10  ===============
ARG PYTHON_VERSION=3.10
ENV DEBIAN_FRONTEND=noninteractive
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-venv \
        python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python${PYTHON_VERSION} && \
    python3 -m pip install --upgrade pip

# ---------------  5. 安装 vLLM 相关依赖  ---------------
RUN ldconfig /usr/local/cuda-$(echo $CUDA_VERSION | cut -d. -f1,2)/compat/ && \
    python3 -m pip install \
        https://github.com/flashinfer-ai/flashinfer/releases/download/v0.0.9/flashinfer-0.0.9+cu121torch2.3-cp310-cp310-linux_x86_64.whl && \
    pip install accelerate hf_transfer 'modelscope!=1.15.0'

# ===============  6. 安装 Node 14（前端编译用）  ===============
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=14.21.1
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# ===============  7. 克隆并安装 Xinference v1.5.1  ===============
WORKDIR /opt/inference
RUN git clone https://github.com/xorbitsai/inference.git . && \
    git checkout v1.5.1

ARG PIP_INDEX=https://pypi.org/simple
RUN pip install --upgrade -i $PIP_INDEX pip && \
    pip install -i $PIP_INDEX "diskcache>=5.6.1" "jinja2>=2.11.3" && \
    pip install llama-cpp-python>=0.2.82 \
        -i https://abetlen.github.io/llama-cpp-python/whl/cu124 && \
    pip install -i $PIP_INDEX --upgrade-strategy only-if-needed \
        -r /opt/inference/xinference/deploy/docker/requirements.txt && \
    pip install -i $PIP_INDEX --no-deps sglang && \
    cd /opt/inference && \
    python3 setup.py build_web && \
    git restore . && \
    pip install -i $PIP_INDEX --no-deps . && \
    pip cache purge

# ---------------  8. 最终环境变量 & 入口  ---------------
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/lib/python3.10/dist-packages/nvidia/cublas/lib
ENV VLLM_USAGE_SOURCE=production-docker-image
EXPOSE 9997
ENTRYPOINT ["xinference"]
CMD ["-H", "0.0.0.0", "--port", "9997"]
