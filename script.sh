#!/bin/bash
sh updater.sh | while IFS= read -r line; do echo "$(date) $line"; done  >> log.txt