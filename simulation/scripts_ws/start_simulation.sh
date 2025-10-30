#!/bin/bash

# original by Alessio Onori

CURRENT_DIR=$(dirname "$0")
cd $CURRENT_DIR 

# Set default model if not specified
MOSTRO_MODEL=${MOSTRO_MODEL:-mostro_v1}
echo "Using MOSTRO model: $MOSTRO_MODEL"

# Optional recompilation
cd ..
source $COLCON_WS_PATH/scripts_common_ws/source_ws.sh && colcon build --symlink-install --packages-skip fast_gicp micro_ros_agent livox_ros_driver2

# Run commands in parallel, custom localizer
# ros2 launch localization_proc_filter processing_filter.py & # optional, mapping
ros2 launch localizer_wrapper artslam_localizer.py model:=$MOSTRO_MODEL & # localization
ros2 launch mostro_sim launch_sim.py model:=$MOSTRO_MODEL &

# Wait for both background processes to complete
wait