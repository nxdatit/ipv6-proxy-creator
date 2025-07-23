# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an IPv6 SOCKS5 Proxy Creator project that automates the setup of IPv6 SOCKS5 proxies using 3proxy on CentOS systems. The project creates multiple IPv6 SOCKS5 proxies from a /64 subnet, each accessible through different ports on a single IPv4 address.

## Key Commands

### Building the installer
```bash
cd scripts
bash build.sh
```
This concatenates `system.sh`, `3proxy.sh`, and `main.sh` into a single `install.sh` file.

### Running the installer
```bash
bash scripts/install.sh
```
The installer will:
1. Install required packages (gcc, net-tools, bsdtar, zip)
2. Download and compile 3proxy
3. Create SOCKS5 proxies in `/home/proxy-installer/`
4. Generate SOCKS5 proxy credentials in `proxy.zip`

## Architecture

The codebase is organized as modular shell scripts:

- **scripts/system.sh**: Utility functions
  - `random()`: Generates random strings
  - `array_random_element()`: Selects random array element
  - `gen_64()`: Generates random IPv6 addresses from /64 subnet

- **scripts/3proxy.sh**: 3proxy management
  - `install_3proxy()`: Downloads and compiles 3proxy from GitHub
  - `gen_3proxy()`: Generates 3proxy SOCKS5 configuration
  - `gen_data()`: Creates SOCKS5 proxy user credentials
  - `gen_iptables()`: Sets up firewall rules
  - `gen_ifconfig()`: Configures IPv6 addresses on network interface
  - `gen_proxy_file_for_user()`: Creates downloadable SOCKS5 proxy list

- **scripts/main.sh**: Main execution flow
  - Detects IPv4 and IPv6 addresses
  - Prompts for number of SOCKS5 proxies
  - Orchestrates SOCKS5 proxy creation
  - Updates `/etc/rc.local` for persistence

## Important Details

1. Working directory: `/home/proxy-installer/`
2. SOCKS5 proxy port range: Starts at 10000
3. Output format: `IP4:PORT:LOGIN:PASS` (SOCKS5) in `proxy.zip`
4. 3proxy config location: `/usr/local/etc/3proxy/3proxy.cfg`
5. Requires CentOS 7/8/9 or CentOS Stream 9 with IPv6 /64 subnet
6. No automated tests - testing done manually via FoxyProxy and ipv6-test.com

## Development Notes
- Hãy làm việc với tôi toàn bộ bằng Tiếng Việt