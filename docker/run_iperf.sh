#!/bin/bash
# Script to start iperf in client or server mode

set -euo pipefail
IFS=$'\n\t'

# environment variables read on startup:
#
# Run in the client or server role
# ROLE = [client || server]
#
# The remote IP of the server to connect to in client role
# SERVER_ADDR = [ip || host]
#
# Output reports to rsyslog instead of stdout
# RSYSLOG = [true || *false]
# RSYSLOG_REMOTE = [true || *false]
# RSYSLOG_REMOTE_IP = ip
# RSYSLOG_REMOTE_PORT = port
#
# If RSYSLOG_REMOTE is false sets the file logging path
# LOG_PATH = path, defaults to /var/log/iperf
#
# iperf itself responds to a a number of environment variables that
# can be used to configure the way it behaves in client and server
# mode. See the iperf documentation for a more complete list.
#
# https://iperf.fr/iperf-doc.php
#

# initialize from environment
role=${ROLE:-}
role_arg=
log_path=${LOG_PATH:-}
server_addr=${SERVER_ADDR:-}
rsyslog=${RSYSLOG:-}
rsyslog_remote=${RSYSLOG_REMOTE:-}
rsyslog_remote_ip=${RSYSLOG_REMOTE_IP:-}
rsyslog_remote_port=${RSYSLOG_REMOTE_PORT:-}

# set up for running as the client or server
if [ "${role}" = "client" ]; then
    if [ -z "${server_addr}" ]; then
        server_addr=127.0.0.1
    fi
    role_arg="-c"
elif [ "${role}" = "server" ]; then
    server_addr=
    role_arg="-s"
else
    echo "Error: unknown ROLE: ${role}"
    exit 1
fi

# ensure reasonable logging defaults
if [ -z "${log_path}" ]; then
    log_path="/var/log/iperf"
fi
if [ ! -d "${log_path}" ]; then
    mkdir -p ${log_path}
fi

# configure and start rsyslogd if called for
if [ "${rsyslog}" = "true" ]; then
    if [ ! -d "/etc/rsyslog.d" ]; then
        mkdir /etc/rsyslog.d
    fi
    mv /bin/rsyslog.conf /etc/
    sed -i"" -e "s:##LOG_PATH##:${log_path}:g" /bin/50-default.conf
    mv /bin/50-default.conf /etc/rsyslog.d/
    if [ "${rsyslog_remote}" = "true" ]; then
        sed -i"" -e "s:##RSYSLOG_REMOTE_IP##:${rsyslog_remote_ip}:g" -e "s:##RSYSLOG_REMOTE_PORT##:${rsyslog_remote_port}:g" /bin/49-remote.conf
        mv /bin/49-remote.conf /etc/rsyslog.d/
    else
        rm /bin/49-remote.conf
    fi
    /usr/sbin/rsyslogd
else
    rm /bin/50-default.conf
    rm /bin/49-remote.conf
fi

# start iperf
if [ "${rsyslog}" = "true" ]; then
    exec iperf ${role_arg} ${server_addr} $@ | logger -t iperf -p local0.info
else
    exec iperf ${role_arg} ${server_addr} $@
fi