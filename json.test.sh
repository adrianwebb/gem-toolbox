#!/bin/bash

python -m json.tool "$1" 1> /dev/null
if [ $? -eq 0 ]; then
    echo "Success!"
else
    echo "Failed"
fi