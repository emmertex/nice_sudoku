#!/usr/bin/env bash
# A simple test runner for Godot

TEST_SCRIPT="res://tests/test_solvers.gd"

if [ -z "$1" ]; then
  godot --headless --script "$TEST_SCRIPT" --quiet
  exit $?
else
  godot --headless --script "$TEST_SCRIPT" --quiet --test_func "$1"
  exit $?
fi