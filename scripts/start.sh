#!/bin/bash
# Isaac Docker 서비스 시작 스크립트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    echo "사용법: $0 [서비스]"
    echo "서비스:"
    echo "  all        - 모든 서비스 시작"
    echo "  isaac-sim  - Isaac Sim만 시작"
    echo "  isaac-lab  - Isaac Lab만 시작"
    echo "  jupyter    - Jupyter Lab만 시작"
    echo "  stop       - 모든 서비스 중지"
    echo "  restart    - 모든 서비스 재시작"
    echo "  status     - 서비스 상태 확인"
    echo "  logs       - 서비스 로그 확인"
    echo "  help       - 이 도움말 출력"
}

# X11 설정
setup_x11() {
    log_info "X11 디스플레이 설정..."
    xhost +local:docker 2>/dev/null || {
        log_warning "xhost 명령을 찾을 수 없습니다. GUI가 작동하지 않을 수 있습니다."
    }
}

# GPU 상태 확인
check_gpu() {
    log_info "GPU 상태 확인..."
    if nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader
    else
        log_warning "nvidia-smi를 찾을 수 없습니다. GPU 상태를 확인할 수 없습니다."
    fi
}

# 환경 파일 확인
check_env() {
    if [ ! -f .env ]; then
        log_error ".env 파일이 없습니다. 먼저 ./scripts/build.sh를 실행하세요."
        exit 1
    fi
}

# 서비스 시작
start_service() {
    local service=$1
    
    if [ "$service" = "all" ]; then
        log_info "모든 서비스를 시작합니다..."
        docker-compose up -d
    else
        log_info "$service 서비스를 시작합니다..."
        docker-compose up -d $service
    fi
    
    if [ $? -eq 0 ]; then
        log_info "서비스가 성공적으로 시작되었습니다."
        
        # Jupyter 서비스인 경우 URL 출력
        if [ "$service" = "jupyter" ] || [ "$service" = "all" ]; then
            echo ""
            log_info "Jupyter Lab URL: http://localhost:8888"
        fi
    else
        log_error "서비스 시작에 실패했습니다."
        exit 1
    fi
}

# 서비스 중지
stop_services() {
    log_info "모든 서비스를 중지합니다..."
    docker-compose down
    log_info "서비스가 중지되었습니다."
}

# 서비스 재시작
restart_services() {
    log_info "모든 서비스를 재시작합니다..."
    docker-compose restart
    log_info "서비스가 재시작되었습니다."
}

# 서비스 상태 확인
check_status() {
    log_info "서비스 상태:"
    docker-compose ps
}

# 로그 확인
show_logs() {
    local service=$2
    if [ -z "$service" ]; then
        docker-compose logs -f --tail=100
    else
        docker-compose logs -f --tail=100 $service
    fi
}

# 컨테이너 접속
enter_container() {
    local service=$1
    
    if [ -z "$service" ]; then
        log_error "서비스 이름을 지정하세요."
        echo "예: $0 enter isaac-sim"
        exit 1
    fi
    
    log_info "$service 컨테이너에 접속합니다..."
    docker-compose exec $service bash
}

# 메인 함수
main() {
    local action=$1
    
    # 기본 체크
    check_env
    
    # 액션 처리
    case $action in
        all)
            setup_x11
            check_gpu
            start_service "all"
            check_status
            ;;
        isaac-sim)
            setup_x11
            check_gpu
            start_service "isaac-sim"
            ;;
        isaac-lab)
            setup_x11
            check_gpu
            start_service "isaac-lab"
            ;;
        jupyter)
            start_service "jupyter"
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            check_status
            ;;
        status)
            check_status
            ;;
        logs)
            show_logs "$@"
            ;;
        enter)
            enter_container $2
            ;;
        help)
            usage
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

# 스크립트 실행
main "$@"