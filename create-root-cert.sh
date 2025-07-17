#!/usr/bin/env bash

set -e
domain="$HOSTNAME"
days="1825"
output_dir="$PWD"

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            domain="$2"
            shift # past argument
            shift # past value
            ;;
        --days)
            days="$2"
            shift # past argument
            shift # past value
            ;;
        -t|--tld)
            TLD="$2"
            shift # past argument
            shift # past value
            ;;
        -o|--output-dir)
            output_dir="$2"
            shift # past argument
            shift # past value
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done

root_key="$output_dir/$domain.key"
root_cert="$output_dir/$domain.cert"
root_pem="$output_dir/$domain.cert"
root_subject="/CN=$domain"
root_ext="subjectAltName=DNS:$domain,DNS:*.$domain"

if [[ -n $TLD ]]; then
  root_ext="$root_ext,DNS:$domain.$TLD,DNS:*.$domain.$TLD"
fi

mkdir -p "$output_dir"

echo "Create a root key"
openssl genrsa -out "$root_key" 2048

echo "Create a root certificate"
openssl req -x509 -new -nodes -key "$root_key" -sha256 -days "$days" -out "$root_cert" -subj "$root_subject" -addext "$root_ext"

echo "Validate root "
openssl x509 -in "$root_cert" -text -noout

echo "Creating combined key and certificate for .pem"
cat "$root_key" "$root_cert" > "$root_pem"
