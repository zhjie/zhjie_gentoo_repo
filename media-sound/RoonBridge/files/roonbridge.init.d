#!/sbin/openrc-run

export SSD_NICELEVEL="-20"

command="/opt/RoonBridge/Bridge/RoonBridge"
command_args=""

command_background=yes
pidfile=/run/roon.pid

depend() {
    use alsasound
    after bootmisc
}
