#!/bin/bash

sudo yum groupinstall "Development Tools" -y
sudo yum install cmake gcc gtk2-devel numpy pkconfig -y
