#!/bin/bash
source ./functions.sh
run_phoc
cd packages/ui && flutter-elinux run -d elinux-wayland
