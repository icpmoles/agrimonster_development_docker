#!/bin/bash

if [ -f "/opt/ros/$ROS_DISTRO/setup.bash" ]; then
    source "/opt/ros/$ROS_DISTRO/setup.bash"
fi

if [ -f "$COLCON_WS_PATH/install/setup.bash" ]; then
    source "$COLCON_WS_PATH/install/setup.bash"
fi
