#!/bin/bash

df -h / | awk '{ print $4 }' | tail -n 1
