#!/bin/bash
source ./functions.sh
(cd packages/ui && flutter-elinux build elinux --target-backend-type wayland --release)
run_phoc -E "./packages/ui/build/elinux/x64/release/bundle/flutter_mobile_ui"
sleep infinity
