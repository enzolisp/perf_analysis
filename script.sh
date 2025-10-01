#!/bin/bash

# sampling rate (seconds)
SAMPLING=1
csv_name=`date +"%d_%m_%Y-%H:%M:%S.csv"`

if [[ ! "$(groups)" == *"docker"* ]]; then
    sudo groupadd docker
    sudo usermod -aG docker ${USER}
    newgrp docker
fi

docker pull jupyter/scipy-notebook
docker run -d --rm -p 8888:8888 --name jupyter -v "${PWD}/src":/home/jovyan/work jupyter/scipy-notebook
while true; do docker stats --no-stream >> ./experiments-csv/$csv_name; sleep $SAMPLING; done
#(echo "CPU_PERC,MEM_USAGE,NET_IO,BLOCK_IO"; watch -n 1 docker stats --no-stream --format "{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.BlockIO}}\n") >> docker_metrics/docker_metrics.csv
#sed 's/\[H|\[K|\[J//g' -nrw docker_metrics.csv 
docker stop jupyter
