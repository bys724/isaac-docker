# Isaac Docker 프로젝트 가이드 (Claude Code용)

## 프로젝트 개요
이 저장소는 NVIDIA Isaac Sim과 Isaac Lab을 위한 Docker 기반 개발 환경입니다.

## 주요 컴포넌트

### 1. Isaac Sim
- 물리 기반 로봇 시뮬레이션 플랫폼
- 경로: `docker/isaac-sim/`
- 베이스 이미지: `nvcr.io/nvidia/isaac-sim:4.2.0`

### 2. Isaac Lab  
- 로봇 학습 프레임워크
- 경로: `docker/isaac-lab/`
- 강화학습 및 모방학습 지원

## 디렉토리 구조
```
isaac-docker/
├── docker/           # Docker 설정 파일
├── config/          # 환경 설정
├── data/            # 시뮬레이션 데이터
├── experiments/     # 실험 결과
├── src/            # 사용자 코드
└── scripts/        # 유틸리티 스크립트
```

## 주요 명령어

### Docker 관리
```bash
docker-compose build         # 이미지 빌드
docker-compose up -d         # 서비스 시작
docker-compose down          # 서비스 중지
docker-compose logs -f       # 로그 확인
```

### Isaac Sim 실행
```bash
docker-compose exec isaac-sim bash
/isaac-sim/isaac-sim.sh
```

### Isaac Lab 실행
```bash
docker-compose exec isaac-lab bash
cd /workspace/isaaclab
python source/standalone/tutorials/[예제파일].py
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
1. 코드를 `src/` 디렉토리에 작성
2. Docker 컨테이너에서 실행
3. 결과는 `experiments/`에 저장
4. 로그는 `logs/`에서 확인

## 주의사항
- GPU 메모리 관리 필요
- 대용량 시뮬레이션 데이터 생성 가능
- X11 포워딩 설정 필요 (GUI 사용시)