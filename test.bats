#!/usr/bin/env bats

source libcnb.bash

setup() {
  # Environment Variables.
  mkdir -p "$BATS_TMPDIR/layers"
  export CNB_LAYERS_DIR="$BATS_TMPDIR/layers/"
}

teardown() {
  unset PROFILE_PATH
  unset EXPORT_PATH
  unset BUILDPACK_LOG_FILE
  unset BPLOG_PREFIX
  unset ENV_DIR
}

@test "creates a layer" {
  run cnb_create_layer "hello"
  [ "$status" -eq 0 ]
  [[ "$output" == "$CNB_LAYERS_DIR/hello" ]] || false
}
