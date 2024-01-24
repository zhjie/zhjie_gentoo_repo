#!/sbin/openrc-run
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

description="AirConnect: Send audio to UPnP players using AirPlay"

user="root:root"
logfile="/tmp/airupnp.log"
command="/usr/bin/airupnp"
command_args=""
pidfile="/run/airupnp.pid"
start_stop_daemon_args="--nicelevel -10 --background --make-pidfile --stderr ${logfile} --user ${user}"

depend() {
    use alsasound
    after bootmisc
}

start_pre() {
    mkdir -p /var/lib/airupnp
    checkpath --file --owner $user --mode 0644 $logfile
}
