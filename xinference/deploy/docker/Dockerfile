FROM vllm/vllm-openai:v0.6.0

COPY . /opt/inference
WORKDIR /opt/inference

# ---------------  1. 统一用清华源  ---------------
ARG PIP_INDEX=https://pypi.tuna.tsinghua.edu.cn/simple
ARG PYTORCH_INDEX=https://download.pytorch.org/whl/cu121          # torch 官方 cu121 源
ARG CONDA_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud

ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=14.21.1

# ---------------  2. 系统依赖 + Node  ---------------
RUN apt-get -y update && \
    apt-get install -y wget curl procps git libgl1 libc6 libnuma1 && \
    apt-get -y --only-upgrade install libstdc++6 && \
    mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && nvm use default && \
    apt-get -yq clean && rm -rf /var/lib/apt/lists/*

ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cublas/lib
ENV FLASH_ATTENTION_SKIP_CUDA_BUILD=TRUE

# ---------------  3. Python 依赖（清华源） ---------------
RUN pip install -i $PIP_INDEX --upgrade pip setuptools wheel && \
    pip install -i $PIP_INDEX "diskcache>=5.6.1" "jinja2>=2.11.3" && \
    pip install -i $PIP_INDEX --upgrade-strategy only-if-needed \
        -r /opt/inference/requirements/requirements-base.txt \
        -r /opt/inference/requirements/requirements-ml.txt   \
        -r /opt/inference/requirements/requirements-models.txt && \
    pip install -i $PIP_INDEX "numpy<2.0.0,>=1.23" && \
    pip install -i $PIP_INDEX --no-deps WeTextProcessing==1.0.4.1 && \
    pip install torch==2.4.1+cu121 torchvision==0.19.1+cu121 torchaudio==2.4.1+cu121 \
        --index-url $PYTORCH_INDEX && \
    pip install -i $PIP_INDEX importlib_resources sgl-kernel==0.1.2 && \
    cd /opt/inference && \
    python3 setup.py build_web && \
    git restore . && \
    pip install -i $PIP_INDEX --no-deps . && \
    pip cache purge

# ---------------  4. Conda 装 ffmpeg（清华 conda 镜像） ---------------
RUN wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p /opt/conda && rm Miniforge3.sh && \
    /opt/conda/bin/conda config --add channels $CONDA_MIRROR/conda-forge && \
    /opt/conda/bin/conda config --set channel_priority strict && \
    /opt/conda/bin/conda create -n ffmpeg-env -c $CONDA_MIRROR/conda-forge 'ffmpeg<7' -y && \
    ln -sf /opt/conda/envs/ffmpeg-env/bin/ffmpeg /usr/local/bin/ffmpeg && \
    ln -sf /opt/conda/envs/ffmpeg-env/bin/ffprobe /usr/local/bin/ffprobe && \
    /opt/conda/bin/conda clean --all -y

# ---------------  5. 覆盖入口  ---------------
ENTRYPOINT []
CMD ["/bin/bash"]
