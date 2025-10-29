FROM ubuntu:noble
ENV ROS_DISTRO=jazzy
ARG USERNAME=ros2
ENV COLCON_WS_PATH=/home/ros2/tesi/mostro
ARG USER_UID=1000
ARG USER_GID=1000

RUN userdel -r ubuntu 
# Ensure user exists with correct UID/GID
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

RUN usermod -aG video,dialout $USERNAME 

RUN apt-get update &&     apt-get install -y git &&     rm -rf /var/lib/apt/lists/* 


RUN apt update && apt install locales -y 


RUN locale-gen en_US en_US.UTF-8 

RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 


ENV LANG=en_US.UTF-8

RUN apt update && apt install -y software-properties-common 

RUN add-apt-repository universe 

RUN apt update && apt install curl -y 

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg 

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null 

RUN apt-get update && apt-get install -y     ros-dev-tools     ros-${ROS_DISTRO}-desktop     ros-${ROS_DISTRO}-ros-base     && rm -rf /var/lib/apt/lists/* 

RUN rosdep init 

RUN apt-get update &&     apt-get install -y     nano     xterm     gdb     wget     telnet     curl     tmux     iputils-ping     pcl-tools  &&     rm -rf /var/lib/apt/lists/* 

RUN apt-get update &&     apt-get install -y     ros-${ROS_DISTRO}-navigation2     ros-${ROS_DISTRO}-nav2-util     ros-${ROS_DISTRO}-nav2-core     ros-${ROS_DISTRO}-nav2-bringup     ros-${ROS_DISTRO}-nav2-graceful-controller     ros-${ROS_DISTRO}-ros2-control      ros-${ROS_DISTRO}-ros2-controllers     ros-${ROS_DISTRO}-libg2o     ros-${ROS_DISTRO}-gtsam     ros-${ROS_DISTRO}-pcl-ros     ros-${ROS_DISTRO}-robot-localization     ros-${ROS_DISTRO}-opennav-docking     ros-${ROS_DISTRO}-opennav-docking-core     ros-${ROS_DISTRO}-image-pipeline     ros-${ROS_DISTRO}-ros-gz &&     rm -rf /var/lib/apt/lists/* 

RUN apt-get update &&     apt-get install -y     xauth     x11-apps     mesa-utils     kmod &&     rm -rf /var/lib/apt/lists/* 

COPY --chown=ros2 ./common/scripts_ws /home/ros2/tesi/mostro/scripts_common_ws 

COPY --chown=ros2 ./development/scripts_ws /home/ros2/tesi/mostro/scripts_ws 

RUN cat $COLCON_WS_PATH/scripts_common_ws/source_ws.sh | tee -a /etc/bash.bashrc /etc/profile /home/$USERNAME/.bashrc 

SHELL ["/bin/bash", "-c"]

ENV BASH_ENV=/home/ros2/tesi/mostro/scripts_common_ws/source_ws.sh

USER ros2

WORKDIR /home/ros2/tesi/mostro

RUN  sudo apt-get -y install ros-${ROS_DISTRO}-libg2o ros-${ROS_DISTRO}-gtsam ros-${ROS_DISTRO}-pcl-ros 

ENV CMAKE_PREFIX_PATH=/opt/ros/jazzy:

ENV CMAKE_LIBRARY_PATH=/opt/ros/jazzy/lib/aarch64-linux-gnu:

ENV CMAKE_INCLUDE_PATH=/opt/ros/jazzy/include:

CMD ["bash"]