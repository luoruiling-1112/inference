FROM nvidia/cuda:12.1.0-devel-ubuntu20.04

# 基础环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    NVARCH=x86_64 \
    CUDA_VERSION=12.1.0 \
    PYTHON_VERSION=3.10 \
    PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

# ==========================
#  系统依赖
# ==========================
RUN apt-get update -y && apt-get install -y \
    gnupg2 curl ca-certificates software-properties-common ccache git vim \
    libibverbs-dev ffmpeg procps libgl1 \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update -y && apt-get install -y \
    python${PYTHON_VERSION} python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-venv \
    && if [ "${PYTHON_VERSION}" != "3" ]; then \
           update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1; \
       fi \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python${PYTHON_VERSION} \
    && python3 --version \
    && pip --version \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ==========================
#  安装 Python 依赖
# ==========================
WORKDIR /opt/inference
ARG PIP_INDEX=https://pypi.org/simple

RUN pip install --upgrade -i "$PIP_INDEX" pip \
    && pip install -i "$PIP_INDEX" "diskcache>=5.6.1" "jinja2>=2.11.3" \
    && pip install "llama-cpp-python>=0.2.82" -i https://abetlen.github.io/llama-cpp-python/whl/cu124 \
    && pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/xinference/deploy/docker/requirements.txt \
    && pip install -i "$PIP_INDEX" --no-deps sglang \
    && pip install -i "$PIP_INDEX" "xinference==1.9.1" \
    && python3 setup.py build_web \
    && git restore . \
    && pip cache purge

# ==========================
#  FlashInfer cu121 (匹配 CUDA 12.1)
# ==========================
RUN pip install https://github.com/flashinfer-ai/flashinfer/releases/download/v0.0.9/flashinfer-0.0.9+cu121torch2.3-cp310-cp310-linux_x86_64.whl

# ==========================
#  Node.js (web 构建)
# ==========================
ENV NVM_DIR=/usr/local/nvm \
    NODE_VERSION=14.21.1 \
    PATH=/usr/local/nvm/versions/node/v14.21.1/bin:$PATH

RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# ==========================
#  Entrypoint
# ==========================
ENTRYPOINT ["xinference"]
