#!/bin/bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; NO_COLOR='\033[0m'
ORANGE='\033[38;5;208m' PINK='\033[38;5;205m'


parse_args() {
    local args
    args=$(getopt -o hvsnt:m:o: --long help,version,silent,no-color,target:,mode:,output: -n "${0}" -- "$@")
    eval set -- "$args"
    
    while true; do
        case "$1" in
            -h|--help)    print_help; exit 0 ;;
            -v|--version) print_version; exit 0 ;;
            -s|--silent)   SILENT=true; shift ;;
            -n|--no-color) DISABLE_COLOR=true; shift ;;
            -m|--mode)     MODE="$2"; shift 2 ;;
            -o|--output)   OUTPUT="$2"; shift 2 ;; 
            -t|--target)   TARGET="$2"; shift 2 ;;
            --)           shift; break ;;
            *)            print_help; exit 0 ;;
        esac
    done

}


print_header() {
    [ "$SILENT" = "true" ] && return

    local c1=$PINK; local c2=$RED; local c3=$ORANGE; local c4=$BLUE; local c5=$YELLOW; local c6=$PURPLE; local reset=$NO_COLOR
    if [ "$DISABLE_COLOR" = "true"  ]; then
        c1=""; c2=""; c3=""; c4=""; c5=""; reset=""
    fi

    printf "${c6}#######################################################################${reset}\n\n"
    printf "${c2}   .d88b.   8888b.  .d8888b  888  888 88888b.d88b.   8888b.  88888b.  ${reset}\n"
    printf "${c3}  d8P  Y8b     \"88b 88K      888  888 888 \"888 \"88b     \"88b 888 \"88b ${reset}\n"
    printf "${c4}  88888888 .d888888 \"Y8888b. 888  888 888  888  888 .d888888 888  888 ${reset}\n"
    printf "${c6}  Y8b.     888  888      X88 Y88b 888 888  888  888 888  888 888 d88P ${reset}\n"
    printf "${c4}   \"Y8888  \"Y888888  88888P'  \"Y88888 888  888  888 \"Y888888 88888P\"  ${reset}\n"
    printf "${c3}                                  888                        888      ${reset}\n"
    printf "${c2}                             Y8b d88P                        888      ${reset}\n"
    printf "${c1}                              \"Y88P\"                         888      ${reset}\n\n"
    printf "${c6}############################################################### v2.0.0 ${reset}\n\n\n"
    printf "              ${c5}EasyMap - Multi-Stage NMAP Helper Tool${reset}                  \n\n\n"
}

print_help() {
    print_header

    local cmd=$GREEN; local opt=$YELLOW; local reset=$NO_COLOR;
    if [ "$DISABLE_COLOR" = "true" ]; then
        cmd=""; opt=""; reset=""
    fi

    printf "${opt}USAGE:${reset}\n"
    printf "  easymap [OPTIONS] --target <network/target/target list> --output <output folder> --mode <paranoid|slow|fast|aggressive>\n\n"

    printf "${opt}DESCRIPTION:${reset}\n"
    printf "  EasyMap is a wrapper designed to simplify multi-stage Nmap scans,\n"
    printf "  providing specialized modes for different aggression levels. \n\n"

    printf "${opt}OPTIONS:${reset}\n"
    printf "  ${cmd}-h, --help${reset}      Show this help message and exit\n"
    printf "  ${cmd}-v, --version${reset}   Show version information\n\n"
    printf "  ${cmd}-t, --target${reset}    Specify target network or host\n"
    printf "  ${cmd}-m, --mode${reset}      Select scan mode: ${cmd}paranoid${reset}, ${cmd}slow${reset}, ${cmd}fast${reset} or ${cmd}aggressive${reset}\n"
    printf "  ${cmd}-o, --output${reset}    Specify output folder\n"
    printf "  ${cmd}-n, --no-color${reset}  Disable colored output\n"
    printf "  ${cmd}-s, --silent${reset}    Run in silent mode (suppresses the banner logs)\n"


    printf "${opt}EXAMPLES:${reset}\n"
    printf "  ${cmd}easymap --target 192.168.1.0/24${reset} --output ./output\n"
    printf "  ${cmd}easymap --mode fast --target 10.0.0.1${reset} --output ./output\n"
    printf "  ${cmd}easymap --no-color --mode slow --target 172.16.0.0/16${reset} --output ./output\n\n"
}

