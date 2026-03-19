#!/bin/bash
# Prevent base_os timeout due to inactivity

while [ ${AWAKE} == 1 ]; do
  echo "I'm awake - $(date)"
  sleep 300  # 5 minutes
done
