#!/sbin/openrc-run

export SSD_NICELEVEL="-15"
export ROON_DATAROOT=/var/roon
export ROON_ID_DIR=/var/roon

user="root:root"
logfile="/var/log/roonserver.log"

start_stop_daemon_args="--user $user"

command="nice"
command_args="
    -n -15 /opt/RoonServer/start.sh -f $logfile
"

command_background=yes
pidfile=/run/roonserver.pid

#need net
depend() {
    # use alsasound
    after bootmisc
}

start_pre() {
    checkpath --file --owner $user --mode 0644 $logfile
}
