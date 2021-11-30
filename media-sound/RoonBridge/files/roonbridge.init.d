#!/sbin/openrc-run

user="root:root"
logfile="/var/log/roon.log"

start_stop_daemon_args="--user $user"

command="/opt/RoonBridge/start.sh"
command_args="
	-f $logfile
"

command_background=yes
pidfile=/run/roon.pid

#need net
depend() {
    use alsasound
    after bootmisc
}

start_pre() {
    checkpath --file --owner $user --mode 0644 $logfile
}
