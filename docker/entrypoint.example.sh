#!/bin/bash
# Example Entrypoint for Projects Using Isaac Lab Docker
# Copy and customize this file for your specific project needs

# Inherit base environment from Isaac Lab image
export ACCEPT_EULA=${ACCEPT_EULA:-Y}
export PRIVACY_CONSENT=${PRIVACY_CONSENT:-Y}
export ISAACSIM_PATH=${ISAACSIM_PATH:-/isaac-sim}
export ISAAC_LAB_PATH=${ISAAC_LAB_PATH:-/isaac-sim/IsaacLab}

# Set library paths
export LD_LIBRARY_PATH=/isaac-sim/kit/python/lib:/isaac-sim/exts/omni.isaac.core/bin:$LD_LIBRARY_PATH
export PATH=/isaac-sim/kit/python/bin:$PATH

# Project-specific environment variables
export PROJECT_NAME=${PROJECT_NAME:-"my_robot_project"}
export WORKSPACE_DIR=${WORKSPACE_DIR:-"/workspace"}

echo "=========================================="
echo "Isaac Lab Container - ${PROJECT_NAME}"
echo "=========================================="
echo "Workspace: ${WORKSPACE_DIR}"
echo "=========================================="

# Check for project requirements and install if present
if [ -f "${WORKSPACE_DIR}/requirements.txt" ]; then
    echo "Installing project dependencies..."
    /isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip install -r ${WORKSPACE_DIR}/requirements.txt
fi

# Check for custom Isaac Lab extensions
if [ -d "${WORKSPACE_DIR}/isaaclab_extensions" ]; then
    echo "Found custom Isaac Lab extensions"
    # Add your extension installation logic here
fi

# Initialize project-specific configurations
if [ -f "${WORKSPACE_DIR}/scripts/init.sh" ]; then
    echo "Running project initialization..."
    source ${WORKSPACE_DIR}/scripts/init.sh
fi

# Set Python aliases
alias python="/isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3"
alias pip="/isaac-sim/IsaacLab/_isaac_sim/kit/python/bin/python3 -m pip"

# Custom aliases for your project
alias train="python ${WORKSPACE_DIR}/scripts/train.py"
alias eval="python ${WORKSPACE_DIR}/scripts/evaluate.py"
alias demo="python ${WORKSPACE_DIR}/scripts/demo.py"

# Display help message
echo ""
echo "Available commands:"
echo "  train  - Start training"
echo "  eval   - Evaluate model"
echo "  demo   - Run demonstration"
echo "=========================================="

# Change to workspace directory
cd ${WORKSPACE_DIR}

# Execute user command
exec "$@"