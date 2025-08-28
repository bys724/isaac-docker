# Isaac Lab Docker

NVIDIA Isaac Lab 개발을 위한 프로덕션 레디 Docker 환경

## 개요

이 저장소는 NVIDIA Isaac Lab을 Docker 컨테이너에서 실행하기 위한 최적화된 환경을 제공합니다. 
- **Docker Hub**: [`bys724/isaac-lab`](https://hub.docker.com/r/bys724/isaac-lab)
- **Base Image**: NVIDIA Isaac Sim 5.0.0
- **Purpose**: 로봇 학습 프로젝트를 위한 즉시 사용 가능한 Isaac Lab 환경

## 주요 특징

- **Isaac Lab**: 로봇 학습을 위한 모듈식 프레임워크
- **Isaac Sim 통합**: NVIDIA 공식 도커 이미지 활용
- **강화학습 지원**: stable-baselines3, rl-games 등 주요 라이브러리 포함
- **GPU 가속**: NVIDIA GPU를 활용한 고속 시뮬레이션
- **개발 도구**: Jupyter Lab, TensorBoard, WandB 연동

## 시스템 요구사항

### 하드웨어
- NVIDIA GPU (RTX 3060 이상 권장)
- 16GB RAM 이상
- 50GB 이상의 여유 디스크 공간

### 소프트웨어
- Ubuntu 20.04/22.04
- NVIDIA Driver 525.60.11 이상
- Docker 20.10 이상
- Docker Compose 2.0 이상
- NVIDIA Container Toolkit

## 사용 방법

### 방법 1: 사전 빌드된 이미지 사용 (권장) 🚀

다른 프로젝트에서 Isaac Lab 환경이 필요한 경우, Docker Hub에서 이미지를 바로 사용할 수 있습니다:

```bash
# 1. Docker Hub에서 이미지 pull
docker pull bys724/isaac-lab:latest

# 2. 컨테이너 실행
docker run --rm -it \
  --gpus all \
  --network host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v $(pwd):/workspace \
  bys724/isaac-lab:latest

# 또는 docker-compose 사용 (프로젝트 디렉토리에 docker-compose.yml 생성)
docker-compose up isaac-lab
```

### 방법 2: 개발 환경 구축 (이 저장소 사용)

Isaac Lab 자체 개발이나 커스터마이징이 필요한 경우:

```bash
# 1. 저장소 클론
git clone https://github.com/bys724/isaac-docker.git
cd isaac-docker

# 2. 서브모듈 초기화 (Isaac Lab 소스 코드)
git submodule update --init --recursive

# 3. 환경 변수 설정
cp .env.example .env

# 4. 개발 이미지 빌드 및 실행
docker-compose up -d isaac-lab-dev
docker exec -it isaac-lab-dev bash
```

## 빠른 시작 가이드

### 필수 요구사항

```bash
# NVIDIA Container Toolkit 설치
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# X11 권한 설정 (GUI 사용 시)
xhost +local:docker
```

## 🚀 프로젝트에서 Isaac Lab 사용하기

### 방법 1: 기본 이미지 직접 사용 (간단한 프로젝트)

```bash
# Docker Hub에서 이미지 pull
docker pull bys724/isaac-lab:latest

# 컨테이너 실행
docker run --rm -it \
  --gpus all \
  --network host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v $(pwd):/workspace \
  bys724/isaac-lab:latest bash
```

### 방법 2: 프로젝트별 커스터마이징 (권장)

**1. 프로젝트 구조 설정:**

```bash
my_robot_project/
├── docker/
│   ├── Dockerfile       # 커스텀 이미지 (선택사항)
│   └── entrypoint.sh    # 프로젝트 entrypoint
├── requirements.txt     # 프로젝트 의존성
├── docker-compose.yml   # Docker 설정
└── src/                 # 프로젝트 코드
```

**2. entrypoint.sh 생성 (이 저장소의 docker/entrypoint.example.sh 참고):**

```bash
# entrypoint.example.sh를 복사하여 커스터마이징
wget https://raw.githubusercontent.com/bys724/isaac-docker/main/docker/entrypoint.example.sh
mv entrypoint.example.sh docker/entrypoint.sh
chmod +x docker/entrypoint.sh
```

**3. docker-compose.yml 생성:**

```yaml
version: '3.8'
services:
  my-robot:
    image: bys724/isaac-lab:latest  # 베이스 이미지 사용
    container_name: my-robot-env
    runtime: nvidia
    environment:
      - DISPLAY=${DISPLAY:-:0}
      - ACCEPT_EULA=Y
      - PROJECT_NAME=my_robot_project
      - NVIDIA_VISIBLE_DEVICES=all
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
      - ./:/workspace:rw
      - ./docker/entrypoint.sh:/entrypoint.sh:ro  # 커스텀 entrypoint
    network_mode: host
    stdin_open: true
    tty: true
    entrypoint: ["/entrypoint.sh"]
    command: bash
```

**4. requirements.txt 생성 (프로젝트 의존성):**

```txt
# My project dependencies
numpy>=1.24.0
opencv-python
# Add your project-specific packages here
```

**5. 실행:**

```bash
# X11 권한 설정
xhost +local:docker

# 컨테이너 시작
docker-compose up -d my-robot

# 컨테이너 접속
docker exec -it my-robot-env bash
```

### 방법 3: 커스텀 이미지 빌드 (대규모 프로젝트)

**Dockerfile 생성:**

```dockerfile
FROM bys724/isaac-lab:latest

# 프로젝트별 추가 설정
WORKDIR /workspace

# 프로젝트 의존성 설치
COPY requirements.txt /tmp/project-requirements.txt
RUN /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip install \
    --no-cache-dir -r /tmp/project-requirements.txt && \
    rm /tmp/project-requirements.txt

# 프로젝트 코드 복사 (선택사항)
COPY src /workspace/src

# 커스텀 entrypoint
COPY docker/entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["bash"]
```

## Isaac Lab 사용법

### Isaac Lab 예제 실행

Isaac Lab 설치가 완료된 후 아래 명령어들을 실행할 수 있습니다:

#### 1. 시뮬레이션 기본 예제

```bash
cd /isaac-sim/IsaacLab

# 빈 시뮬레이션 환경 생성 (가장 기본)
./isaaclab.sh -p source/standalone/tutorials/00_sim/create_empty.py

# 헤드리스 모드로 실행 (GUI 없이)
./isaaclab.sh -p source/standalone/tutorials/00_sim/create_empty.py --headless

# 다양한 프림(기본 도형) 생성
./isaaclab.sh -p source/standalone/tutorials/00_sim/spawn_prims.py
```

#### 2. 로봇 데모

```bash
# 4족 로봇 데모
./isaaclab.sh -p source/standalone/demos/quadrupeds.py

# 2족 로봇 데모
./isaaclab.sh -p source/standalone/demos/bipeds.py

# 로봇 팔 데모
./isaaclab.sh -p source/standalone/demos/arms.py

# 로봇 손 데모
./isaaclab.sh -p source/standalone/demos/hands.py
```

#### 3. 강화학습 환경

```bash
# Cartpole 환경 (가벼운 테스트용)
./isaaclab.sh -p source/standalone/tutorials/03_envs/run_cartpole_rl_env.py

# Cartpole 랜덤 에이전트
./isaaclab.sh -p source/standalone/workflows/rl_games/play.py --task Isaac-Cartpole-v0

# Ant 로봇 환경
./isaaclab.sh -p source/standalone/workflows/rl_games/play.py --task Isaac-Ant-v0 --num_envs 32
```

#### 4. 강화학습 훈련

```bash
# RL Games를 사용한 훈련
./isaaclab.sh -p source/standalone/workflows/rl_games/train.py \
    --task Isaac-Cartpole-v0 \
    --num_envs 64 \
    --headless

# RSL-RL을 사용한 훈련
./isaaclab.sh -p source/standalone/workflows/rsl_rl/train.py \
    --task Isaac-Velocity-Flat-Anymal-C-v0 \
    --num_envs 4096 \
    --headless

# Stable Baselines3를 사용한 훈련
./isaaclab.sh -p source/standalone/workflows/sb3/train.py \
    --task Isaac-Cartpole-v0 \
    --num_envs 16 \
    --headless
```

#### 5. 환경 목록 확인

```bash
# 사용 가능한 모든 환경 목록 보기
./isaaclab.sh -p source/standalone/workflows/rl_games/list_envs.py

# 특정 환경 정보 확인
./isaaclab.sh -p source/standalone/workflows/rl_games/play.py --task Isaac-Ant-v0 --print_info
```

#### 6. 센서 예제

```bash
# 카메라 센서
./isaaclab.sh -p source/standalone/tutorials/04_sensors/run_usd_camera.py

# Ray Caster (라이다 시뮬레이션)
./isaaclab.sh -p source/standalone/tutorials/04_sensors/run_ray_caster.py
```

### 성능 테스트

```bash
# GPU 메모리와 성능을 고려한 환경 수 조정
# 가벼운 테스트 (16 환경)
./isaaclab.sh -p source/standalone/workflows/rl_games/play.py \
    --task Isaac-Cartpole-v0 --num_envs 16

# 중간 부하 (256 환경)
./isaaclab.sh -p source/standalone/workflows/rl_games/play.py \
    --task Isaac-Ant-v0 --num_envs 256 --headless

# 높은 부하 (2048 환경) - GPU 메모리 충분할 때만
./isaaclab.sh -p source/standalone/workflows/rl_games/play.py \
    --task Isaac-Ant-v0 --num_envs 2048 --headless
```

### 유용한 옵션들

```bash
# --headless : GUI 없이 실행 (서버 환경)
# --num_envs N : 병렬 환경 개수 설정
# --device cuda:0 : 특정 GPU 사용
# --seed 42 : 랜덤 시드 고정 (재현성)
# --max_iterations 1000 : 최대 반복 횟수
```

## 📦 이미지 빌드 및 배포 가이드

### 이미지 빌드하기

```bash
# 1. 저장소 클론 및 서브모듈 초기화
git clone https://github.com/bys724/isaac-docker.git
cd isaac-docker
git submodule update --init --recursive

# 2. 이미지 빌드
docker-compose build isaac-lab

# 3. 빌드 확인
docker images | grep bys724/isaac-lab
```

### Docker Hub 배포 (관리자용)

```bash
# 1. Docker Hub 로그인
docker login
# Username: bys724
# Password: [your-docker-hub-token]

# 2. 버전 태깅
docker tag bys724/isaac-lab:latest bys724/isaac-lab:1.0.0
docker tag bys724/isaac-lab:latest bys724/isaac-lab:isaac-sim-5.0.0

# 3. 이미지 푸시
docker push bys724/isaac-lab:latest
docker push bys724/isaac-lab:1.0.0
docker push bys724/isaac-lab:isaac-sim-5.0.0

# 4. 배포 확인
docker pull bys724/isaac-lab:latest
```

### 버전 태깅 전략

| Tag | Description | Use Case |
|-----|------------|----------|
| `latest` | 최신 안정 버전 | 일반 사용자 |
| `1.x.x` | 특정 버전 (Semantic Versioning) | 프로덕션 환경 |
| `isaac-sim-5.0.0` | Isaac Sim 버전 명시 | 호환성 보장 필요 시 |
| `dev` | 개발 버전 | 테스트 목적 |

### 이미지 내용

빌드된 이미지에는 다음이 포함됩니다:
- ✅ NVIDIA Isaac Sim 5.0.0
- ✅ Isaac Lab (사전 설치됨)
- ✅ RL 프레임워크 (RL-Games, Stable-Baselines3, SKRL)
- ✅ 실험 추적 도구 (TensorBoard, WandB)
- ✅ Python 3.11 환경

## 디렉토리 구조

```
isaac-docker/
├── docker/               # Docker 설정 파일
│   ├── Dockerfile       # Isaac Lab 도커 이미지 정의
│   └── entrypoint.sh    # 컨테이너 진입점 스크립트
├── IsaacLab/            # Isaac Lab 서브모듈 (개발 빌드용)
├── workspace/           # 사용자 프로젝트 공간
├── docker-compose.yml   # Docker Compose 설정
├── .env.example         # 환경 변수 예제
└── README.md           # 이 파일
```

## 주요 명령어

### Docker 관리

```bash
# 컨테이너 시작/중지
docker-compose up -d isaac-lab     # 백그라운드 실행
docker-compose down                # 중지 및 제거

# 로그 확인
docker-compose logs -f isaac-lab

# 컨테이너 상태 확인
docker-compose ps

# 이미지 재빌드 (변경사항 반영)
docker-compose build --no-cache isaac-lab
```

### GPU 관리

```bash
# GPU 상태 확인
nvidia-smi

# 특정 GPU만 사용
export NVIDIA_VISIBLE_DEVICES=0
docker-compose up -d isaac-lab

# 컨테이너 내부에서 GPU 확인
docker exec isaac-lab nvidia-smi
```

## 환경 변수

`.env` 파일에서 다음 변수들을 설정할 수 있습니다:

- `ACCEPT_EULA=Y` - NVIDIA EULA 동의 (필수)
- `DISPLAY` - GUI 디스플레이 설정
- `NVIDIA_VISIBLE_DEVICES` - 사용할 GPU 지정
- `WANDB_API_KEY` - WandB 실험 추적 (선택)

## 개발 워크플로우

### 1. 로컬 개발

```bash
# 호스트에서 코드 작성
vim workspace/custom/my_robot_env.py

# 컨테이너에서 테스트 (자동 동기화)
docker exec -it isaac-lab bash
cd /workspace/custom
python my_robot_env.py
```

### 2. Jupyter Notebook 사용

```bash
# 컨테이너 내부에서
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root

# 브라우저에서 http://localhost:8888 접속
```

### 3. TensorBoard 모니터링

```bash
# 컨테이너 내부에서
tensorboard --logdir=/workspace/logs --host=0.0.0.0

# 브라우저에서 http://localhost:6006 접속
```

## 트러블슈팅

### X11 디스플레이 오류

```bash
# X 서버 접근 권한 설정
xhost +local:docker

# 환경 변수 확인
echo $DISPLAY
```

### GPU 인식 실패

```bash
# NVIDIA 런타임 테스트
docker run --rm --gpus all nvidia/cuda:11.8.0-base nvidia-smi

# Docker 데몬 재시작
sudo systemctl restart docker
```

### 메모리 부족

```bash
# Docker 리소스 정리
docker system prune -a
docker volume prune

# 사용하지 않는 이미지 제거
docker rmi $(docker images -q -f dangling=true)
```

### Isaac Lab 모듈 에러

```bash
# 컨테이너 내부에서 의존성 재설치
cd /isaac-sim/IsaacLab
./isaaclab.sh --install
```

## 성능 최적화

### GPU 메모리 관리

```python
# 코드에서 GPU 메모리 제한
import torch
torch.cuda.set_per_process_memory_fraction(0.8)
```

### 병렬 환경 실행

```bash
# 다중 환경 병렬 실행
./isaaclab.sh -p source/standalone/workflows/skrl/train.py \
    --task Isaac-Ant-v0 \
    --num_envs 2048 \
    --headless
```

## 예제 프로젝트

### 기본 시뮬레이션

```python
# workspace/custom/simple_sim.py
from omni.isaac.lab.app import AppLauncher
app_launcher = AppLauncher(headless=False)
simulation_app = app_launcher.app

# 시뮬레이션 코드 작성
# ...
```

### 강화학습 환경

```python
# workspace/custom/custom_rl_env.py
from omni.isaac.lab.envs import ManagerBasedRLEnv
# 사용자 정의 환경 구현
```

## 기여 방법

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. Isaac Lab 자체는 별도의 라이선스를 따릅니다.

## 문의 및 지원

- Issue Tracker: [GitHub Issues](https://github.com/yourusername/isaac-docker/issues)
- Discord: [Isaac Lab Community](https://discord.gg/isaac-lab)

## 🔍 빠른 참조

### 필수 파일 목록

| 파일 | 설명 | 용도 |
|------|------|------|
| `docker/entrypoint.example.sh` | Entrypoint 템플릿 | 프로젝트 커스터마이징 참고 |
| `requirements.txt` | Python 의존성 목록 | 패키지 버전 확인 |
| `docker-compose.yml` | Docker Compose 설정 | 컨테이너 실행 설정 참고 |
| `docker/Dockerfile` | 이미지 빌드 정의 | 커스텀 이미지 빌드 시 참고 |

### 환경 변수

```bash
ACCEPT_EULA=Y              # NVIDIA EULA 동의 (필수)
PRIVACY_CONSENT=Y          # 개인정보 동의 (필수)
DISPLAY=:0                 # GUI 디스플레이
NVIDIA_VISIBLE_DEVICES=all # GPU 설정
WANDB_API_KEY=xxx         # WandB 연동 (선택)
PROJECT_NAME=my_project    # 프로젝트 이름 (커스텀)
```

### 유용한 명령어

```bash
# GPU 확인
docker exec isaac-lab nvidia-smi

# Isaac Lab 버전 확인
docker exec isaac-lab bash -c "cd /isaac-sim/IsaacLab && cat VERSION"

# Python 패키지 목록
docker exec isaac-lab pip list | grep -E "isaaclab|rl-games|stable-baselines3"

# 컨테이너 로그
docker logs isaac-lab
```

## 참고 자료

- [Isaac Lab Documentation](https://isaac-sim.github.io/IsaacLab/)
- [Isaac Sim Documentation](https://docs.omniverse.nvidia.com/isaacsim/latest/)
- [Docker Hub - bys724/isaac-lab](https://hub.docker.com/r/bys724/isaac-lab)
- [GitHub - isaac-docker](https://github.com/bys724/isaac-docker)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)