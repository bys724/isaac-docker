#!/bin/bash
# Isaac Docker 이미지 빌드 스크립트

set -e  # 오류 발생시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 사용법 출력
usage() {
    echo "사용법: $0 [옵션]"
    echo "옵션:"
    echo "  all        - 모든 이미지 빌드"
    echo "  isaac-sim  - Isaac Sim 이미지만 빌드"
    echo "  isaac-lab  - Isaac Lab 이미지만 빌드"
    echo "  clean      - 기존 이미지 제거 후 재빌드"
    echo "  --no-cache - 캐시 없이 빌드"
    echo "  help       - 이 도움말 출력"
}

# Docker 설치 확인
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되어 있지 않습니다."
        exit 1
    fi
    log_info "Docker 버전: $(docker --version)"
}

# Docker Compose 설치 확인
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose가 설치되어 있지 않습니다."
        exit 1
    fi
    log_info "Docker Compose 버전: $(docker-compose --version)"
}

# NVIDIA Docker Runtime 확인
check_nvidia_runtime() {
    if ! docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
        log_warning "NVIDIA Docker Runtime이 제대로 설정되지 않았습니다."
        log_warning "GPU 가속을 사용할 수 없을 수 있습니다."
    else
        log_info "NVIDIA Docker Runtime이 정상적으로 작동합니다."
    fi
}

# 환경 파일 설정
setup_env() {
    if [ ! -f .env ]; then
        log_info "환경 파일을 생성합니다..."
        cp config/env.example .env
        log_warning ".env 파일을 확인하고 필요한 설정을 수정하세요."
    else
        log_info "환경 파일이 이미 존재합니다."
    fi
}

# 이미지 빌드
build_image() {
    local service=$1
    local no_cache=$2
    
    log_info "$service 이미지 빌드를 시작합니다..."
    
    if [ "$no_cache" = true ]; then
        docker-compose build --no-cache $service
    else
        docker-compose build $service
    fi
    
    if [ $? -eq 0 ]; then
        log_info "$service 이미지 빌드가 완료되었습니다."
    else
        log_error "$service 이미지 빌드에 실패했습니다."
        exit 1
    fi
}

# 모든 이미지 빌드
build_all() {
    local no_cache=$1
    build_image "isaac-sim" $no_cache
    build_image "isaac-lab" $no_cache
}

# 이미지 정리
clean_images() {
    log_warning "기존 이미지를 제거합니다..."
    docker-compose down -v
    docker rmi isaac-sim:latest isaac-lab:latest 2>/dev/null || true
    log_info "이미지 정리가 완료되었습니다."
}

# 메인 함수
main() {
    local action=$1
    local no_cache=false
    
    # --no-cache 옵션 확인
    if [ "$2" = "--no-cache" ] || [ "$1" = "--no-cache" ]; then
        no_cache=true
        if [ "$1" = "--no-cache" ]; then
            action=$2
        fi
    fi
    
    # 기본 체크
    check_docker
    check_docker_compose
    check_nvidia_runtime
    setup_env
    
    # 액션 처리
    case $action in
        all)
            build_all $no_cache
            ;;
        isaac-sim)
            build_image "isaac-sim" $no_cache
            ;;
        isaac-lab)
            build_image "isaac-lab" $no_cache
            ;;
        clean)
            clean_images
            build_all false
            ;;
        help)
            usage
            ;;
        *)
            log_info "모든 이미지를 빌드합니다..."
            build_all $no_cache
            ;;
    esac
    
    log_info "빌드 프로세스가 완료되었습니다."
    log_info "다음 명령으로 컨테이너를 시작할 수 있습니다:"
    echo "  docker-compose up -d"
}

# 스크립트 실행
main "$@"