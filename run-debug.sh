#!/bin/bash
source ./functions.sh
run_phoc
cd ui && flutter-elinux run -d elinux-wayland
