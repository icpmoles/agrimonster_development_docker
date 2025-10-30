#!/bin/bash

# original by Alessio Onori

CURRENT_DIR=$(dirname "$0")
cd $CURRENT_DIR 

# Set default model if not specified
MOSTRO_MODEL=${MOSTRO_MODEL:-mostro_v1}
echo "Using MOSTRO model: $MOSTRO_MODEL"

# recompilation
cd $COLCON_WS_PATH/LOTS-CORE && \
    mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc --ignore 1)

cd $COLCON_WS_PATH/fast_gicp && \
    mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_VGICP_CUDA=OFF .. && \
    make -j$(nproc --ignore 1)

cd $COLCON_WS_PATH/LOTS-LOCALIZATION && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j$(nproc --ignore 1)    

cd $COLCON_WS_PATH && source $COLCON_WS_PATH/scripts_common_ws/source_ws.sh && colcon build --parallel-workers $(nproc --ignore 1) --symlink-install --packages-skip fast_gicp micro_ros_agent livox_ros_driver2 
# cd $COLCON_WS_PATH && source $COLCON_WS_PATH/scripts_common_ws/source_ws.sh && colcon build --parallel-workers $(nproc --ignore 1) --symlink-install --packages-select localizer_wrapper

cd $COLCON_WS_PATH && source $COLCON_WS_PATH/install/setup.bash


#echo "start trace"
#mkdir '/home/ros2/.ros/log'
# developement_session_$START_TIME  developement_session_$START_TIME 
START_TIME=$(date '+%m_%d_%H_%M_%S')
export LOG_DIR=/home/ros2/ros_tracing/developement_session_$START_TIME
#export ROS_TRACE_DIR="/home/ros2/ros_tracing"
sudo mkdir $LOG_DIR
sudo chown ros2 $LOG_DIR
#ros2 trace start developement_session_$START_TIME -a && sleep 10

# Run commands in parallel, custom localizer
ros2 run performance_test perf_test --logfile $LOG_DIR/Relay.json --num-sub-threads 1 --num-pub-threads 1 --communicator rclcpp-single-threaded-executor --msg Array1k --roundtrip-mode Relay &
ros2 launch localizer_wrapper artslam_localizer.py model:=$MOSTRO_MODEL & # localization
ros2 launch mostro_sim launch_sim.py model:=$MOSTRO_MODEL &  wait 

# ros2 launch mostro_sim perimeter_recorder.py & # to record a perimeter
# ros2 launch mostro_sim trajectory_follower.py & # to start a trajectory follow mission

# Wait for both background processes to comple

# (sleep 20 && ros2 trace stop developement_session_$START_TIME && wait)

#echo "End of Developement" & 
#wait


