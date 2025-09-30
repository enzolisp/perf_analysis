#!/bin/bash

if [[ ! "$(groups)" == *"docker"* ]]; then
    sudo groupadd docker
    sudo usermod -aG docker ${USER}
    newgrp docker
fi

docker pull jupyter/scipy-notebook
docker run -d --rm -p 8888:8888 --name jupyter -v "${PWD}/src":/home/jovyan/work jupyter/scipy-notebook
(echo "CPU_PERC,MEM_USAGE,NET_IO,BLOCK_IO"; docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.BlockIO}}") > docker_metrics.csv
#sed 's/\[H|\[K|\[J//g' -nrw docker_metrics.csv 

