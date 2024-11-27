#!/sbin/openrc-run
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

description="Nvidia GPU Fan Control"

user="root:root"
command="/usr/bin/nvidia_fan_control.py"
pidfile="/run/nvidia_fan_control.pid"
command_background="yes"
output_log="/tmp/nvidia_fan_control.log"
error_log="/tmp/nvidia_fan_control.err"

depend() {
    after bootmisc
}

start_pre() {
    checkpath --file --owner $user --mode 0644 $output_log
    checkpath --file --owner $user --mode 0644 $error_log
}
