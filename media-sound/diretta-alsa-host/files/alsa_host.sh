#!/bin/sh

if [ ! -f "/opt/diretta-alsa-host/ssyncAlsa" ]; then
	if [ $(getconf PAGESIZE) == "4096" ]; then
		ln -s /opt/diretta-alsa-host/ssyncAlsa_gcc14_arm64_v80A4k /opt/diretta-alsa-host/ssyncAlsa
	fi
	if [ $(getconf PAGESIZE) == "16384" ]; then
		ln -s /opt/diretta-alsa-host/ssyncAlsa_gcc14_arm64_v81A16k /opt/diretta-alsa-host/ssyncAlsa
	fi
fi

if [[ -f "/opt/diretta-alsa-host/ssyncAlsa" ]]; then
	/opt/diretta-alsa-host/ssyncAlsa
fi
