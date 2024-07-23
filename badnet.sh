#!/bin/bash

usage(){
    echo "Must be run as root"
    echo "$0 [-m mode] [-d delay] [-l loss] [-u duplicate] [-r rate] <interface>"
    echo " Modify a network interface to match real world conditions"
    echo " latency and speed are set following https://www.bandwidthplace.com/article/speed-comparison-5g-4g-lte-3g"
    echo " if a mode is set, it override any other settings"
    echo ""
    echo "Examples :"
    echo "  Makes connectivity looks like 3G mobile network"
    echo "  $0 --mode 3G eth0"
    echo ""
    echo "  Add specific delay, loss rate, duplicate rate, and bandwith speed"
    echo "  $0 -d 10ms -l 2% -u 1% -r 2.5mbit eth0"
    echo ""
    echo "  Disable all rules and go back to normal"
    echo "  $0 --reset eth0"
    echo ""
    echo "Options : "
    echo "  -h : show this message"
    echo "  -m|--mode <mode>           : network mode. Available are : 2G, 3G, 4G, 4G+, 5G "
    echo "  --reset                    : remove any existing rules"
    echo "  -r|--rate <speed>          : max speed  of the connection. accepted units are : bps, kbps, mbps, gbps"
    echo "  -d|--delay <duration>      : add delay on the interface"
    echo "  -l|--loss <percentage>     : percentage of lost packets"
    echo "  -u|--duplicate <percentage>: percentage of duplicated packets"
    echo ""
    echo "interface is like you see it in ip addr"
    echo ""
    exit 0
}

# argz parsing
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--delay)
            DELAY=$2
            shift
            shift;;
        -l|--loss)
            LOSS=$2
            shift
            shift;;
        -u|--duplicate)
            DUPLICATE=${2}
            shift
            shift;;
        -m|--mode)
            MODE=${2}
            shift
            shift;;
	-r|--rate)
            RATE=$2
	    shift
	    shift;;
	--reset)
	    RESET=true
	    shift
	    shift;;
        -h|--help)
            usage
	    exit 0
            ;;
        *)
            POSITIONAL+=("$1")
            shift;;
    esac
done

set -- "${POSITIONAL[@]}"
INTERFACE=$1

### FUNCTIONS ###

disable() {
  tc qdisc del dev $1 root
}

delay(){
  # $2 must be somthing line 10ms 
  tc qdisc add dev $1 root netem delay $2
}

loss(){
  # $2 must look like 0.5%
  tc qdisc change dev $1 root netem loss $2
}

duplicate(){
  # $2 is like 1%
  tc qdisc change dev $1 root netem duplicate $2
}

rate(){
  # rate is like 0.5mbit
  tc qdisc add dev $1 handle 10: root tbf rate $2
}

mobile2G(){
  disable   $1
  rate      $1 "20kbit"
  duplicate $1 "1%"
  loss      $1 "5%"
  delay     $1 "100ms"
}

mobile3G(){
  disable   $1
  rate      $1 "384kbit"
  duplicate $1 "1%"
  loss      $1 "5%"
  delay     $1 "100ms"
}

mobile4G(){
  disable   $1
  rate      $1 "15mbit"
  duplicate $1 "1%"
  loss      $1 "5%"
  delay     $1 "50ms"
}

mobile4Gp(){ # 4G+
  disable   $1
  rate      $1 "30mbit"
  duplicate $1 "1%"
  loss      $1 "5%"
  delay     $1 "30ms"
}

mobile5G(){
  disable   $1
  rate      $1 "150mbit"
  duplicate $1 "1%"
  loss      $1 "5%"
  delay     $1 "1ms"
}

### EXECUTION ###
[[ ! -z $INTERFACE ]] && usage
[[ -z $RESET ]]       && disable $INTERFACE
if [[ -z $MODE ]]; then
  [[ $MODE == "2G" ]]  && mobile2G  $INTERFACE	
  [[ $MODE == "3G" ]]  && mobile3G  $INTERFACE	
  [[ $MODE == "4G" ]]  && mobile4G  $INTERFACE	
  [[ $MODE == "4G+" ]] && mobile4Gp $INTERFACE	
  [[ $MODE == "5G" ]]  && mobile5G  $INTERFACE	
else
  [[ -z $DELAY ]]     && delay     $INTERFACE $DELAY
  [[ -z $LOSS ]]      && loss      $INTERFACE $LOSS
  [[ -z $DUPLICATE ]] && duplicate $INTERFACE $DUPLICATE
  [[ -z $RATE ]]      && rate      $INTERFACE $RATE
fi
