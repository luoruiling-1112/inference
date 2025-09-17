FROM vllm-openai:v0.5.3

COPY . /opt/inference
WORKDIR /opt/inference

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 14.21.1

RUN sed -i 's|http://archive.ubuntu.com|https://mirrors.tuna.tsinghua.edu.cn|g' \
        /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get install -y \
        wget curl procps git libgl1 libc6 libnuma1 && \
    apt-get -y --only-upgrade install libstdc++6 && \
    mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default && \
    apt-get -yq clean && rm -rf /var/lib/apt/lists/*
  
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cublas/lib
ENV FLASH_ATTENTION_SKIP_CUDA_BUILD TRUE

ARG PIP_INDEX=https://mirrors.aliyun.com/pypi/simple
ARG TRUST_HOST=mirrors.aliyun.com
RUN pip install --upgrade -i "$PIP_INDEX" pip setuptools wheel&& \
    pip install -i "$PIP_INDEX" "diskcache>=5.6.1" "jinja2>=2.11.3" && \
    pip install -i "$PIP_INDEX" "numpy<2.0.0,>=1.23" && \
    pip install -i "$PIP_INDEX" transformers==4.53.2 && \
    pip install -i "$PIP_INDEX" --no-deps sglang==0.4.6.post5 && \
    pip install -i "$PIP_INDEX" importlib_resources && \
    pip install -i "$PIP_INDEX" sgl-kernel==0.1.8
    pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/requirements/requirements-base.txt && \
    pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/requirements/requirements-ml.txt && \
    pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/requirements/requirements-models.txt && \
    pip install -i "$PIP_INDEX" --no-deps WeTextProcessing==1.0.4.1 && \
    pip install -i "$PIP_INDEX" \
    torch==2.3.1+cu121 \
    torchvision==0.16.1+cu121 \
    torchaudio==2.3.1+cu121 \
    --extra-index-url https://download.pytorch.org/whl/cu121

    pip uninstall -y flashinfer flash-attn && \
    pip install flashinfer-python==0.2.9rc2+cu121 \
        -f https://github.com/flashinfer-ai/flashinfer/releases/expanded_assets/v0.2.9rc2 && \
    pip install https://github.com/Dao-AILab/flash-attention/releases/download/v2.7.4/flash_attn-2.7.4+cu121torch2.3-cp310-cp310-linux_x86_64.whl

    cd /opt/inference && \
    python3 setup.py build_web && \
    git restore . && \
    pip install -i "$PIP_INDEX" --no-deps "." && \
    pip uninstall -y xllamacpp && \
    pip install "xllamacpp>=0.2.0" --index-url https://xorbitsai.github.io/xllamacpp/whl/cu121
    pip cache purge

# -------------- 1. 安装 miniforge（清华镜像） --------------
RUN apt-get update && apt-get install -y wget ca-certificates && \
    wget -O Miniforge3.sh \
    "https://mirrors.tuna.tsinghua.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p /opt/conda && \
    rm Miniforge3.sh && \
    # 一次性写入国内 conda 镜像配置，后续所有容器内 conda 命令均生效
    /opt/conda/bin/conda config --system --set show_channel_urls yes && \
    /opt/conda/bin/conda config --system --remove-key channels && \
    /opt/conda/bin/conda config --system --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main && \
    /opt/conda/bin/conda config --system --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free && \
    /opt/conda/bin/conda config --system --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r && \
    /opt/conda/bin/conda config --system --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge && \
    /opt/conda/bin/conda clean -i -y

# -------------- 2. 创建 ffmpeg 环境（国内源） --------------
RUN /opt/conda/bin/conda create -n ffmpeg-env -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge \
    'ffmpeg<7' -y && \
    ln -s /opt/conda/envs/ffmpeg-env/bin/ffmpeg /usr/local/bin/ffmpeg && \
    ln -s /opt/conda/envs/ffmpeg-env/bin/ffprobe /usr/local/bin/ffprobe && \
    /opt/conda/bin/conda clean --all -y
# Overwrite the entrypoint of vllm's base image

ENTRYPOINT []
CMD ["/bin/bash"]
