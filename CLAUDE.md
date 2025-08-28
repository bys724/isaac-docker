# Isaac Docker 프로젝트 가이드 (Claude Code용)

## 프로젝트 개요
이 저장소는 NVIDIA Isaac Sim과 Isaac Lab을 위한 Docker 기반 개발 환경입니다.

## 주요 컴포넌트

### Isaac Sim + Isaac Lab 통합 환경
- 베이스 이미지: `nvcr.io/nvidia/isaac-sim:5.0.0`
- Isaac Lab: GitHub 서브모듈로 관리
- 강화학습 라이브러리 포함 (stable-baselines3, rl-games 등)

## 디렉토리 구조
```
isaac-docker/
├── docker/           # Docker 설정 파일
│   ├── Dockerfile   # Isaac Lab 도커 이미지
│   └── entrypoint.sh # 컨테이너 진입점 스크립트
├── IsaacLab/        # Isaac Lab 서브모듈 (공식 저장소)
├── config/          # 환경 설정
├── docker-compose.yml # Docker Compose 설정
└── .env            # 환경 변수
```

## 주요 명령어

### 초기 설정
```bash
# Isaac Lab 서브모듈 초기화
git submodule update --init --recursive
```

### Docker 관리
```bash
docker-compose build isaac-lab    # 이미지 빌드
docker-compose up -d isaac-lab     # 컨테이너 시작
docker-compose down               # 컨테이너 중지
docker-compose logs -f isaac-lab  # 로그 확인
```

### Isaac Lab 사용
```bash
# 컨테이너 접속
docker exec -it isaac-lab bash

# Isaac Lab 디렉토리로 이동
cd /isaac-sim/IsaacLab

# 예제 실행
./isaaclab.sh -p source/standalone/tutorials/00_sim/create_empty.py

# 강화학습 훈련
./isaaclab.sh -p source/standalone/workflows/skrl/train.py --task Isaac-Ant-v0 --headless
```

## 환경 변수
- `ACCEPT_EULA`: NVIDIA EULA 동의 (필수: Y)
- `DISPLAY`: GUI 디스플레이 설정
- `NVIDIA_VISIBLE_DEVICES`: GPU 설정
- `WANDB_API_KEY`: WandB 연동 (선택)

## GPU 요구사항
- NVIDIA GPU (RTX 3060 이상)
- NVIDIA Driver 525.60.11+
- CUDA 11.8+

## 트러블슈팅

### X11 오류
```bash
xhost +local:docker
```

### GPU 인식 실패
```bash
nvidia-smi  # GPU 상태 확인
docker run --rm --gpus all nvidia/cuda:11.8.0-base nvidia-smi
```

## 테스트 명령어
```bash
# GPU 테스트
docker-compose run --rm isaac-sim nvidia-smi

# Isaac Sim 버전 확인
docker-compose run --rm isaac-sim /isaac-sim/isaac-sim.sh --version
```

## 개발 워크플로우
1. Isaac Lab 서브모듈에서 직접 코드 수정
2. Docker 컨테이너에서 테스트 실행
3. 변경사항은 호스트와 자동 동기화 (볼륨 마운트)

## 주의사항
- GPU 메모리 관리 필요
- 대용량 시뮬레이션 데이터 생성 가능
- X11 포워딩 설정 필요 (GUI 사용시)