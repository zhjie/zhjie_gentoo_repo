#!/sbin/openrc-run

export SSD_NICELEVEL="-20"
export ROON_DATAROOT=/var/roon
export ROON_ID_DIR=/var/roon

command="/opt/RoonServer/Server/RoonServer"

command_background=yes
pidfile=/run/roonserver.pid

depend() {
    use alsasound
    after bootmisc
}
