# NetScan - Network Discovery Tool

![NetScan Logo](https://i.imgur.com/JQhG3vE.png)

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Technical Details](#technical-details)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Overview

NetScan is an advanced bash script that helps network administrators and IT professionals discover active hosts within their local network. Using ICMP ping sweeps with configurable parameters, it provides a clear map of connected devices.

**Key Advantages:**
- No dependencies beyond standard Linux tools
- Interactive interface with color-coded output
- Precise network boundary calculation
- Progress tracking for large scans

## Features

### Core Functionality
- Automatic network interface detection
- CIDR notation support (16-30)
- Parallel ping scanning
- Network/broadcast address exclusion
- Real-time active host display

### User Experience
- Interactive prompts with validation
- Color-coded terminal output
- Progress percentage indicator
- Scan confirmation for large networks
- Detailed final report

### Technical
- Bitwise network calculations
- IP address integer conversion
- Interface-specific pinging
- Configurable timeout values
- Error handling for common issues

## Installation

### Requirements
- Linux-based OS
- Bash 4.0+
- iproute2 package
- Standard GNU core utilities

### Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/JonatanGiedelmann/netscan.git
cd netscan
```

2. Make the script executable:
```bash
chmod +x netscan.sh
```

3. (Optional) Install system-wide:
```bash
sudo cp netscan.sh /usr/local/bin/netscan
```

## Usage

### Basic Scan
```bash
./netscan.sh
```

### Command Line Options
| Option | Description |
|--------|-------------|
| `-i <interface>` | Specify network interface |
| `-c <CIDR>` | Set subnet prefix (16-30) |
| `-t <timeout>` | Ping timeout in seconds (default: 0.2) |
| `-q` | Quiet mode (minimal output) |

### Interactive Mode
When run without options, the script will:
1. Show available interfaces
2. Prompt for interface selection
3. Display current network config
4. Allow CIDR modification
5. Confirm large scans
6. Show real-time results

## Examples

### Example 1: Basic Network Scan
```bash
$ ./netscan.sh
Available network interfaces:
eth0
wlan0

Enter network interface [default: eth0]: eth0

Current interface configuration:
  IP Address: 192.168.1.42
  Subnet Mask: /24

Enter subnet prefix (CIDR 16-30) [default: 24]: 
Scanning network: 192.168.1.0/24
Starting scan... (Press Ctrl+C to stop)
  Active: 192.168.1.1
  Active: 192.168.1.42
Scanned: 150/254 (59%) - Found: 12
```

### Example 2: Specific Interface Scan
```bash
./netscan.sh -i wlan0 -c 23
```

## Technical Details

### Network Calculation
The script uses bitwise operations to:
1. Convert IP addresses to 32-bit integers
2. Apply netmasks mathematically
3. Calculate valid host ranges
4. Skip reserved addresses

### Ping Methodology
- Uses `ping -c1 -W0.2` for each host
- Interface-specific with `-I` option
- Parallel execution with flow control
- Timeout configurable via `-t` option

### Performance Metrics
| Network Size | Approx Scan Time |
|-------------|------------------|
| /24 (254)   | 51 seconds       |
| /23 (510)   | 102 seconds      |
| /22 (1022)  | 3.4 minutes      |
| /16 (65534) | 3.6 hours        |

## Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

### Coding Standards
- 4-space indentation
- Descriptive variable names
- Section comments for logic blocks
- POSIX-compliant where possible

## License

MIT License

Copyright (c) [year] [yourname]

## Acknowledgments

- Inspired by traditional network mapping tools
- ASCII art generated with patorjk.com
- Color scheme from terminal-color-config

---

