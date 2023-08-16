#!/bin/bash

set_hostname() {
    # Set hostname to current system hostname
    if [[ -z ${HOSTNAME} ]]; then
        export HOSTNAME="localhost"
    else
        echo "HOSTNAME is set: $HOSTNAME"
        export HOSTNAME
    fi

    FILE=config/ros2/${HOSTNAME}.env
    if [ -f "$FILE" ]; then
        echo "Environment Config file exists: $FILE"
    else
        echo "Environment Config file NOT FOUND: $FILE"
        if   [[ $HOSTNAME == localhost ]]; then
            echo "Exiting"
            exit
        else
            export HOSTNAME="localhost"
            FILE=config/ros2/${HOSTNAME}.env
            echo "Trying default env file: $FILE"
            if [ -f "$FILE" ]; then
                echo "Environment Config file exists: $FILE"
            else
                echo "Environment Config file NOT FOUND: $FILE"
                if   [[ $HOSTNAME == localhost ]]; then
                    echo "Exiting"
                    exit
                fi
            fi
        fi

    fi

}

start_module() {
    # Enable GUI passthorugh
    xhost +

    # Set hostname to current system hostname
    set_hostname

    # Start docker container
    docker compose -f docker-compose-ros2-humble-dev.yaml up -d 
    # docker compose -f docker-compose-ros2-humble-dev.yaml up -d rosmaster &
    # docker compose -f docker-compose-ros2-humble-dev.yaml up -d ros-dev &

}

stop_module() {
    # Set hostname to current system hostname
    set_hostname

    # Build docker container
    docker compose -f docker-compose-ros2-humble-dev.yaml pull 
    docker compose -f docker-compose-ros2-humble-dev.yaml down 
}

restart_module() {
      stop_module
      sleep 5
      start_module
}

build_module() {
    # Set hostname to current system hostname
    set_hostname

    # Start docker container
    docker compose -f docker-compose-ros2-humble-dev.yaml build 
}

usage_message() {

    # Define a file path
    filepath=$0
    
    # Extract the filename and extension from the file path
    filename=$(basename "$filepath")
    echo "Usage: $filename start | stop | restart | build "
}

if [ $# != 1 ]; then                # If Argument is not exactly one
    usage_message

    exit 1                         # Exit the program
fi


ARGUMENT=$(echo "$1" | awk '{print tolower($0)}')     # Converts Argument in lower case. This is to make user Argument case independent. 

if   [[ $ARGUMENT == start ]]; then

    start_module

elif [[ $ARGUMENT == stop ]]; then

    stop_module

elif [[ $ARGUMENT == build ]]; then

    build_module

elif [[ $ARGUMENT == restart ]]; then

    restart_module

else 
    usage_message
fi
