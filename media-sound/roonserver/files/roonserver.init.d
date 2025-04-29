#!/sbin/openrc-run

description="RoonServer - Everything about music"
export SSD_NICELEVEL="-19"
export ROON_DATAROOT=/var/roon
export ROON_ID_DIR=/var/roon

user="root:root"
command="/opt/RoonServer/Server/RoonServer"
pidfile="/run/roonserver.pid"
command_background="yes"
output_log="/tmp/roonserver.log"
error_log="/tmp/roonserver.err"

depend() {
    # use alsasound
    after bootmisc
}

start_pre() {
    checkpath --file --owner $user --mode 0644 $output_log
    checkpath --file --owner $user --mode 0644 $error_log
}
