# FTP and SSH Brute-Force Script
Bash Script to bruteforce ftp credentiallist from seclists and try to login via ssh with found credentials

## Overview

This script performs a brute-force attack on an FTP server using a specified wordlist, attempts to download files from the server with the found credentials, and then tests SSH login credentials with the found FTP credentials. The script also provides user-friendly prompts and detailed output in the console.

## Features

- **FTP Brute-Force Attack**: Uses `hydra` to attempt login with a list of credentials.
- **File Download**: Downloads files from the FTP server using valid credentials.
- **SSH Login Test**: Attempts SSH login with the found FTP credentials and user-provided SSH usernames.
- **Interactive Prompts**: User is prompted to decide whether to download files and which SSH usernames to test.
- **Detailed Output**: Color-coded console output for better readability.

## Requirements

- `hydra` (for FTP brute-force)
- `sshpass` (for SSH login attempts)
- `ftp` command-line client
- A wordlist for FTP credentials (e.g., `/usr/share/seclists/Passwords/Default-Credentials/ftp-betterdefaultpasslist.txt`)

## Usage

1. **Make the script executable**:
    ```bash
    chmod +x ftp_ssh_bruteforce.sh
    ```

2. **Run the script**:
    ```bash
    ./ftp_ssh_bruteforce.sh <IP_ADDRESS>
    ```

    Replace `<IP_ADDRESS>` with the target IP address of the FTP server.

## Script Details

### Initial Setup

The script begins with a welcome message and checks if the target IP address is provided.

### FTP Brute-Force Attack

- Executes `hydra` with the specified wordlist to perform brute-force attacks on the FTP server.
- Saves the results in `ftp_bruteforce_results.txt`.

### File Download

- Prompts the user to decide if they want to download files using the found credentials.
- Downloads files from the FTP server and saves them in `~/Downloads/ftp_downloads`.

### SSH Login Test

- Prompts the user to enter SSH usernames (comma-separated).
- Tests SSH login with the found FTP credentials and the provided SSH usernames.

### Console Output

- Uses color-coded output for better readability:
  - **Green**: Successful operations
  - **Red**: Errors or failed attempts
  - **Yellow**: Warnings or prompts

## Example

```bash
chmod +x ftp_ssh_bruteforce.sh
./ftp_ssh_bruteforce.sh 10.0.2.15
```

### Notes
Ensure hydra, sshpass, and ftp are installed on your system.
Modify the FTP_WORDLIST path in the script if your wordlist is located elsewhere.

### License
This script is for educational and research purposes only. Use responsibly and in accordance with applicable laws and regulations.

