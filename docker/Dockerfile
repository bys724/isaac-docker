# Isaac Lab Docker Image
# NVIDIA Isaac Lab 개발 환경을 위한 Docker 이미지
# Docker Hub: bys724/isaac-lab
# Based on Isaac Sim 5.0.0

FROM nvcr.io/nvidia/isaac-sim:5.0.0

# 메타데이터 설정
LABEL maintainer="bys724"
LABEL description="Production-ready Isaac Lab environment for robotics development"
LABEL version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/bys724/isaac-docker"

# 환경 변수 설정
ENV ACCEPT_EULA=Y
ENV PRIVACY_CONSENT=Y
ENV ISAACSIM_PATH=/isaac-sim
ENV ISAAC_LAB_PATH=/isaac-sim/IsaacLab
ENV ISAACSIM_PYTHON_EXE=/isaac-sim/python.sh
ENV DISPLAY=:0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# 작업 디렉토리 설정
WORKDIR /isaac-sim

# 필요한 시스템 패키지 설치 (Isaac Lab 공식 요구사항 포함)
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    git-lfs \
    python3-pip \
    python3-dev \
    libglib2.0-0 \
    ncurses-term \
    nano \
    vim \
    htop \
    tmux \
    wget \
    curl \
    libgl1-mesa-glx \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# 캐시 디렉토리 생성 (컨테이너 내부)
RUN mkdir -p /isaac-sim/kit/cache \
    /root/.cache/ov \
    /root/.cache/pip \
    /root/.cache/nvidia/GLCache \
    /root/.nv/ComputeCache \
    /root/.nvidia-omniverse/logs \
    /root/.local/share/ov/data \
    /root/Documents

# Isaac Lab 서브모듈 복사
COPY IsaacLab /isaac-sim/IsaacLab

# Requirements 파일 복사
COPY requirements.txt /tmp/requirements.txt

# Isaac Lab 설치
WORKDIR /isaac-sim/IsaacLab
RUN ./isaaclab.sh --install && \
    # Pip 업그레이드 (주의: 너무 최신 버전은 호환성 문제 가능)
    /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip install --upgrade "pip<24.2" && \
    # Requirements 설치 (의존성 순서 중요)
    /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip install --no-cache-dir -r /tmp/requirements.txt && \
    # 설치 완료 마커 생성
    touch /isaac-sim/IsaacLab/.isaac_lab_installed && \
    # 설치 검증
    /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -c "import toml; import isaaclab; print('✓ Isaac Lab installation verified')" && \
    # Cleanup
    rm /tmp/requirements.txt

# 엔트리포인트 스크립트 복사
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 포트 노출 (Jupyter, TensorBoard, Isaac Sim Streaming Client 등)
EXPOSE 8888 6006 8211 8899 8011

# 작업 디렉토리를 Isaac Lab으로 설정 (마운트되면 자동으로 여기서 시작)
WORKDIR /isaac-sim/IsaacLab

# 엔트리포인트 설정
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]