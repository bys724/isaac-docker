# Isaac Lab Docker Image
# NVIDIA Isaac Lab 개발 환경을 위한 Docker 이미지

FROM nvcr.io/nvidia/isaac-sim:4.2.0

# 메타데이터 설정
LABEL maintainer="your-email@example.com"
LABEL description="Isaac Lab development environment for robotics learning"

# 환경 변수 설정
ENV ACCEPT_EULA=Y
ENV ISAACSIM_PATH=/isaac-sim
ENV ISAAC_LAB_PATH=/workspace/isaaclab
ENV PYTHON_PATH=/isaac-sim/python.sh
ENV DISPLAY=:0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# 작업 디렉토리 설정
WORKDIR /workspace

# 필요한 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    python3-pip \
    python3-dev \
    build-essential \
    cmake \
    nano \
    vim \
    htop \
    tmux \
    wget \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Isaac Lab 클론 및 설치
RUN git clone https://github.com/isaac-sim/IsaacLab.git ${ISAAC_LAB_PATH} && \
    cd ${ISAAC_LAB_PATH} && \
    git lfs pull

# Python 패키지 설치
RUN ${PYTHON_PATH} -m pip install --upgrade pip && \
    ${PYTHON_PATH} -m pip install \
    torch torchvision torchaudio \
    gymnasium \
    stable-baselines3 \
    tensorboard \
    wandb \
    hydra-core \
    omegaconf \
    matplotlib \
    pandas \
    jupyter \
    jupyterlab

# Isaac Lab 의존성 설치
WORKDIR ${ISAAC_LAB_PATH}
RUN ${PYTHON_PATH} -m pip install -e .

# 엔트리포인트 스크립트 복사
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 포트 노출 (Jupyter, TensorBoard, Isaac Sim UI 등)
EXPOSE 8888 6006 8899 8211

# 볼륨 마운트 포인트
VOLUME ["/workspace/data", "/workspace/logs", "/workspace/experiments"]

# 작업 디렉토리로 돌아가기
WORKDIR /workspace

# 엔트리포인트 설정
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]