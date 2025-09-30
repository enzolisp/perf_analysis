#!/bin/bash

if [[ ! "$(groups)" == *"docker"* ]]; then
    sudo groupadd dockerd
    sudo usermod -aG docker ${USER}
    newgrp docker
fi

#docker pull jupyter/scipy-notebook
#docker run --rm -p 8888:8888 --name jupyter -v "${PWD}/src":/home/jovyan/work jupyter/scipy-notebook
#docker stats jupyter

