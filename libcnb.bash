#!/usr/bin/env bash

# Utilities

_cnb_load_env() {
  local env_dir=${1:?}
  if compgen -G "${env_dir}/*" > /dev/null; then
    for var in "${env_dir}"/*; do
      export "$(basename "${var}")=$(<"${var}")"
    done
  fi
}

cnb_load_env() {
  local env_dir
  if [[ -n "${CNB_PLATFORM_DIR:-}" ]]; then
    env_dir=${CNB_PLATFORM_DIR}/env
  else
    env_dir=${1:?}
  fi
  _cnb_load_env "$env_dir"
}

# Layer Management

cnb_create_layer() {
  local name=${1:?}
  local scope=${2:-"launch,build,cache"}
  local dir=${CNB_BP_LAYERS_DIR:?}
  mkdir -p "${dir}/${name}"

  if [[ ! -f "${dir}/${name}.toml" ]]; then
    if [[ "$scope" == *"launch"* ]]; then
      echo "launch = true" >> "${dir}/${name}.toml"
    fi

    if [[ "$scope" == *"build"* ]]; then
      echo "build = true" >> "${dir}/${name}.toml"
    fi

    if [[ "$scope" == *"cache"* ]]; then
      echo "cache = true" >> "${dir}/${name}.toml"
    fi
  else
    touch "${dir}/${name}.toml"
    # TODO what if the existing launch,build,cache don't match?
  fi
}

cnb_set_layer_env() {
  local layer=${1:?}
  local name=${2:-?}
  local value=${3:-?}
  local layers_dir=${CNB_BP_LAYERS_DIR:?}
  local env_dir="${layers_dir}/${layer}/env"
  mkdir -p "$env_dir"
  echo -n "$value" > "${env_dir}/${name}"
}

cnb_load_layer() {
  local name=${1:?}
  local layers_dir=${CNB_BP_LAYERS_DIR:?}
  local layer_dir="$layers_dir/$name"

  _cnb_load_env "${layer_dir}/env"
  _cnb_load_env "${layer_dir}/env.build"

  export "PATH=$layer_dir/bin:$PATH"
  export "LD_LIBRARY_PATH=$layer_dir/lib:${LD_LIBRARY_PATH:-}"
}

# Launch Config

cnb_create_process(){
  local type=${1:?}
  local command=${2:?}
  local dir=${CNB_BP_CONFIG_DIR:?}
  cat <<EOF >> "${dir}/launch.toml"
[[processes]]
type = "${type}"
command = "${command}"
EOF
}
