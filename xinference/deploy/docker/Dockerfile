FROM vllm/vllm-openai:v0.6.0

COPY . /opt/inference
WORKDIR /opt/inference
RUN ls -l xinference/deploy/docker/requirements/

# 仅装 xinference 需要的依赖，不碰 cuda/pytorch/flash
ARG PIP_INDEX=https://pypi.org/simple
RUN pip install --upgrade -i "$PIP_INDEX" pip && \
    pip install -i "$PIP_INDEX" -r xinference/deploy/docker/requirements/requirements-base.txt && \
    pip install -i "$PIP_INDEX" -r xinference/deploy/docker/requirements/requirements-ml.txt && \
    pip install -i "$PIP_INDEX" -r xinference/deploy/docker/requirements/requirements-models.txt && \
    pip install -i "$PIP_INDEX" --no-deps sglang==0.4.6.post5 "xllamacpp>=0.2.0" --extra-index-url https://xorbitsai.github.io/xllamacpp/whl/cu121 && \
    pip install --no-deps . && \
    pip cache purge

# 如需前端
ENV NODE_VERSION=14.21.1
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz | tar -xJ -C /usr/local --strip-components=1
RUN cd /opt/inference && python3 setup.py build_web

ENTRYPOINT []
CMD ["/bin/bash"]
