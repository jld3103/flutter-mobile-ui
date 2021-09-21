#!/bin/bash
source ./functions.sh
(cd ui && flutter-elinux build elinux --target-backend-type wayland --release)
run_phoc -E "./ui/build/elinux/x64/release/bundle/flutter_mobile_ui"
sleep infinity
