# Isaac Sim Docker Image
# NVIDIA Isaac Sim 개발 환경을 위한 Docker 이미지

FROM nvcr.io/nvidia/isaac-sim:4.2.0

# 메타데이터 설정
LABEL maintainer="your-email@example.com"
LABEL description="Isaac Sim development environment"

# 환경 변수 설정
ENV ACCEPT_EULA=Y
ENV OMNI_SERVER=localhost
ENV OMNI_PORT=8899
ENV DISPLAY=:0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# 작업 디렉토리 설정
WORKDIR /workspace

# 필요한 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    git \
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
    && rm -rf /var/lib/apt/lists/*

# Python 패키지 설치
RUN pip3 install --upgrade pip && \
    pip3 install \
    numpy \
    matplotlib \
    pandas \
    jupyter \
    jupyterlab \
    tensorboard

# Isaac Sim 추가 확장 설치 (선택사항)
# RUN /isaac-sim/python.sh -m pip install [추가 패키지]

# 엔트리포인트 스크립트 복사
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 포트 노출 (Jupyter, Isaac Sim UI 등)
EXPOSE 8888 8899 8211

# 볼륨 마운트 포인트
VOLUME ["/workspace/data", "/workspace/logs"]

# 엔트리포인트 설정
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]