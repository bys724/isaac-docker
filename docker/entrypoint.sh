#!/bin/bash
# Isaac Lab Docker 엔트리포인트 스크립트

# 환경 변수 설정
export ACCEPT_EULA=${ACCEPT_EULA:-Y}
export PRIVACY_CONSENT=${PRIVACY_CONSENT:-Y}
export ISAACSIM_PATH=${ISAACSIM_PATH:-/isaac-sim}
export ISAAC_LAB_PATH=${ISAAC_LAB_PATH:-/isaac-sim/IsaacLab}
export ISAACSIM_PYTHON_EXE=${ISAACSIM_PYTHON_EXE:-/isaac-sim/python.sh}

# 라이브러리 경로 수정 (pinocchio 충돌 해결)
export LD_LIBRARY_PATH=/isaac-sim/kit/python/lib:/isaac-sim/exts/omni.isaac.core/bin:$LD_LIBRARY_PATH

# NVIDIA 드라이버 확인
echo "=========================================="
echo "Checking NVIDIA GPU..."
echo "=========================================="
nvidia-smi

echo "=========================================="
echo "Isaac Sim Container Starting..."
echo "=========================================="
echo "Isaac Sim Version: 5.0.0"
echo "Isaac Sim Path: ${ISAACSIM_PATH}"
echo "Isaac Lab Path: ${ISAAC_LAB_PATH}"
echo "Python Executable: ${ISAACSIM_PYTHON_EXE}"
echo "=========================================="

# Isaac Sim/Lab 라이선스 동의 확인
if [ "$ACCEPT_EULA" != "Y" ]; then
    echo "Error: EULA must be accepted by setting ACCEPT_EULA=Y"
    exit 1
fi

if [ "$PRIVACY_CONSENT" != "Y" ]; then
    echo "Error: Privacy consent must be accepted by setting PRIVACY_CONSENT=Y"
    exit 1
fi

# Isaac Lab 설치 확인 및 설정
if [ -d "/isaac-sim/IsaacLab" ]; then
    echo "=========================================="
    echo "Isaac Lab detected at ${ISAAC_LAB_PATH}"
    echo "=========================================="
    
    cd ${ISAAC_LAB_PATH}
    
    # Force reinstall if FORCE_REINSTALL is set
    if [ "$FORCE_REINSTALL" = "1" ] && [ -f "${ISAAC_LAB_PATH}/.isaac_lab_installed" ]; then
        echo "Force reinstall requested, removing installation marker..."
        rm -f ${ISAAC_LAB_PATH}/.isaac_lab_installed
    fi
    
    # Check if Isaac Lab needs to be installed
    if [ ! -f "${ISAAC_LAB_PATH}/.isaac_lab_installed" ]; then
        echo "=========================================="
        echo "Installing Isaac Lab..."
        echo "=========================================="
        
        # Install Isaac Lab extensions (공식 문서 방법)
        echo "Installing Isaac Lab extensions..."
        ./isaaclab.sh --install
        
        # Upgrade pip as recommended
        echo "Upgrading pip..."
        /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip install --upgrade pip
        
        # Install additional Python packages for RL
        echo "Installing additional Python packages for RL..."
        
# Install RL libraries (Isaac Lab Python 환경 사용)
        echo "Installing RL libraries..."
        /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip install rl-games
        /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip install stable-baselines3
        /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip install "skrl[torch]"
        
        # Fix pinocchio if needed (optional)
        # echo "Attempting to fix pinocchio..."
        # /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip uninstall -y pinocchio
        # /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip install pin==2.7.1
        
        # Mark as installed
        touch ${ISAAC_LAB_PATH}/.isaac_lab_installed
        echo "Isaac Lab installation completed!"
        
        # Verify installation
        echo ""
        echo "Verifying installation..."
        /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -c "import isaaclab; print('Isaac Lab imported successfully')" || echo "Warning: Isaac Lab import test failed"
    else
        echo "Isaac Lab is already installed."
    fi
else
    echo "=========================================="
    echo "WARNING: Isaac Lab not found at ${ISAAC_LAB_PATH}"
    echo "Please mount the Isaac Lab directory as a volume."
    echo "=========================================="
fi

# Python 경로 설정 및 별칭 생성
alias python="${ISAACSIM_PYTHON_EXE}"
alias pip="${ISAACSIM_PYTHON_EXE} -m pip"

# 도움말 메시지
echo ""
echo "=========================================="
echo "Container Ready!"
echo "=========================================="
echo ""

if [ -d "/isaac-sim/IsaacLab" ]; then
    echo "Isaac Lab 사용 예제:"
    echo ""
    echo "1. 빈 시뮬레이션 생성:"
    echo "   cd /isaac-sim/IsaacLab"
    echo "   ./isaaclab.sh -p scripts/tutorials/00_sim/create_empty.py"
    echo ""
    echo "2. Cartpole 환경 (가벼운 테스트):"
    echo "   ./isaaclab.sh -p scripts/tutorials/03_envs/run_cartpole_rl_env.py"
    echo ""
    echo "3. 강화학습 훈련 (RL Games):"
    echo "   ./isaaclab.sh -p scripts/reinforcement_learning/rl_games/train.py \\"
    echo "     --task Isaac-Cartpole-v0 --num_envs 16"
    echo ""
    echo "4. 랜덤 에이전트 테스트:"
    echo "   ./isaaclab.sh -p scripts/environments/random_agent.py \\"
    echo "     --task Isaac-Cartpole-v0 --num_envs 4"
    echo ""
    echo "5. 데모 실행 (로봇 시각화):"
    echo "   ./isaaclab.sh -p scripts/demos/quadrupeds.py"
fi

echo "=========================================="
echo ""

# Isaac Lab 디렉토리로 자동 이동 (있는 경우)
if [ -d "/isaac-sim/IsaacLab" ]; then
    cd /isaac-sim/IsaacLab
    echo "Current directory: $(pwd)"
fi

# 사용자 명령 실행
exec "$@"