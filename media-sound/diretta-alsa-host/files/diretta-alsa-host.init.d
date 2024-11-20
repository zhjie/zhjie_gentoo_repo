#!/sbin/openrc-run
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

description="Diretta ALSA Host"

export SSD_NICELEVEL="-10"
user="root:root"
error_log="/tmp/diretta-alsa-host.err"
output_log="/tmp/diretta-alsa-host.log"
command="/opt/diretta-alsa-host/alsa_host.sh"
command_args=""
pidfile="/run/diretta-alsa-host.pid"
command_background="yes"
# start_stop_daemon_args="--nicelevel -10 --background --make-pidfile --stderr ${logfile} --user ${user}"

depend() {
    use alsasound
    after bootmisc
}

start_pre() {
    checkpath --file --owner $user --mode 0644 $output_log
    checkpath --file --owner $user --mode 0644 $error_log
}
