# Overview

This is intended to be a simple Makefile for Ubuntu 20.04 (as of now) and/or PopOS 20.04. You can
install a number of EDA tools using it.

# Usage

Environment variable SWROOT will be where the tools are installed. This will default to ~/software.

Environment variable REPODIR will be where the repos are cloned. This will be default to ~/repos.

Open-source targets: xyce, ngspice, magic, netgen, klayout, xschem

% make <tool>
