#!/bin/bash
echo "PWD: $PWD"
echo "TARGET: $1"
grep -E '\\.' "$1"/*.tex | sed 's/\\./\n&/g' | grep -E '\\.' | grep -vf ./helpers/known_latex | sort | uniq
