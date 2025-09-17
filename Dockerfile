FROM vllm/vllm-openai:v0.5.3

COPY . /opt/inference
WORKDIR /opt/inference

ENV NVM_DIR=/usr/local/nvm \
    NODE_VERSION=14.21.1 \
    FLASH_ATTENTION_SKIP_CUDA_BUILD=TRUE

# ----------------- 系统包：用清华 Ubuntu 源 -----------------
RUN sed -i 's|http://archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' \
        /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get install -y wget curl procps git libgl1 libc6 libnuma1 && \
    apt-get -y --only-upgrade install libstdc++6 && \
    mkdir -p $NVM_DIR && \
    # NVM 安装脚本（GitHub 仍走 raw.githubusercontent.com，如被墙可换 gitee 镜像）
    curl -o- https://ghproxy.com/https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default && \
    # 配置 npm 国内镜像
    npm config set registry https://registry.npmmirror.com && \
    apt-get -yq clean && rm -rf /var/lib/apt/lists/*

ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cublas/lib

# ----------------- Python 依赖：国内 PyPI 镜像 -----------------
ARG PIP_INDEX=https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install -i $PIP_INDEX --upgrade pip setuptools wheel && \
    pip install -i $PIP_INDEX \
        "diskcache>=5.6.1" \
        "jinja2>=2.11.3" \
        "numpy<2.0.0,>=1.23" \
        importlib_resources \
        sgl-kernel==0.1.2 \
        WeTextProcessing==1.0.4.1 && \
    # 如果 requirements_cpu-base.txt 里含 numpy 等已装包，加 --upgrade-strategy only-if-needed 避免重复
    pip install -i $PIP_INDEX --upgrade-strategy only-if-needed \
        -r /opt/inference/xinference/deploy/docker/requirements_cpu/requirements_cpu-base.txt && \
    cd /opt/inference && \
    npm ci && \
    python3 setup.py build_web && \
    git restore . && \
    pip install -i $PIP_INDEX --no-deps . && \
    pip cache purge

# ----------------- Conda 用清华源 + 中科大 conda-forge 镜像 -----------------
RUN wget -O Miniforge3.sh "https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/Latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p /opt/conda && \
    rm Miniforge3.sh && \
    # 换 conda 频道
    /opt/conda/bin/conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge && \
    /opt/conda/bin/conda config --remove channels defaults && \
    /opt/conda/bin/conda create -n ffmpeg-env 'ffmpeg<7' -y && \
    ln -sf /opt/conda/envs/ffmpeg-env/bin/ffmpeg /usr/local/bin/ffmpeg && \
    ln -sf /opt/conda/envs/ffmpeg-env/bin/ffprobe /usr/local/bin/ffprobe && \
    /opt/conda/bin/conda clean --all -y

ENTRYPOINT []
CMD ["/bin/bash"]
