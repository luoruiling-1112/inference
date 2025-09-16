FROM vllm/vllm-openai:v0.5.3

COPY . /opt/inference
WORKDIR /opt/inference

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 14.21.1

RUN apt-get -y update \
  && apt-get install -y wget curl procps git libgl1 \
  && apt-get install -y --only-upgrade libstdc++6 \
  && apt-get install -y libc6 libnuma1 \
  && mkdir -p $NVM_DIR \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh  | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default \
  && apt-get -yq clean
  
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cublas/lib
ENV FLASH_ATTENTION_SKIP_CUDA_BUILD TRUE

ARG PIP_INDEX=https://pypi.org/simple 
RUN pip install --upgrade -i "$PIP_INDEX" pip setuptools wheel&& \
    pip install -i "$PIP_INDEX" "diskcache>=5.6.1" "jinja2>=2.11.3" && \
    pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/requirements/requirements-base.txt && \
    pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/requirements/requirements-ml.txt && \
    pip install -i "$PIP_INDEX" --upgrade-strategy only-if-needed -r /opt/inference/requirements/requirements-models.txt && \
    pip install -i "$PIP_INDEX" "numpy<2.0.0,>=1.23" && \
    pip install -i "$PIP_INDEX" --no-deps WeTextProcessing==1.0.4.1 && \
    pip install importlib_resources && \
    pip install -i "$PIP_INDEX" sgl-kernel==0.1.2 && \
    cd /opt/inference && \
    python3 setup.py build_web && \
    git restore . && \
    pip install -i "$PIP_INDEX" --no-deps "." && \
    pip cache purge

RUN apt-get install -y wget && \
    wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3- $(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p /opt/conda && \
    rm Miniforge3.sh

RUN /opt/conda/bin/conda create -n ffmpeg-env -c conda-forge 'ffmpeg<7' -y && \
    ln -s /opt/conda/envs/ffmpeg-env/bin/ffmpeg /usr/local/bin/ffmpeg && \
    ln -s /opt/conda/envs/ffmpeg-env/bin/ffprobe /usr/local/bin/ffprobe && \
    /opt/conda/bin/conda clean --all -y

# Overwrite the entrypoint of vllm's base image
ENTRYPOINT []
CMD ["/bin/bash"]
