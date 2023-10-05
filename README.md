# TraceRoller: A TCPDump Rolling Trace Tool

`TraceRoller.sh` is a user-friendly tool that allows users to capture network traffic in a rolling trace fashion using `tcpdump`, all within a `tmux` session. This means that even if your SSH session is disconnected or you log out, the capture will continue to run.

**How it works:**

- **Rolling Trace Files:** The tool captures traffic into `.pcap` files that roll over. Each file is limited to 500MB, and a maximum of 20 such files are created. This configuration allows the tool to capture up to 10GB of trace data before it starts overwriting the oldest traces.
  
- **Session Management:** The trace capture operates within a `tmux` session, which allows it to persist beyond the lifespan of the initiating shell or SSH session. This offers uninterrupted trace collection even if the user disconnects or logs out.
  
- **Port Specification:** By default, the tool captures traffic on port `10001`. However, you can specify any port or set of comma-separated ports as an argument to focus the trace on specific traffic.
  
- **Easy Management:** You can start, stop, check the status of, or list the `tmux` sessions using the provided commands.

&nbsp;
&nbsp;


## Requirements

The user executing the script must have `sudo` permissions, as the script internally invokes `tcpdump` using `sudo`.


## Installation
```
wget https://raw.githubusercontent.com/Suaroman/networktrace/master/TraceRoller.sh && chmod +x TraceRoller.sh
```


## Usage

```
Usage: ./TraceRoller.sh {start|stop|status|list} [session_name] [port(s)]
For multiple ports, use comma separated without space e.g., 80,443
```

## Scenarios

### 1. Capture HiveServer2 Traffic
Here's an example where we capture traffic for HS2 and DNS.

```bash
./TraceRoller.sh list
no server running on /tmp/tmux-2020/default

./TraceRoller.sh start hs2 10001,53
tcpdump is now running in the tmux session named 'hs2'
```

Note: After starting the traces, you can safely log out of your SSH session. The traces will continue running.

If you forget the name of the session, you can simply list them:

```bash
./TraceRoller.sh list
hs2: 1 windows (created Wed Oct  4 12:02:03 2023) [80x24]
```

To stop the traces after observing a problem:

```bash
./TraceRoller.sh stop hs2

Stopped the tcpdump running in the tmux session named 'hs2'
adding: tmp/hs2-network-trace.pcap00 (deflated 81%)

=== > /tmp/hs2-network-trace-hn0-loadsp.zip
```

### 2. Capture winbindd Network Flows
Another use-case could be capturing `winbindd` network-related flows.

```bash
./TraceRoller.sh start samba-winbind 445,135,53,389,88
tcpdump is now running in the tmux session named 'samba-winbind'

./TraceRoller.sh list
samba-winbind: 1 windows (created Wed Oct  4 12:04:02 2023) [80x24]

./TraceRoller.sh stop samba-winbind
Stopped the tcpdump running in the tmux session named 'samba-winbind'
adding: tmp/samba-winbind-network-trace.pcap00
zip warning: file size changed while zipping /tmp/samba-winbind-network-trace.pcap00
(deflated 10%)

=== > /tmp/samba-winbind-network-trace-hn0-loadsp.zip
```

---


