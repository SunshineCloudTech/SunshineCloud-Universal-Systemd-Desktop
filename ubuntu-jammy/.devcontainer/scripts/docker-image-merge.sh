#!/bin/bash
export src_image_name=$1
export docker_tmp_name=temp1
docker create -it -P --name $docker_tmp_name $src_image_name
docker export $docker_tmp_name -o $docker_tmp_name.tar
docker rm $docker_tmp_name
docker rmi $src_image_name
docker import $docker_tmp_name.tar $src_image_name
rm $docker_tmp_name.tar