#!/bin/bash

# original by Alessio Onori

set -e

CURRENT_DIR=$(dirname "$0")
cd $CURRENT_DIR 

source ../scripts_common_ws/source_ws.sh

./start_simulation.sh