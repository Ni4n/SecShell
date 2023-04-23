#!/bin/bash

usage() {
  echo "Usage: $0 [-h] [-k key_file] [-c cert_file] [-p port_number]"
  echo "  -h             Display this help message"
  echo "  -k key_file    Private key file (default: key.pem)"
  echo "  -c cert_file   Certificate file (default: cert.pem)"
  echo "  -p port_number Port number to listen on (default: 4444)"
}

key_file="key.pem"
cert_file="cert.pem"
port_number="4444"

while getopts ":hk:c:p:" option; do
  case $option in
    h)
      usage
      exit;;
    k)
      key_file="$OPTARG";;
    c)
      cert_file="$OPTARG";;
    p)
      port_number="$OPTARG";;
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

# Check if key file and certificate file exist, generate if not
if [[ ! -f "$key_file" || ! -f "$cert_file" ]]; then
  echo "No key file or certificate file found. Generating new ones..." >&2
  openssl req -x509 -newkey rsa:4096 -nodes -keyout "$key_file" -out "$cert_file" -days 365 -subj "/CN=localhost"
fi

echo "Starting server with key file: $key_file, certificate file: $cert_file, and port: $port_number"
openssl s_server -quiet -key "$key_file" -cert "$cert_file" -port "$port_number"
