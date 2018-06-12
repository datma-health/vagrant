#!/bin/bash

# Clearing eth1 to get private network bound correctly to the host machine
sudo /sbin/ifdown eth1
sudo /sbin/ifup eth1
