#!/sbin/openrc-run


user="root"

description="emulates an AirPort Express to stream music from i-devices"
start_stop_daemon_args="--user $user"

command="/usr/bin/shairport-sync"

command_background=yes
pidfile=/run/shairport-sync.pid

depend() {
    need localmount
    after bootmisc net* avahi-daemon
}

stop() {
    ebegin "Stopping Shaitport-sync"
    start-stop-daemon --stop --quiet \
        --exec /usr/bin/shairport-sync
    eend $?
}
