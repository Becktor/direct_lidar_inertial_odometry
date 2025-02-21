# Use official ROS 2 Jazzy image as the base
FROM ros:humble-perception

ARG PACKAGE_NAME=dlio

# Set non-interactive frontend to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Tweak APT configuration
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    # Don't install recommended pkgs
    echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
    /etc/apt/apt.conf.d/01norecommend \
    # Assume `-y`
    && echo 'APT::Get::Assume-Yes "true";' > \
    /etc/apt/apt.conf.d/02assumeyes \
    # Keep APT package cache
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/03keep-cache \
    && echo 'APT::Clean-Installed "false";' \
    > /etc/apt/apt.conf.d/04clean-installed-off \
    && rm -f /etc/apt/apt.conf.d/docker-clean

# Add string to shell prompt to help identify Docker container shells
RUN echo ${PACKAGE_NAME} > /etc/debian_chroot
# Install additional build tools and dependencies
RUN apt-get update && apt-get install -y \
    git \
    vim \
    htop \
    tmux \
    tmuxp \
    python3-colcon-common-extensions \
    python3-colcon-clean \
    python3-rosdep \
    python3-vcstool \
    ros-humble-rviz2 \
    ros-humble-rqt* \
    && rm -rf /var/lib/apt/lists/*

# Ensure rosdep is initialized (should already be in the base image, but just in case)
RUN rosdep update

# Set up workspace
WORKDIR /naisr2_ws
RUN mkdir -p /naisr2_ws/src

# Copy the DLIO repo from the parent folder (build context) into the workspace
COPY . /naisr2_ws/src/direct_lidar_inertial_odometry

# Install ROS dependencies with APT cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    /bin/bash -c "source /opt/ros/humble/setup.bash && \
    rosdep install --from-paths src --ignore-src -r -y"

# Build the workspace with colcon cache
RUN --mount=type=cache,target=/naisr2_ws/build,sharing=locked \
    /bin/bash -c "source /opt/ros/humble/setup.bash && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo"

# clear the workspace since we will mount it as a volume
RUN rm -rf /naisr2_ws/src/direct_lidar_inertial_odometry
RUN echo "rosdep install --from-paths src --ignore-src -r -y" >> /naisr2_ws/rosdep_install.sh
RUN echo "colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo" >> /naisr2_ws/build_ws.sh

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ARG USERNAME=naisr
RUN groupadd ${USERNAME} && \
    useradd -m -g ${USERNAME} -s /bin/bash ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# Copy and set the entrypoint from the dlio-docker subdirectory
COPY humble-docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER ${USERNAME}
RUN echo "source /opt/ros/humble/setup.bash" >> /home/${USERNAME}/.bashrc
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]