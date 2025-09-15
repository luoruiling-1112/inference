########## 阶段 1：编译 &安装 ##########
FROM vllm/vllm-openai:v0.6.0 AS builder

ENV DEBIAN_FRONTEND=noninteractive
# 1. 系统依赖 + Node（同你原来）
ENV NVM_DIR=/usr/local/nvm NODE_VERSION=14.21.1
RUN apt-get -y update && \
    apt-get install -y wget curl procps git libgl1 libc6 libnuma1 && \
    apt-get -y --only-upgrade install libstdc++6 && \
    mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && nvm use default && \
    apt-get -yq clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV FLASH_ATTENTION_SKIP_CUDA_BUILD=TRUE

# 2. 用官方 PyPI 装全部包（同你原来逻辑，但放在 builder 阶段）
ARG PIP_INDEX=https://pypi.org/simple
RUN pip install --upgrade pip setuptools wheel && \
    pip install -i $PIP_INDEX "diskcache>=5.6.1" "jinja2>=2.11.3" "numpy<2.0.0,>=1.23" && \
    pip install -i $PIP_INDEX --upgrade-strategy only-if-needed \
        -r /opt/inference/requirements/requirements-base.txt \
        -r /opt/inference/requirements/requirements-ml.txt \
        -r /opt/inference/requirements/requirements-models.txt && \
    pip install -i $PIP_INDEX --no-deps WeTextProcessing==1.0.4.1 && \
    pip install torch==2.4.1+cu121 torchvision==0.19.1+cu121 torchaudio==2.4.1+cu121 \
        --index-url https://download.pytorch.org/whl/cu121 && \
    pip install -i $PIP_INDEX importlib_resources sgl-kernel==0.1.2

# 3. 构建前端 & 安装项目
COPY . /opt/inference
WORKDIR /opt/inference
RUN python3 setup.py build_web && git restore . && pip install --no-deps .

# 4. conda 装 ffmpeg 也放在 builder
RUN wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p /opt/conda && rm Miniforge3.sh && \
    /opt/conda/bin/conda create -n ffmpeg-env -c conda-forge 'ffmpeg<7' -y && \
    /opt/conda/bin/conda clean --all -y

########## 阶段 2：运行时镜像 ##########
FROM vllm/vllm-openai:v0.6.0

# 只复制必要内容，不复制缓存/构建中间文件
COPY --from=builder /opt/conda /opt/conda
COPY --from=builder /opt/inference /opt/inference
COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
COPY --from=builder $NVM_DIR/versions/node/v14.21.1 /usr/local/nvm/versions/node/v14.21.1

ENV NVM_DIR=/usr/local/nvm
ENV PATH=$NVM_DIR/versions/node/v14.21.1/bin:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cublas/lib:/opt/conda/envs/ffmpeg-env/lib
RUN ln -sf /opt/conda/envs/ffmpeg-env/bin/ffmpeg /usr/local/bin/ffmpeg && \
    ln -sf /opt/conda/envs/ffmpeg-env/bin/ffprobe /usr/local/bin/ffprobe

WORKDIR /opt/inference
ENTRYPOINT []
CMD ["/bin/bash"]
