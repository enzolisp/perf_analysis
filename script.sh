#!/bin/bash

# sudo groupadd dockerd
# sudo usermod -aG docker ${USER}
# newgrp docker

docker pull jupyter/scipy-notebook
docker run --rm -p 8888:8888 --name jupyter -v "${PWD}/src":/home/jovyan/work jupyter/scipy-notebook
#docker stats jupyter

