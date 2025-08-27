#!/bin/bash
# Isaac Sim Docker 엔트리포인트 스크립트

# 환경 변수 설정
export ACCEPT_EULA=${ACCEPT_EULA:-Y}
export OMNI_SERVER=${OMNI_SERVER:-localhost}
export OMNI_PORT=${OMNI_PORT:-8899}

# NVIDIA 드라이버 확인
nvidia-smi

echo "=========================================="
echo "Isaac Sim Docker Container Started"
echo "=========================================="
echo "Workspace: /workspace"
echo "Data directory: /workspace/data"
echo "Logs directory: /workspace/logs"
echo "=========================================="

# Isaac Sim 라이선스 동의 확인
if [ "$ACCEPT_EULA" != "Y" ]; then
    echo "Error: EULA must be accepted by setting ACCEPT_EULA=Y"
    exit 1
fi

# 사용자 명령 실행
exec "$@"