#!/usr/bin/env bash

# Utilities

cnb_load_env() {
  local env_dir
  if [ -n "${CNB_PLATFORM_DIR:-}" ]; then
    env_dir=${CNB_PLATFORM_DIR}/env
  else
    env_dir=${1:?}
  fi
  if compgen -G "${env_dir}/*" > /dev/null; then
    for var in "${env_dir}"/*; do
      declare "$(basename "${var}")=$(<"${var}")"
    done
  fi
}

# Layer Management

cnb_create_layer() {
  local name=${1:?}
  local dir=${CNB_LAYERS_DIR:?}
  mkdir -p "${dir}/${name}" > /dev/null
  touch "${dir}/${name}.toml" > /dev/null
  # TODO use a param to set launch, build, cache
  echo "${dir}/${name}"
}


# Launch Config

cnb_create_process(){
  local type=${1:?}
  local command=${2:?}
  local dir=${CNB_LAYERS_DIR:?}
  cat <<EOF > "${dir}/launch.toml"
[[processes]]
type = "${type}"
command = "${command}"
EOF
}
