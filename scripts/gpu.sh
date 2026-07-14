#!/usr/bin/env bash
# AMD GPU load via sysfs (works for amdgpu cards).
# Takes the first card exposing gpu_busy_percent.
# NVIDIA users: replace with `nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits`
# Intel users: see the intel_gpu_top JSON output.
for f in /sys/class/drm/card*/device/gpu_busy_percent; do
    [[ -r $f ]] && { cat "$f"; exit 0; }
done
echo 0
