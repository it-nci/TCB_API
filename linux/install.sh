#!/bin/bash

mkdir tcb-service

cd tcb-service

curl -O https://canceranywhere.com/caw-gateway-production/tcb-service-v2-linux.zip

unzip tcb-service-v2-linux.zip

sudo dnf install java-11-openjdk java-11-openjdk-devel -y

java --version