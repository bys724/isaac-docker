#!/bin/bash
# Isaac Lab Docker Entrypoint (Production Image)
# This is a minimal entrypoint for the pre-built image

# Set environment variables
export ACCEPT_EULA=${ACCEPT_EULA:-Y}
export PRIVACY_CONSENT=${PRIVACY_CONSENT:-Y}
export ISAACSIM_PATH=${ISAACSIM_PATH:-/isaac-sim}
export ISAAC_LAB_PATH=${ISAAC_LAB_PATH:-/isaac-sim/IsaacLab}

# Set library paths
export LD_LIBRARY_PATH=/isaac-sim/kit/python/lib:/isaac-sim/exts/omni.isaac.core/bin:$LD_LIBRARY_PATH
export PATH=/isaac-sim/kit/python/bin:$PATH

# Display startup information
echo "=========================================="
echo "Isaac Lab Docker Container"
echo "=========================================="
echo "Isaac Sim Version: 5.0.0"
echo "Isaac Lab: Pre-installed"
echo "Working Directory: $(pwd)"
echo "=========================================="

# Check GPU
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader || echo "Warning: GPU not detected"

# Quick verification
if [ -f "/isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3" ]; then
    /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -c "import isaaclab" 2>/dev/null && \
        echo "✓ Isaac Lab module ready" || \
        echo "⚠ Isaac Lab module not found (may need reinstall)"
fi

# Set Python aliases
alias python="/isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3"
alias pip="/isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip"

# Execute user command
exec "$@"