#!/bin/bash
# Isaac Lab Docker 엔트리포인트 스크립트

# 환경 변수 설정
export ACCEPT_EULA=${ACCEPT_EULA:-Y}
export ISAACSIM_PATH=${ISAACSIM_PATH:-/isaac-sim}
export ISAAC_LAB_PATH=${ISAAC_LAB_PATH:-/workspace/isaaclab}
export PYTHON_PATH=${PYTHON_PATH:-/isaac-sim/python.sh}

# NVIDIA 드라이버 확인
nvidia-smi

echo "=========================================="
echo "Isaac Lab Docker Container Started"
echo "=========================================="
echo "Isaac Sim Path: ${ISAACSIM_PATH}"
echo "Isaac Lab Path: ${ISAAC_LAB_PATH}"
echo "Python Path: ${PYTHON_PATH}"
echo "Workspace: /workspace"
echo "Data directory: /workspace/data"
echo "Logs directory: /workspace/logs"
echo "Experiments directory: /workspace/experiments"
echo "=========================================="

# Isaac Sim/Lab 라이선스 동의 확인
if [ "$ACCEPT_EULA" != "Y" ]; then
    echo "Error: EULA must be accepted by setting ACCEPT_EULA=Y"
    exit 1
fi

# Isaac Lab 환경 활성화
if [ -f "${ISAAC_LAB_PATH}/isaaclab.sh" ]; then
    source "${ISAAC_LAB_PATH}/isaaclab.sh"
fi

# 사용자 명령 실행
exec "$@"