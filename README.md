# ROS 2 Docker Development Environment

This repository provides a step-by-step guide to set up a ROS 2 development environment within a Docker container on your local computer. Using Docker ensures a consistent and isolated environment for your ROS 2 projects, and integrating it with Visual Studio Code (VSCode) enhances your development experience.

## Prerequisites

Before you begin, make sure you have the following prerequisites:

1. **OS:** Ubuntu is recommended).
2. **Docker** installed on your system. Installation instructions on the official website: [Install Docker](https://docs.docker.com/get-docker/).
3. **VSCode** installed on your system. Installation instructions on the official website:  [Install VSCode](https://code.visualstudio.com/Download)

## Steps

Follow these steps to set up the ROS 2 development environment:

### 1. Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/niladut/ros2-docker-workspace.git
cd ros2-docker-workspace
```

### 2. Docker Compose Configuration
The Docker Compose configuration  file `docker-compose-ros2-humble-dev.yml` creates a ROS 2 development environment in a Docker container with network and device access, allowing for efficient development and debugging.

`docker-compose-ros2-humble-dev.yml` :

```yaml
version: "3.7"

x-env-file-common-variables: &env_file
    config/ros2/${HOSTNAME}.env

services:

  ros2-dev:
    container_name: ros2-dev
    image: ros2-dev:nvidia-humble
    network_mode: host
    ipc: host # TODO: Investigate  issue
    build:
      context: .
      dockerfile: Dockerfile.nvidia-ros2-humble
      network: host
    environment:
      - "DISPLAY"
      - "NVIDIA_VISIBLE_DEVICES=all"
      - "NVIDIA_DRIVER_CAPABILITIES=all"
      # - "ROS_DOMAIN_ID=25" # Optional: to choose ROS domain
      # - "ROS_LOCALHOST_ONLY=0" # Optional: set to 1 if you want to present network communication
    env_file: *env_file
    privileged: true
    restart: unless-stopped
    # command: bash -c "sleep 3; source "
    command: tail -f /dev/null
    volumes:
      - type: bind
        source: /dev
        target: /dev
      - $HOME/logs/docker/ros2:/root/.ros/
      - $HOME/user/ros2_ws:/root/ros2_ws
      - $HOME/user/docker_ws:/root/docker_ws
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
      - $HOME/.Xauthority:/root/.Xauthority:rw
      - /var/run/dbus:/var/run/dbus
      - $HOME/.ssh:/root/.ssh
```


#### 2.1 Sharing Folders with the Docker container
Sharing the access to folders on the host system to the docker container can be done by binding the paths for these folders with a path inside the docker container. This is done by configuring the `volumes` section of the docker container service:
```yaml
volumes:
- type: bind
source: /dev
target: /dev
- $HOME/logs/docker/ros2:/root/.ros/
- $HOME/user/ros2_ws:/root/ros2_ws
- $HOME/user/docker_ws:/root/docker_ws
- /tmp/.X11-unix:/tmp/.X11-unix:rw
- $HOME/.Xauthority:/root/.Xauthority:rw
- /var/run/dbus:/var/run/dbus
- $HOME/.ssh:/root/.ssh
```
The configuration assumes certain directory structures (`$HOME/logs/docker/ros2`, `$HOME/user/ros2_ws`, etc.). You can add your custom folder paths in by adding a new entry under the `volumes` section:
```yaml
volumes:
.
.
.
      - <absolute-path-to-directory-on-host>:<absolute-path-to-directory-in-docker-container>
```
This configuration sets up a service named `ros2_container` using the Docker image built from the provided `Dockerfile`. It also mounts a local `workspace` directory into the container, allowing file sharing between the host and the container.


#### 2.2 Environment Variable Configuration
The project defines the system and ROS environemnt variables required in the docker container in the following sections:
- `environment` : Sets environment variables for the container, including "DISPLAY", "NVIDIA_VISIBLE_DEVICES", and "NVIDIA_DRIVER_CAPABILITIES".
- `env_file`: Loads environment variables from the common environment file `config/ros2/${HOSTNAME}.env`.

To create a custom environment variable configuration file for the current host system with (`$HOSTNAME`), make a duplicate of the default environment configuration file (`config/ros2/localhost.env`) and place it at `config/ros2/${HOSTNAME}.env`. 

For example, if the system hostname is `mypc`, then follow the following commands:
```bash
cd config/ros2/
cp localhost.env mypc.env
```

The environment variable `${HOSTNAME}` is usually set to the hostname of the current system (in Ubuntu). If it is not defined, and if the current system hostname is `mypc`, it can define by:
```bash
export HOSTNAME=mypc
```

### 3. Using the Bash Script

The provided Bash script simplifies the management of your ROS 2 Docker development environment. It offers commands to start, stop, restart, or build the environment using Docker Compose. Here's how to use the script:

#### 3.1. Setting Up Environment Variables:
    
The script uses an environment configuration file located in `config/ros2/${HOSTNAME}.env` to set up environment variables. You can create this file and define environment variables as needed for your ROS 2 environment. 
    
#### 3.2. Understanding the Commands:
    
The script supports the following commands:

- `start`: Starts the ROS 2 Docker environment by executing the specified Docker Compose file.
- `stop`: Stops and removes the Docker containers defined in the Docker Compose file.
- `restart`: Stops, rebuilds, and restarts the Docker containers.
- `build`: Builds the Docker containers defined in the Docker Compose file.
#### 3.3. Running the Script:
    
Open a terminal and navigate to the directory where the script is located. Then, use the following syntax to execute the script with a specific command:

```bash
./ros2_docker.sh command

```

Replace `command` with one of the commands mentioned above (e.g., `start`, `stop`, `restart`, `build`).

**Example:**

To start the ROS 2 Docker environment, execute:

```bash
./ros2_docker.sh start
```

To stop the environment, execute:

```bash
./ros2_docker.sh stop
```

To rebuild and restart the environment, execute:

```bash
./ros2_docker_script.sh restart
```

To build the Docker containers, execute:

```bash
./ros2_docker_script.sh build
```

If you're unsure about the available commands, running the script without any arguments will display a usage message:

```bash
./ros2_docker_script.sh
```

This will provide information about using the script and the available commands.

The provided script helps you manage your ROS 2 Docker development environment with ease, automating various Docker-related tasks and allowing you to focus on your robotics projects.



### 4. Set Up Development Environment with VSCode

1. Install the "Remote - Containers" extension for VSCode.
2. Open your project directory in VSCode.
3. Press `Ctrl` + `Shift` + `P` (or `Cmd` + `Shift` + `P` on macOS), type "Remote-Containers: Open Folder in Container," and select the project folder.

VSCode will start the container and open a new window within it, providing a seamless development environment.
For more information the use of this plugin: [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers) 


## Feedback

Feel free to explore advanced features like hardware device access, using ROS packages, and further customization within the Docker environment.
Also feel free to suggest improvements and features.

## Author

This ROS 2 Docker Workspace guide was authored by [niladut](https://github.com/niladut).

Happy coding! 🤖🐍🐬