#!/sbin/openrc-run


user="root:root"

description="nqptp is a companion application to Shairport Sync and provides timing information for AirPlay 2 operation."
start_stop_daemon_args="--user $user"

command="/usr/bin/nqptp"

command_background=yes
pidfile=/run/nqptp.pid

depend() {
    after bootmisc
}

stop() {
    ebegin "Stopping nqptp"
    start-stop-daemon --stop --quiet \
        --exec /usr/bin/nqptp
    eend $?
}
