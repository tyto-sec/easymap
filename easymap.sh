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
            -n|--no-color) DISABLE_COLOR=true; shift ;; # Ativa a desabilitação
            -t|--target)   TARGET="$2"; shift 2 ;;
            -m|--mode)     MODE="$2"; shift 2 ;;
            -o|--output)   OUTPUT="$2"; shift 2 ;;
            --)           shift; break ;;
            *)            print_help; exit 0 ;;
        esac
    done

    COMMAND="$1"
    shift
    ARGS=("$@")
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
    printf "  ./main.sh [OPTIONS] <network/target>\n\n"

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
    printf "  ${cmd}easymap 192.168.1.0/24${reset}\n"
    printf "  ${cmd}easymap --mode fast 10.0.0.1${reset}\n"
    printf "  ${cmd}easymap --no-color --mode slow 172.16.0.0/16${reset}\n\n"
}

print_version() {
    echo "EasyMap version 2.0.0"
}

main() {
    parse_args "$@"
    
    case "$COMMAND" in
        "" )            print_help; exit 1 ;;
        help )         print_help; exit 0 ;;
        version )      print_version; exit 0 ;;
        * )            print_help; exit 1 ;;
    esac
}

main "$@"
    

