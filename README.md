# Badnet

a bash script that uses `tc` to emulate various real world network connectivity topologies

## usage

```
Must be run as root
badnet.sh [-m mode] [-d delay] [-l loss] [-u duplicate] [-r rate] <interface>
 Modify a network interface to match real world conditions
 latency and speed are set following https://www.bandwidthplace.com/article/speed-comparison-5g-4g-lte-3g
 if a mode is set, it override any other settings

Examples :
  Makes connectivity looks like 3G mobile network
  badnet.sh --mode 3G eth0

  Add specific delay, loss rate, duplicate rate, and bandwith speed
  badnet.sh -d 10ms -l 2% -u 1% -r 2.5mbit eth0

  Disable all rules and go back to normal
  badnet.sh --reset eth0

Options : 
  -h : show this message
  -m|--mode <mode>           : network mode. Available are : 2G, 3G, 4G, 4G+, 5G 
  --reset                    : remove any existing rules
  -r|--rate <speed>          : max speed  of the connection. accepted units are : bps, kbps, mbps, gbps
  -d|--delay <duration>      : add delay on the interface
  -l|--loss <percentage>     : percentage of lost packets
  -u|--duplicate <percentage>: percentage of duplicated packets

interface is like you see it in ip addr
```

