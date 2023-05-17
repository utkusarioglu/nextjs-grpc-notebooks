#!/bin/bash

echo "Starting watchmedo for pytest…"
watchmedo shell-command \
  --patterns "*.py" \
  --recursive \
  --command "\
      pytest src \
    " \
  .
  
