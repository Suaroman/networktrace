#!/bin/bash

# Author: gregorys

DEFAULT_SESSION_NAME="tcpdumpSession"

start_tcpdump() {
    SESSION_NAME=${1:-$DEFAULT_SESSION_NAME}
    PORTS=${2:-"10001"}

    # Transform the comma-separated list into the format "port xxx or port yyy or port zzz"
    PORTS_FORMATTED=$(echo $PORTS | sed 's/,/ or port /g')
    FILE_PATH="/tmp/${SESSION_NAME}-network-trace.pcap"
    TMUX_COMMAND="sudo tcpdump -w $FILE_PATH -i eth0 port $PORTS_FORMATTED -C 500 -W 20"

    tmux has-session -t $SESSION_NAME 2>/dev/null

    if [ $? != 0 ]; then
        tmux new-session -d -s $SESSION_NAME
        tmux send-keys -t $SESSION_NAME "$TMUX_COMMAND" C-m
        echo "tcpdump is now running in the tmux session named '$SESSION_NAME'"
    else
        echo "tcpdump is already running in the tmux session named '$SESSION_NAME'"
    fi
}

stop_tcpdump() {
    SESSION_NAME=${1:-$DEFAULT_SESSION_NAME}

    tmux has-session -t $SESSION_NAME 2>/dev/null

    if [ $? = 0 ]; then
        tmux kill-session -t $SESSION_NAME
        echo "Stopped the tcpdump running in the tmux session named '$SESSION_NAME'"
    else
        echo "No active tcpdump session named '$SESSION_NAME' found."
    fi
}

show_status() {
    SESSION_NAME=${1:-$DEFAULT_SESSION_NAME}

    tmux has-session -t $SESSION_NAME 2>/dev/null

    if [ $? = 0 ]; then
        echo "tcpdump is running in the tmux session named '$SESSION_NAME'"
    else
        echo "No active tcpdump session named '$SESSION_NAME' found."
        echo "To list all active sessions, use the 'list' command."
    fi
}

list_sessions() {
    tmux list-sessions
}

case "$1" in
    start|START)
        start_tcpdump "$2" "$3"
        ;;
    stop|STOP)
        stop_tcpdump "$2"
        ;;
    status|STATUS)
        show_status "$2"
        ;;
    list|LIST)
        list_sessions
        ;;
    *)
        echo "Usage: $0 {start|stop|status|list} [session_name] [port(s)]"
        echo "For multiple ports, use comma separated without space e.g., 80,443"
        ;;
esac
