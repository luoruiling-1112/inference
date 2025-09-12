# -------------- 1. 官方 vLLM 0.6.0 已含 CUDA 12.1 + Python 3.10 + vLLM --------------
FROM vllm/vllm-openai:v0.6.0

# -------------- 2. 修复原历史 LABEL 语法错误 --------------
LABEL maintainer="Xorbits AI <xorbitsai@github.com>"

# -------------- 3. 一键升级到 Xinference v1.9.1 --------------
# 国内用户取消注释下一行可加速
# RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install --upgrade pip && \
    pip install --no-cache-dir 'xinference[all]==1.9.1'

# -------------- 4. 默认启动方式 --------------
ENTRYPOINT ["xinference"]
CMD ["supervisor"]
