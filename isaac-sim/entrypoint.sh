#!/bin/bash

# Isaac Sim + Isaac Lab entrypoint script

echo "==================================="
echo "Isaac Sim Container Starting..."
echo "==================================="

# Isaac Lab 설치 (처음 한 번만)
if [ ! -f "/isaac-sim/.isaac_lab_installed" ]; then
    echo "Installing Isaac Lab..."
    cd /isaac-sim
    
    # Clone Isaac Lab if not exists
    if [ ! -d "IsaacLab" ]; then
        git clone https://github.com/isaac-sim/IsaacLab.git
    fi
    
    # Setup Isaac Lab
    cd IsaacLab
    ln -sf /isaac-sim _isaac_sim
    ./isaaclab.sh --install
    
    # Mark as installed
    touch /isaac-sim/.isaac_lab_installed
    echo "Isaac Lab installation completed!"
fi

# 환경 변수 설정
export ISAAC_SIM_PATH="/isaac-sim"
export ISAACSIM_PATH=$ISAAC_SIM_PATH
export ISAACSIM_PYTHON_EXE=$ISAAC_SIM_PATH/python.sh

echo ""
echo "==================================="
echo "Container Ready!"
echo "==================================="
echo ""
echo "To run Isaac Lab examples:"
echo "  cd /isaac-sim/IsaacLab"
echo "  ./isaaclab.sh -p scripts/tutorials/00_sim/create_empty.py"
echo ""
echo "To run your custom code from my-isaac-lab:"
echo "  cd /isaac-sim/IsaacLab"
echo "  ./isaaclab.sh -p /isaac-sim/my-isaac-lab/examples/simple_example.py"
echo ""

# Keep container running
exec "$@"