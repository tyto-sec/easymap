# Easymap

![easymap](/img/easymap.png)


<div align="center">

![last commit](https://img.shields.io/github/last-commit/tyto-sec/easymap) ![created](https://img.shields.io/github/created-at/tyto-sec/easymap) ![language](https://img.shields.io/github/languages/top/tyto-sec/easymap) ![stars](https://img.shields.io/github/stars/tyto-sec/easymap)

</div>

<br>

> **Easymap** is a Bash-based toolkit that automates a multi-stage network reconnaissance process using Nmap. It's designed to quickly discover live hosts, scan ports, and detect services and versions, all while offering different performance modes.

<br>


## Features

- **Network Discovery**

  - ICMP and multiple TCP/UDP probe scans to identify live hosts.
  
- **Port Scanning**

  - TCP SYN and UDP scans.
  - Adjustable speed.

- **Version and Service Detection**

  - Identifies services, versions and banners.
  - Generates XML and HTML reports for easier analysis.


<br>


## How to Use


### Installation


```bash
sudo chmod +x easymap
sudo cp easymap /usr/local/bin
```
<br>


### Usage

```bash
easymap [OPTIONS] --target <network/target/target list> --output <output folder> --mode <paranoid|slow|fast|aggressive>
```

<br> 



### Options

- `-h, --help` - Show this help message and exit
- `-v, --version` - Show version information
- `-t, --target` - Specify target network or host
- `-m, --mode` - Select scan mode: `paranoid`, `slow`, `fast` or `aggressive`
- `-o, --output` - Specify output folder
- `-n, --no-color` - Disable colored output
- `-s, --silent` - Run in silent mode (suppresses the banner logs)


<br>


### Examples

```bash
# Scan just one target
sudo easymap --target 127.0.0.1 --output ./output --mode slow

# Scan a list of targets
sudo easymap --target 127.0.0.1,127.0.0.2 --output ./output  --mode fast

# Scan a list of IPs or CIDR
sudo easymap --target targets.txt --output ./output --mode paranoid

# Scan a CIDR
sudo easymap --target 127.0.0.0/24 --output ./output --mode aggressive
```

<br>

##  Modes
<br>

The Nmap options for each performance mode are the following:

* **paranoid:** `-sS -p- -T0 -g 53 --max-retries 1 --scan-delay 1s -Pn -n`
* **slow:** `-sS -p- -sU --top-ports 20 -T1 -g 53 --max-retries 2 -Pn -n`
* **default:** `-sS -p- -sU --top-ports 20 -T3 -g 53 -Pn -n`
* **fast:** `-sS -p- -sU --top-ports 20 -T4 -g 53 --min-rate 1000 --max-retries 2 -Pn -n`
* **aggressive:** `sS -p- -sU --top-ports 100 -T5 --min-rate 3000 -g 53 --max-retries 1 --host-timeout 15m -Pn -n

<br>

## Dependencies

<br>

* [Nmap](https://nmap.org)
* [xmlstarlet](http://xmlstar.sourceforge.net/)
* [xsltproc](http://xmlsoft.org/XSLT/xsltproc.html)

<br> 

Install them on Debian/Ubuntu:

```bash
sudo apt update
sudo apt install nmap xmlstarlet xsltproc
```

<br>

## Disclaimer

<br>

This tool is intended for **authorized security testing and learning purposes only**. Always ensure you have permission to scan networks and systems.


