# original by Alessio Onori

FROM ubuntu:24.04

ENV ROS_DISTRO=jazzy

# Not really configurable, everything is hardcoded so that the ws path is /home/ros2/tesi/mostro
ARG USERNAME=ros2 
ENV COLCON_WS_PATH=/home/$USERNAME/tesi/mostro

ARG USER_UID=1000
ARG USER_GID=1000

RUN userdel -r ubuntu

RUN if ! id -u $USER_UID >/dev/null 2>&1; then \
        groupadd --gid $USER_GID $USERNAME && \
        useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME; \
    fi

# Add sudo support for the non-root user
RUN apt-get update && \
    apt-get install -y sudo && \
    echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    rm -rf /var/lib/apt/lists/*

# Add user to video group to allow access to webcam and serial interfaces
RUN usermod -aG video,dialout $USERNAME

# Install Git
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

###### Install ROS 2 as per https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html ###
RUN apt update && apt install locales -y
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8

RUN apt update && apt install -y software-properties-common
RUN add-apt-repository universe

RUN apt update && apt install curl -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt-get update && apt-get install -y \
    ros-dev-tools \
    ros-${ROS_DISTRO}-desktop \
    ros-${ROS_DISTRO}-ros-base \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init
####################################################################

# Not necessary
# RUN rosdep update

################################
## ADD ANY CUSTOM SETUP BELOW ##
################################

# Install useful tools
RUN apt-get update && \
    apt-get install -y \
    nano \
    xterm \
    gdb \
    wget \
    telnet \
    curl \ 
    tmux \
    iputils-ping \
    pcl-tools  && \
    rm -rf /var/lib/apt/lists/*

# Install navigation stack packages and other ros packages
RUN apt-get update && \
    apt-get install -y \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-util \
    ros-${ROS_DISTRO}-nav2-core \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-nav2-graceful-controller \
    ros-${ROS_DISTRO}-nav2-route  \
    ros-${ROS_DISTRO}-ros2-control  \
    ros-${ROS_DISTRO}-ros2-controllers \
    ros-${ROS_DISTRO}-libg2o \
    ros-${ROS_DISTRO}-gtsam \
    ros-${ROS_DISTRO}-pcl-ros \
    ros-${ROS_DISTRO}-robot-localization \
    ros-${ROS_DISTRO}-opennav-docking \
    ros-${ROS_DISTRO}-opennav-docking-core \
    ros-${ROS_DISTRO}-image-pipeline \
    ros-${ROS_DISTRO}-ros-gz && \
    rm -rf /var/lib/apt/lists/*

# GUI
RUN apt-get update && \
    apt-get install -y \
    xauth \
    x11-apps \
    mesa-utils \
    kmod && \
    rm -rf /var/lib/apt/lists/*    

################################
## Building the Workspace ##
################################

COPY --chown=$USERNAME ./docker/common/scripts_ws $COLCON_WS_PATH/scripts_common_ws
COPY --chown=$USERNAME ./docker/simulation/scripts_ws $COLCON_WS_PATH/scripts_ws

# Automatic sourcing for system-wide login shells, system-wide non-login interactive shells, and the user-specific non-login interactive shells. Only dockerfile shells are left outside (non login, non interactive)
RUN cat $COLCON_WS_PATH/scripts_common_ws/source_ws.sh | tee -a /etc/bash.bashrc /etc/profile /home/$USERNAME/.bashrc
# Fix for Dockerfile shells (non login, non interactive)
SHELL ["/bin/bash", "-c"]
ENV BASH_ENV=$COLCON_WS_PATH/scripts_common_ws/source_ws.sh

USER $USERNAME
WORKDIR $COLCON_WS_PATH

RUN sudo apt-get -y install ros-${ROS_DISTRO}-libg2o ros-${ROS_DISTRO}-gtsam ros-${ROS_DISTRO}-pcl-ros

# Set environment variables for CMake
ENV CMAKE_PREFIX_PATH=/opt/ros/${ROS_DISTRO}:$CMAKE_PREFIX_PATH
ENV CMAKE_LIBRARY_PATH=/opt/ros/${ROS_DISTRO}/lib/aarch64-linux-gnu:$CMAKE_LIBRARY_PATH
ENV CMAKE_INCLUDE_PATH=/opt/ros/${ROS_DISTRO}/include:$CMAKE_INCLUDE_PATH

COPY --chown=$USERNAME additional-modules/LOTS-CORE $COLCON_WS_PATH/LOTS-CORE
RUN cd $COLCON_WS_PATH/LOTS-CORE && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc)

COPY --chown=$USERNAME additional-modules/fast_gicp $COLCON_WS_PATH/fast_gicp
RUN cd $COLCON_WS_PATH/fast_gicp && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_VGICP_CUDA=OFF .. && \
    make -j$(nproc)

COPY --chown=$USERNAME additional-modules/LOTS-LOCALIZATION $COLCON_WS_PATH/LOTS-LOCALIZATION
RUN cd $COLCON_WS_PATH/LOTS-LOCALIZATION && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc)

COPY --chown=$USERNAME src $COLCON_WS_PATH/src

RUN source $COLCON_WS_PATH/scripts_common_ws/source_ws.sh && colcon build --parallel-workers $(nproc) --symlink-install --packages-skip fast_gicp micro_ros_agent livox_ros_driver2

CMD [ "bash" ]