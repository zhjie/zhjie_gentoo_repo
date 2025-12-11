#!/sbin/openrc-run
# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

description="Roon RAAT app"

export SSD_NICELEVEL="-19"

user="root:root"
logfile="/tmp/roon.log"

command="/usr/bin/raat_app"
command_args="/etc/raat.conf"

pidfile="/run/roon.pid"
start_stop_daemon_args="--nicelevel -19 --background --make-pidfile --stderr ${logfile} --user ${user}"

depend() {
    use alsasound
    after bootmisc
}

start_pre() {
    checkpath --file --owner $user --mode 0644 $logfile
}
