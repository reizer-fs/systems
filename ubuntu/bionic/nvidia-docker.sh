#!/bin/bash


# Add Nvidia repository for bionic
if [ ! -f /etc/apt/sources.list.d/nvidia-docker.list ]; then
	curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey |  sudo apt-key add -
	distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
	curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
	sudo apt-get update

else
	echo "[info]: Nvidia repository already configured.\n"
fi

# get docker ce version
version=`/usr/bin/docker -v |awk '{print $3}'| sed -e 's/-.*$//g'`
version_nvidia=`apt-cache madison nvidia-docker2 | grep $version | cut -d" " -f3`
sudo apt-get install nvidia-docker2=$version_nvidia
sudo pkill -SIGHUP dockerd

#Example of image
docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
docker run --rm --runtime=nvidia nvidia/cuda:9.0-devel nvcc --version

docker run --runtime=nvidia --rm -ti -v "${PWD}:/app" python /app/benchmark.py cpu 10000
