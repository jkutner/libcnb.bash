#!/usr/bin/env bash

# Utilities

_cnb_load_env() {
  local env_dir=${1:?}
  if compgen -G "${env_dir}/*" > /dev/null; then
    for var in "${env_dir}"/*; do
      if [[ "$(basename $var)" == "PATH" ]]; then
        export PATH="$(<"$var"):$PATH"
      elif [[ $var == *.prepend ]]; then
        local var_only="$(basename "${var}" .prepend)"
        export "${var_only}=$(<"${var}"):$(printenv ${var_only})"
      elif [[ $var == *.append ]]; then
        local var_only="$(basename "${var}" .append)"
        export "${var_only}=$(printenv ${var}):$(<"${var_only}")"
      else
        export "$(basename "${var}")=$(<"${var}")"
      fi
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
  local layers_dir=${CNB_BP_LAYERS_DIR:?}
  local layer_dir="${layers_dir}/${name}"
  mkdir -p "${layer_dir}"

  if [[ ! -f "${layer_dir}.toml" ]]; then
    if [[ "$scope" == *"launch"* ]]; then
      echo "launch = true" >> "${layer_dir}.toml"
    fi

    if [[ "$scope" == *"build"* ]]; then
      echo "build = true" >> "${layer_dir}.toml"
    fi

    if [[ "$scope" == *"cache"* ]]; then
      echo "cache = true" >> "${layer_dir}.toml"
    fi
  else
    touch "${layer_dir}.toml"
    # TODO what if the existing launch,build,cache don't match?
  fi
  echo "${layer_dir}"
}

cnb_reset_layer() {
  local name=${1:?}
  local scope=${2:-"launch,build,cache"}
  local layers_dir=${CNB_BP_LAYERS_DIR:?}
  local layer_dir="${layers_dir}/${name}"
  rm -rf "${layer_dir}"
  rm -f "${layer_dir}.toml"
  cnb_create_layer "${name}" "${scope}" "${layers_dir}"
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

  if [[ -d "$layer_dir/bin" ]]; then export "PATH=$layer_dir/bin:$PATH"; fi
  if [[ -d "$layer_dir/lib" ]]; then export "LD_LIBRARY_PATH=$layer_dir/lib:${LD_LIBRARY_PATH:-}"; fi
}

cnb_set_layer_metadata() {
  local name=${1:?}
  local toml=${2:?}
  local layers_dir=${CNB_BP_LAYERS_DIR:?}
  local layer_toml="${layers_dir}/${name}.toml"
  cat <<EOF >> "${layer_toml}"
[metadata]
${2}
EOF
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
