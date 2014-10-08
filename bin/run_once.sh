#!/usr/bin/env sh

pgrep $@ > /dev/null || ($@ &)
