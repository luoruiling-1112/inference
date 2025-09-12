FROM vllm/vllm-openai:v0.6.0

# -------------- 环境变量 --------------
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=14.21.1
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cublas/lib
ENV FLASH_ATTENTION_SKIP_CUDA_BUILD=TRUE

# -------------- 系统依赖 + CUDA 12.1 --------------
RUN apt-get update && \
    apt install -y wget curl procps git libgl1 software-properties-common && \
    apt-get install -y --only-upgrade libstdc++6 libc6 libnuma1 && \
    wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda_12.1.0_530.30.02_linux.run  && \
    chmod +x cuda_12.1.0_530.30.02_linux.run && \
    ./cuda_12.1.0_530.30.02_linux.run --silent --toolkit --override && \
    rm -f cuda_12.1.0_530.30.02_linux.run && \
    apt-get clean

# -------------- Node.js (via nvm) --------------
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh  | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# -------------- Python 依赖 --------------
ARG PIP_INDEX=https://pypi.org/simple 
RUN pip install --upgrade -i "$PIP_INDEX" pip setuptools wheel

COPY . /opt/inference
WORKDIR /opt/inference

RUN pip install -i "$PIP_INDEX" "diskcache>=5.6.1" "jinja2>=2.11.3" && \
    pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed \
        -r /opt/inference/xinference/deploy/docker/requirements/requirements-base.txt && \
    pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed \
        -r /opt/inference/xinference/deploy/docker/requirements/requirements-ml.txt && \
    pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed \
        -r /opt/inference/xinference/deploy/docker/requirements/requirements-models.txt && \
    pip install -i "$PIP_INDEX" transformers==4.53.2 && \
    pip install -i "$PIP_INDEX" --no-deps sglang==0.4.6.post5 && \
    pip install WeTextProcessing==1.0.4.1 --no-deps && \
    pip install importlib_resources && \
    pip install -i "$PIP_INDEX" sgl-kernel==0.1.8 && \
    pip install -i "$PIP_INDEX" torch==2.7.1 && \
    pip uninstall flashinfer -y && \
    pip install flashinfer-python==0.2.9rc2

# -------------- CUDA 12.1 专用 wheel --------------
RUN pip install https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.3.18/flash_attn-2.7.4+cu121torch2.7-cp310-cp310-linux_x86_64.whl 

# -------------- 构建 xinference + xllamacpp --------------
RUN cd /opt/inference && \
    python3 setup.py build_web && \
    git restore . && \
    pip install -i "$PIP_INDEX" --no-deps "." && \
    pip uninstall xllamacpp -y && \
    pip install "xllamacpp>=0.2.0" --index-url https://xorbitsai.github.io/xllamacpp/whl/cu121 

# -------------- 清理缓存 --------------
RUN pip cache purge

# -------------- Miniforge 仅用于 FFmpeg --------------
RUN wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p /opt/conda && rm Miniforge3.sh && \
    /opt/conda/bin/conda create -n ffmpeg-env -c conda-forge 'ffmpeg<7' -y && \
    ln -s /opt/conda/envs/ffmpeg-env/bin/ffmpeg /usr/local/bin/ffmpeg && \
    ln -s /opt/conda/envs/ffmpeg-env/bin/ffprobe /usr/local/bin/ffprobe && \
    /opt/conda/bin/conda clean --all -y

ENTRYPOINT []
CMD ["/bin/bash"]