print_version() {
    echo "EasyMap version 2.0.0"
}

validate_target_type() {
    local TARGET=$1
    
    # Verify if it's a network range in CIDR notation
    if [[ "$TARGET" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        echo "network_range"
        return 0
    fi
    
    # Verify if it's a single IP
    if [[ "$TARGET" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "single_ip"
        return 0
    fi
    
    # Verify if it's a list of IPs separated by commas
    if [[ "$TARGET" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(,([0-9]{1,3}\.){3}[0-9]{1,3})+$ ]]; then
        echo "ip_list"
        return 0
    fi
    
    # Invalid format
    echo "invalid"
    return 1
}

host_discovery() {
    local TARGET=$1
    local OUTPUT_DIR=$2
    local SILENT=$3
    local TARGET_TYPE=$(validate_target_type "$TARGET")
    
    if [ "$TARGET_TYPE" == "invalid" ]; then
        if [[ "$DISABLE_COLOR" != "true" ]]; then
            echo -e "${RED}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Error: Invalid target format '$TARGET'."
        else
            echo "[$(date +"%Y-%m-%d %H:%M:%S")] Error: Invalid target format '$TARGET'."
        fi
        exit 1
    elif [ "$TARGET_TYPE" == "network_range" ]; then
        NETWORK=$TARGET
        
        local NETWORK_NAME=${NETWORK%%/*}
        local DATE="$(date -I)"
        local FILENAME_PREFIX="${OUTPUT_DIR}/${NETWORK_NAME}_${DATE}"
        
        if [[ "$SILENT" != "true" ]]; then
            if [[ "$DISABLE_COLOR" != "true" ]]; then
                echo -e "${YELLOW}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Starting host discovery on network range: ${GREEN}$NETWORK${NO_COLOR}\n"
            else
                echo "[$(date +"%Y-%m-%d %H:%M:%S")] Starting host discovery on network range: $NETWORK\n"
            fi
            nmap -sn -PE -PP -PM -PS21,22,80,443 -PA21,22,80,443 -PU53,123,161 -PY80 --disable-arp-ping $NETWORK -oX "${FILENAME_PREFIX}_nmap_host_discovery.xml"
            
            if [[ "$DISABLE_COLOR" != "true" ]]; then
                echo -e "\n${YELLOW}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Extracting live hosts to ${GREEN}${FILENAME_PREFIX}_live_hosts.txt${NO_COLOR}\n"
            else
                echo "\n[$(date +"%Y-%m-%d %H:%M:%S")] Extracting live hosts to ${FILENAME_PREFIX}_live_hosts.txt\n"    
            fi
        else 
            nmap -sn -PE -PP -PM -PS21,22,80,443 -PA21,22,80,443 -PU53,123,161 -PY80 --disable-arp-ping $NETWORK -oX "${FILENAME_PREFIX}_nmap_host_discovery.xml" >/dev/null 2>&1
        fi
        
        xmlstarlet sel -t -m "//host[status/@state='up']" -v "address[@addrtype='ipv4']/@addr" -n "${FILENAME_PREFIX}_nmap_host_discovery.xml" > "${FILENAME_PREFIX}_live_hosts.txt"


    elif [ "$TARGET_TYPE" == "single_ip" ]; then
        SINGLE_IP=$TARGET

        local DATE="$(date -I)"
        local FILENAME_PREFIX="${OUTPUT_DIR}/${SINGLE_IP}_${DATE}"
        
        if [[ "$SILENT" != "true" ]]; then
            
            if [[ "$DISABLE_COLOR" != "true" ]]; then
                echo -e "${YELLOW}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Performing host discovery on single IP: ${GREEN}$SINGLE_IP${NO_COLOR}\n"
            else
                echo "[$(date +"%Y-%m-%d %H:%M:%S")] Performing host discovery on single IP: $SINGLE_IP\n"
            fi
            nmap -sn -PE -PP -PM -PS21,22,80,443 -PA21,22,80,443 -PU53,123,161 -PY80 --disable-arp-ping $SINGLE_IP -oX "${FILENAME_PREFIX}_nmap_host_discovery.xml"
        
            if [[ "$DISABLE_COLOR" != "true" ]]; then
                echo -e "\n${YELLOW}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Extracting live hosts to ${GREEN}${FILENAME_PREFIX}_live_hosts.txt${NO_COLOR}\n"
            else
                echo "\n[$(date +"%Y-%m-%d %H:%M:%S")] Extracting live hosts to ${FILENAME_PREFIX}_live_hosts.txt\n"    
            fi
        else 
            nmap -sn -PE -PP -PM -PS21,22,80,443 -PA21,22,80,443 -PU53,123,161 -PY80 --disable-arp-ping $SINGLE_IP -oX "${FILENAME_PREFIX}_nmap_host_discovery.xml" >/dev/null 2>&1
        fi

        xmlstarlet sel -t -m "//host[status/@state='up']" -v "address[@addrtype='ipv4']/@addr" -n "${FILENAME_PREFIX}_nmap_host_discovery.xml" > "${FILENAME_PREFIX}_live_hosts.txt"

    elif [ "$TARGET_TYPE" == "ip_list" ]; then
        IP_LIST=$TARGET

        local OUTPUT_DIR=$2
        local DATE="$(date -I)"
        local FILENAME_PREFIX="${OUTPUT_DIR}/ip_list_${DATE}"
        
        if [[ "$SILENT" != "true" ]]; then
            
            if [[ "$DISABLE_COLOR" != "true" ]]; then
                echo -e "${YELLOW}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Performing host discovery on IP list: ${GREEN}$IP_LIST${NO_COLOR}\n"
            else
                echo "[$(date +"%Y-%m-%d %H:%M:%S")] Performing host discovery on IP list: $IP_LIST\n"
            fi
            nmap -sn -PE -PP -PM -PS21,22,80,443 -PA21,22,80,443 -PU53,123,161 -PY80 --disable-arp-ping $(echo $IP_LIST | tr ',' ' ') -oX "${FILENAME_PREFIX}_nmap_host_discovery.xml"
        
            if [[ "$DISABLE_COLOR" != "true" ]]; then
                echo -e "\n${YELLOW}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Extracting live hosts to ${GREEN}${FILENAME_PREFIX}_live_hosts.txt${NO_COLOR}\n"
            else
                echo "\n[$(date +"%Y-%m-%d %H:%M:%S")] Extracting live hosts to ${FILENAME_PREFIX}_live_hosts.txt\n"    
            fi
        
        else
            nmap -sn -PE -PP -PM -PS21,22,80,443 -PA21,22,80,443 -PU53,123,161 -PY80 --disable-arp-ping $(echo $IP_LIST | tr ',' ' ') -oX "${FILENAME_PREFIX}_nmap_host_discovery.xml" >/dev/null 2>&1
        fi

        xmlstarlet sel -t -m "//host[status/@state='up']" -v "address[@addrtype='ipv4']/@addr" -n "${FILENAME_PREFIX}_nmap_host_discovery.xml" > "${FILENAME_PREFIX}_live_hosts.txt"
    fi

}

port_scan(){
    HOSTS_FILE="$1"
    MODE="$2"
    OUTPUT_DIR="$3"
    SILENT="$4"
    HOSTS_FILE_BASENAME="$(basename "$HOSTS_FILE")"
    HOSTS_FILE_NAME="${HOSTS_FILE_BASENAME%%_*}"
    DATE="$(date -I)"
    FILENAME_PREFIX="${OUTPUT_DIR}/${HOSTS_FILE_NAME}_${DATE}"
    FILENAME="${FILENAME_PREFIX}_nmap_port_scan.xml"

    if [[ ! -f "$HOSTS_FILE" ]]; then
        if [[ "$DISABLE_COLOR" != "true" ]]; then
            echo -e "${RED}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Error: Invalid hosts file '$HOSTS_FILE'."
        else
            echo "[$(date +"%Y-%m-%d %H:%M:%S")] Error: Invalid hosts file '$HOSTS_FILE'."
        fi
        exit 1
    fi

    case "$MODE" in
    paranoid)
        # Extremely stealth mode: TCP only, very slow, source port spoofing
        NMAP_OPTS="-sS -p- -T0 -g 53 --max-retries 1 --scan-delay 1s -Pn -n"
        ;;
    slow)
        # Moderate stealth mode: TCP and top UDP ports, source port spoofing
        NMAP_OPTS="-sS -p- -sU --top-ports 20 -T1 -g 53 --max-retries 2 -Pn -n"
        ;;
    default)
        # Balanced mode: full TCP scan, moderate speed, source port spoofing
        NMAP_OPTS="-sS -p- -sU --top-ports 20 -T3 -g 53 -Pn -n"
        ;;
    fast)
        # Fast mode: full TCP scan with optimizations
        NMAP_OPTS="-sS -p- -sU --top-ports 20 -T4 -g 53 --min-rate 1000 --max-retries 2 -Pn -n"
        ;;
    aggressive)
        # Aggressive mode: full TCP + top UDP ports, maximum speed, source port spoofing
        NMAP_OPTS="-sS -p- -sU --top-ports 100 -T5 --min-rate 3000 -g 53 --max-retries 1 --host-timeout 15m -Pn -n"
        ;;
    *)
        if [[ -n "$MODE" ]]; then
            if [[ "$DISABLE_COLOR" != "true" ]]; then
                echo -e "${RED}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Error: Invalid mode '$MODE'"
                echo -e "${YELLOW}Valid modes:${NO_COLOR} paranoid, slow, default, fast, aggressive"
            else
                echo "[$(date +"%Y-%m-%d %H:%M:%S")] Error: Invalid mode '$MODE'"
                echo "Valid modes: paranoid, slow, default, fast, aggressive"
            fi
            exit 1
        fi
        ;;
    esac

    if [[ "$SILENT" != "true" ]]; then
        if [[ "$DISABLE_COLOR" != "true" ]]; then
            echo -e "${YELLOW}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Starting port scan in ${GREEN}$MODE${NO_COLOR} mode on hosts from file: ${GREEN}$HOSTS_FILE${NO_COLOR}\n"
        else
            echo "[$(date +"%Y-%m-%d %H:%M:%S")] Starting port scan in $MODE mode on hosts from file: $HOSTS_FILE\n"
        fi
        nmap $NMAP_OPTS -oX "${FILENAME_PREFIX}_nmap_port_discovery.xml" -iL "$HOSTS_FILE"
    else
        nmap $NMAP_OPTS -oX "${FILENAME_PREFIX}_nmap_port_discovery.xml" -iL "$HOSTS_FILE" >/dev/null 2>&1
    fi

    if [[ "$DISABLE_COLOR" != "true" ]]; then
        echo -e "\n${YELLOW}[$(date +"%Y-%m-%d %H:%M:%S")]${NO_COLOR} Extracting open ports to ${GREEN}${FILENAME_PREFIX}_open_ports.txt${NO_COLOR}\n"
    else
        echo "\n[$(date +"%Y-%m-%d %H:%M:%S")] Extracting open ports to ${FILENAME_PREFIX}_open_ports.txt\n"    
    fi

    xmlstarlet sel -t \
    -m "//host[status/@state='up']" \
        -m "ports/port[state/@state='open']" \
        -v "concat(../../address[@addrtype='ipv4']/@addr, ':', @portid)" \
        -n \
    "${FILENAME_PREFIX}_nmap_port_discovery.xml" \
    > "${FILENAME_PREFIX}_open_ports.txt"
}

get_live_hosts_file() {
    local TARGET=$1
    local OUTPUT=$2
    local DATE="$(date -I)"
    local TARGET_TYPE=$(validate_target_type "$TARGET")
    local NETWORK_NAME=""
    
    if [ "$TARGET_TYPE" == "network_range" ]; then
        NETWORK_NAME="${TARGET%%/*}"
    elif [ "$TARGET_TYPE" == "single_ip" ]; then
        NETWORK_NAME="$TARGET"
    elif [ "$TARGET_TYPE" == "ip_list" ]; then
        NETWORK_NAME="ip_list"
    fi
    
    echo "${OUTPUT}/${NETWORK_NAME}_${DATE}_live_hosts.txt"
}

execute(){
    print_header

    if [[ -z "$OUTPUT" ]]; then
        echo "Error: --output is required"
        echo "Example: ./easymap.sh --target 172.16.109.131 --output ./output --mode aggressive"
        exit 1
    fi

    mkdir -p "$OUTPUT"

    host_discovery "$TARGET" "$OUTPUT" "$SILENT"

    local LIVE_HOSTS_FILE=$(get_live_hosts_file "$TARGET" "$OUTPUT")

    port_scan "$LIVE_HOSTS_FILE" "$MODE" "$OUTPUT" "$SILENT"
}

main() {
    parse_args "$@"
    
    if [[ -n "$TARGET" ]]; then
        execute
        exit 0
    fi
    
    print_help
    exit 1
}

main "$@"
    

