#!/usr/bin/env bats

source libcnb.bash

setup() {
  # Environment Variables.
  mkdir -p "$BATS_TMPDIR/layers"
  export CNB_BP_LAYERS_DIR="$BATS_TMPDIR/layers/"

  mkdir -p "$BATS_TMPDIR/config"
  export CNB_BP_CONFIG_DIR="$BATS_TMPDIR/config/"
}

teardown() {
  unset CNB_LAYERS_DIR
}

@test "creates a layer" {
  run cnb_create_layer "hello"
  [ "$status" -eq 0 ]
  [[ "$output" == "$CNB_BP_LAYERS_DIR/hello" ]] || false
  [ -f "$CNB_BP_LAYERS_DIR/hello.toml" ] || false
}

@test "creates a process type" {
  run cnb_create_process "web" "bash start.sh"
  [ "$status" -eq 0 ]
  [ -f "$CNB_BP_CONFIG_DIR/launch.toml" ] || false
}
