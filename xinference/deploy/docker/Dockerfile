# 2024/4/11 02:50
ARG RELEASE
# 2024/4/11 02:50
ARG LAUNCHPAD_BUILD_ARCH
# 2024/4/11 02:50
LABEL org.opencontainers.image.ref.name=ubuntu
# 2024/4/11 02:50
LABEL org.opencontainers.image.version=20.04
# 2024/4/11 02:50
ADD file:ea2128e23dce0162557abadd80656bd5ae047d573095d1d4323eb4154490dfdc in /
# 2024/4/11 02:50
CMD ["/bin/bash"]
# 2024/4/23 07:42
ENV NVARCH=x86_64
# 2024/4/23 07:42
ENV NVIDIA_REQUIRE_CUDA=cuda>=12.1 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471 brand=tesla,driver>=525,driver<526 brand=unknown,driver>=525,driver<526 brand=nvidia,driver>=525,driver<526 brand=nvidiartx,driver>=525,driver<526 brand=geforce,driver>=525,driver<526 brand=geforcertx,driver>=525,driver<526 brand=quadro,driver>=525,driver<526 brand=quadrortx,driver>=525,driver<526 brand=titan,driver>=525,driver<526
# 2024/4/23 07:42
ENV NV_CUDA_CUDART_VERSION=12.1.55-1
# 2024/4/23 07:42
ENV NV_CUDA_COMPAT_PACKAGE=cuda-compat-12-1
# 2024/4/23 07:42
ARG TARGETARCH
# 2024/4/23 07:42
LABEL maintainer=NVIDIA CORPORATION <cudatools@nvidia.com>
# 2024/4/23 07:42
RUN |1 TARGETARCH=amd64 RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/ ${NVARCH}/3bf863cc.pub | apt-key add - && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/ ${NVARCH} /" > /etc/apt/sources.list.d/cuda.list && apt-get purge --autoremove -y curl && rm -rf /var/lib/apt/lists/* # buildkit
# 2024/4/23 07:42
ENV CUDA_VERSION=12.1.0
# 2024/4/23 07:42
RUN |1 TARGETARCH=amd64 RUN apt-get update && apt-get install -y --no-install-recommends cuda-cudart-12-1=${NV_CUDA_CUDART_VERSION} ${NV_CUDA_COMPAT_PACKAGE} && rm -rf /var/lib/apt/lists/* # buildkit
# 2024/4/23 07:42
RUN |1 TARGETARCH=amd64 RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf # buildkit
# 2024/4/23 07:42
ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# 2024/4/23 07:42
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
# 2024/4/23 07:42
COPY NGC-DL-CONTAINER-LICENSE / # buildkit
# 2024/4/23 07:42
ENV NVIDIA_VISIBLE_DEVICES=all
# 2024/4/23 07:42
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
# 2024/7/23 15:03
ARG CUDA_VERSION=12.1.0
# 2024/7/23 15:03
ARG PYTHON_VERSION=3.10
# 2024/7/23 15:03
WORKDIR /vllm-workspace
# 2024/7/23 15:03
ENV DEBIAN_FRONTEND=noninteractive
# 2024/9/5 07:36
RUN |2 CUDA_VERSION=12.1.0 PYTHON_VERSION=3.10 RUN PYTHON_VERSION_STR=$(echo ${PYTHON_VERSION} | sed 's/\.//g') && echo "export PYTHON_VERSION_STR=${PYTHON_VERSION_STR}" >> /etc/environment # buildkit
# 2024/9/5 07:39
RUN |2 CUDA_VERSION=12.1.0 PYTHON_VERSION=3.10 RUN echo 'tzdata tzdata/Areas select America' | debconf-set-selections && echo 'tzdata tzdata/Zones/America select Los_Angeles' | debconf-set-selections && apt-get update -y && apt-get install -y ccache software-properties-common git curl sudo vim python3-pip && add-apt-repository ppa:deadsnakes/ppa && apt-get update -y && apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-venv libibverbs-dev && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 && update-alternatives --set python3 /usr/bin/python${PYTHON_VERSION} && ln -sf /usr/bin/python${PYTHON_VERSION}-config /usr/bin/python3-config && curl -sS https://bootstrap.pypa.io/get-pip.py  | python${PYTHON_VERSION} && python3 --version && python3 -m pip --version # buildkit
# 2024/9/5 07:39
RUN |2 CUDA_VERSION=12.1.0 PYTHON_VERSION=3.10 RUN ldconfig /usr/local/cuda-$(echo $CUDA_VERSION | cut -d. -f1,2)/compat/ # buildkit
# 2024/9/5 08:26
RUN |2 CUDA_VERSION=12.1.0 PYTHON_VERSION=3.10 RUN python3 -m pip install dist/*.whl --verbose # buildkit
# 2024/9/5 08:26
RUN |2 CUDA_VERSION=12.1.0 PYTHON_VERSION=3.10 RUN . /etc/environment && python3 -m pip install https://github.com/flashinfer-ai/flashinfer/releases/download/v0.1.6/flashinfer-0.1.6+cu121torch2.4-cp${PYTHON_VERSION_STR}-cp${PYTHON_VERSION_STR}-linux_x86_64.whl # buildkit
# 2024/9/5 08:27
RUN RUN pip install accelerate hf_transfer 'modelscope!=1.15.0' # buildkit
# 2024/9/5 08:27
ENV VLLM_USAGE_SOURCE=production-docker-image
# 2024/


