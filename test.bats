#!/usr/bin/env bats

source libcnb.bash

setup() {
  # Environment Variables.
  mkdir -p "$BATS_TMPDIR/layers"
  export CNB_BP_LAYERS_DIR="$BATS_TMPDIR/layers/"

  mkdir -p "$BATS_TMPDIR/config"
  export CNB_BP_CONFIG_DIR="$BATS_TMPDIR/config/"

  mkdir -p "$BATS_TMPDIR/platform"
  export CNB_PLATFORM_DIR="$BATS_TMPDIR/platform/"
}

teardown() {
  unset CNB_LAYERS_DIR
  unset CNB_BP_CONFIG_DIR
  unset CNB_PLATFORM_DIR
}

@test "laods a platform env var" {
  unset TEST_VAR
  local env_dir="${CNB_PLATFORM_DIR}/env"
  mkdir -p "${env_dir}"
  echo -n "success" > "${env_dir}/TEST_VAR"
  cnb_load_env
  [ -n "$TEST_VAR" ] || false
  [[ "$TEST_VAR" == "success" ]] || false
  unset TEST_VAR
}

@test "creates a layer" {
  run cnb_create_layer "hello"
  [ "$status" -eq 0 ]
  # [[ "$output" == "$CNB_BP_LAYERS_DIR/hello" ]] || false
  [ -d "$CNB_BP_LAYERS_DIR/hello" ] || false
  [ -f "$CNB_BP_LAYERS_DIR/hello.toml" ] || false
  [[ "$(cat $CNB_BP_LAYERS_DIR/hello.toml)" == *"launch = true"* ]] || false
  [[ "$(cat $CNB_BP_LAYERS_DIR/hello.toml)" == *"build = true"* ]] || false
  [[ "$(cat $CNB_BP_LAYERS_DIR/hello.toml)" == *"cache = true"* ]] || false
}

@test "creates a build layer" {
  run cnb_create_layer "hello" "build"
  [ "$status" -eq 0 ]
  [ -d "$CNB_BP_LAYERS_DIR/hello" ] || false
  [ -f "$CNB_BP_LAYERS_DIR/hello.toml" ] || false
  [[ "$(cat $CNB_BP_LAYERS_DIR/hello.toml)" == *"build = true"* ]] || false
  cat $CNB_BP_LAYERS_DIR/hello.toml | grep -vq "launch = true" || false
  cat $CNB_BP_LAYERS_DIR/hello.toml | grep -vq "cache = true" || false
}

@test "creates a launch layer" {
  run cnb_create_layer "hello" "launch"
  [ "$status" -eq 0 ]
  [ -d "$CNB_BP_LAYERS_DIR/hello" ] || false
  [ -f "$CNB_BP_LAYERS_DIR/hello.toml" ] || false
  [[ "$(cat $CNB_BP_LAYERS_DIR/hello.toml)" == *"launch = true"* ]] || false
  cat $CNB_BP_LAYERS_DIR/hello.toml | grep -vq "build = true" || false
  cat $CNB_BP_LAYERS_DIR/hello.toml | grep -vq "cache = true" || false
}

@test "creates a launch and cache layer" {
  run cnb_create_layer "hello" "launch,cache"
  [ "$status" -eq 0 ]
  [ -d "$CNB_BP_LAYERS_DIR/hello" ] || false
  [ -f "$CNB_BP_LAYERS_DIR/hello.toml" ] || false
  [[ "$(cat $CNB_BP_LAYERS_DIR/hello.toml)" == *"launch = true"* ]] || false
  [[ "$(cat $CNB_BP_LAYERS_DIR/hello.toml)" == *"cache = true"* ]] || false
  cat $CNB_BP_LAYERS_DIR/hello.toml | grep -vq "build = true" || false
}

@test "sets layer env var" {
  run cnb_create_layer "with_env"
  [ "$status" -eq 0 ]

  run cnb_set_layer_env "with_env" "TEST_VAR" "something"
  [ "$status" -eq 0 ]

  unset TEST_VAR
  cnb_load_layer "with_env"
  [ -n "$TEST_VAR" ] || false
  [[ "$TEST_VAR" == "something" ]] || false
  unset TEST_VAR
}

@test "sets layer metadata" {
  run cnb_create_layer "with_env"
  [ "$status" -eq 0 ]

  run cnb_set_layer_metadata "with_env" """
something = true
"""
  [ "$status" -eq 0 ]
  [ -f "$CNB_BP_LAYERS_DIR/with_env.toml" ] || false
  [[ "$(cat $CNB_BP_LAYERS_DIR/with_env.toml)" == *"something = true"* ]] || false
}

@test "creates a process type" {
  run cnb_create_process "web" "bash start.sh"
  [ "$status" -eq 0 ]
  [ -f "$CNB_BP_CONFIG_DIR/launch.toml" ] || false
}
