# Isaac Docker

NVIDIA Isaac Sim과 Isaac Lab을 위한 Docker 개발 환경

## 개요

이 저장소는 NVIDIA Isaac Sim과 Isaac Lab을 Docker 컨테이너에서 실행하기 위한 개발 환경을 제공합니다. 로봇 시뮬레이션, 강화학습, 컴퓨터 비전 등의 작업을 위한 통합 개발 환경을 구축할 수 있습니다.

## 주요 기능

- **Isaac Sim**: NVIDIA의 고성능 물리 시뮬레이션 환경
- **Isaac Lab**: 로봇 학습을 위한 프레임워크
- **GPU 가속**: NVIDIA GPU를 활용한 고속 시뮬레이션
- **Jupyter Lab**: 인터랙티브 개발 환경
- **TensorBoard**: 학습 과정 모니터링
- **WandB 연동**: 실험 추적 및 관리

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

## 설치 방법

### 1. NVIDIA Container Toolkit 설치

```bash
# NVIDIA GPG 키 추가
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# 패키지 설치
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### 2. 저장소 클론

```bash
git clone https://github.com/yourusername/isaac-docker.git
cd isaac-docker
```

### 3. 환경 변수 설정

```bash
cp config/env.example .env
# .env 파일을 편집하여 필요한 설정을 수정하세요
```

### 4. Docker 이미지 빌드

```bash
# 모든 이미지 빌드
docker-compose build

# 특정 이미지만 빌드
docker-compose build isaac-sim
docker-compose build isaac-lab
```

## 사용 방법

### Isaac Sim 실행

```bash
# Isaac Sim 컨테이너 시작
docker-compose up -d isaac-sim

# 컨테이너 접속
docker-compose exec isaac-sim bash

# Isaac Sim 실행 (컨테이너 내부)
/isaac-sim/isaac-sim.sh
```

### Isaac Lab 실행

```bash
# Isaac Lab 컨테이너 시작
docker-compose up -d isaac-lab

# 컨테이너 접속
docker-compose exec isaac-lab bash

# Isaac Lab 예제 실행 (컨테이너 내부)
cd /workspace/isaaclab
python source/standalone/tutorials/00_sim/create_empty_scene.py
```

### Jupyter Lab 사용

```bash
# Jupyter Lab 시작
docker-compose up -d jupyter

# 브라우저에서 http://localhost:8888 접속
```

### TensorBoard 모니터링

```bash
# 컨테이너 내부에서 TensorBoard 실행
tensorboard --logdir=/workspace/logs --host=0.0.0.0

# 브라우저에서 http://localhost:6006 접속
```

## 디렉토리 구조

```
isaac-docker/
├── docker/
│   ├── isaac-sim/       # Isaac Sim Docker 설정
│   │   ├── Dockerfile
│   │   └── entrypoint.sh
│   └── isaac-lab/        # Isaac Lab Docker 설정
│       ├── Dockerfile
│       └── entrypoint.sh
├── config/               # 설정 파일
│   └── env.example       # 환경 변수 예제
├── data/                 # 데이터 저장 디렉토리
├── logs/                 # 로그 저장 디렉토리
├── experiments/          # 실험 결과 저장
├── checkpoints/          # 모델 체크포인트
├── notebooks/            # Jupyter 노트북
├── src/                  # 사용자 코드
├── scripts/              # 유틸리티 스크립트
├── tools/                # 도구 및 헬퍼 스크립트
├── docker-compose.yml    # Docker Compose 설정
├── README.md             # 이 파일
├── CLAUDE.md            # Claude Code 참조 문서
└── .gitignore           # Git 제외 파일
```

## 주요 명령어

```bash
# 모든 서비스 시작
docker-compose up -d

# 모든 서비스 중지
docker-compose down

# 로그 확인
docker-compose logs -f [서비스명]

# 컨테이너 상태 확인
docker-compose ps

# 볼륨 정리
docker-compose down -v

# 이미지 재빌드
docker-compose build --no-cache [서비스명]
```

## GPU 메모리 관리

```bash
# GPU 상태 확인
nvidia-smi

# 특정 GPU만 사용
export CUDA_VISIBLE_DEVICES=0,1
docker-compose up -d isaac-lab
```

## 트러블슈팅

### X11 디스플레이 오류

```bash
# X 서버 접근 권한 설정
xhost +local:docker

# 또는 더 안전한 방법
xhost +local:root
```

### GPU를 인식하지 못하는 경우

```bash
# NVIDIA 런타임 확인
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi

# Docker 데몬 재시작
sudo systemctl restart docker
```

### 메모리 부족

```bash
# Docker 리소스 정리
docker system prune -a
docker volume prune
```

## 예제 프로젝트

`examples/` 디렉토리에서 다양한 예제를 확인할 수 있습니다:

- `basic_simulation/`: 기본 시뮬레이션 설정
- `reinforcement_learning/`: 강화학습 예제
- `computer_vision/`: 컴퓨터 비전 작업
- `robot_control/`: 로봇 제어 예제

## 기여 방법

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 문의 및 지원

- Issue Tracker: [GitHub Issues](https://github.com/yourusername/isaac-docker/issues)
- Email: your-email@example.com

## 참고 자료

- [NVIDIA Isaac Sim Documentation](https://docs.omniverse.nvidia.com/isaacsim/latest/)
- [Isaac Lab Documentation](https://isaac-sim.github.io/IsaacLab/)
- [Docker Documentation](https://docs.docker.com/)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)