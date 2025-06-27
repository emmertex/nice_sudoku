#!/bin/bash
# A simple test runner for Godot

TEST_SCRIPT="res://tests/test_solvers.gd"

if [ -z "$1" ]; then
  # Run all tests
  godot --headless --script "$TEST_SCRIPT" --exit
else
  # Run a specific test
  godot --headless --script "$TEST_SCRIPT" --exit --test_func "$1"
fi 