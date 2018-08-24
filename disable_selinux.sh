#!/bin/bash
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
