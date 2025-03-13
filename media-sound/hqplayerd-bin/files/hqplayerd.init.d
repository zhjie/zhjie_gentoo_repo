#!/sbin/openrc-run
# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

description="HQPlayerEmbedded - upsampling multichannel audio player"

export SSD_NICELEVEL="-10"
user="root:root"
logfile="/tmp/hqplayerd.log"
command="/usr/bin/hqplayerd"
command_args=""
pidfile="/run/hqplayerd.pid"
start_stop_daemon_args="--nicelevel -10 --background --make-pidfile --stderr ${logfile} --user ${user}"

#need net
depend() {
    use alsasound
    after bootmisc
}

start_pre() {
    checkpath --file --owner $user --mode 0644 $logfile
}
