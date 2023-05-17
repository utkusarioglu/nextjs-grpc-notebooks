#!/bin/sh

REPO_ENV_FILE_PATH=environment.repo.yml
COMMON_ENV_FILE_PATH=environment.common.yml
TMP_ENV_FILE_PATH=/tmp/environment.merged.yml

# create_tmp_env_file() {
#   if [ -z "$(which yq)" ]; then
#     echo "Error: yq needs to be available on the system for this script to run"
#     exit 1
#   fi
#   common_env_file_path=$1
#   repo_env_file_path=$2
#   tmp_env_file_path=$3
#   echo "Creating merged environment file…"
#   yq eval-all '. as $item ireduce ({}; . *+ $item)' \
#     "$common_env_file_path" \
#     "$repo_env_file_path" \
#     > "$tmp_env_file_path"
# }

# create_tmp_env_file \
#   "$COMMON_ENV_FILE_PATH" \
#   "$REPO_ENV_FILE_PATH" \
#   "$TMP_ENV_FILE_PATH"

# conda env update --prune --file "$TMP_ENV_FILE_PATH" 

conda env update --prune --file "$REPO_ENV_FILE_PATH"
