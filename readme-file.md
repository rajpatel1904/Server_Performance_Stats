# Server Performance Statistics Tool

A shell script to analyze and display comprehensive server performance statistics on Linux systems.

## Overview

This tool provides a quick overview of your server's performance metrics, including:

- CPU usage
- Memory usage
- Disk usage
- Top resource-consuming processes
- System information
- Network connections
- Logged-in users
- Recent system events

## Project Page URL

[https://github.com/rajpatel1904/Server_Performance_Stats.git]

## Installation

1. Clone the repository:
   ```bash
   git remote add origin https://github.com/rajpatel1904/Server_Performance_Stats.git

   cd Devops
   ```

2. Make the script executable:
   ```bash
   chmod 777 server-stats.sh
   ```

## Usage

Run the script with:

```bash
./server-stats.sh
```

For complete information (including some metrics that require elevated privileges):

```bash
sudo ./server-stats.sh
```

## Features

### Core Metrics

- **CPU Usage**: Shows the total CPU utilization percentage
- **Memory Usage**: Displays free and used memory with usage percentage
- **Disk Usage**: Shows disk space utilization with colored indicators
- **Process Monitoring**: Lists top 5 processes by CPU and memory usage

### Additional Information

- **System Details**: OS version, hostname, kernel version
- **System Uptime**: Running time and load averages
- **User Activity**: Currently logged-in users
- **Security**: Recent failed login attempts (requires appropriate permissions)
- **Network**: Summary of active network connections
- **System Logs**: Recent system messages from dmesg

## Output Example

The script provides colorized output for easy interpretation:
- Green: Normal usage levels
- Yellow: Moderate usage levels
- Red: High usage levels (potential issues)

## Requirements

- Linux-based operating system
- Bash shell
- Standard system utilities (ps, top, grep, awk, etc.)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
