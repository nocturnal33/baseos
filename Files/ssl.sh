#!/bin/bash

# Set user variable
USER=${USER:-"operator"}

# Generate new self-signed X.509 certificate for NoVNC
openssl req -new -x509 -days 365 -nodes \
  -subj "/C=US/ST=NH/L=Hanover/O=OpenSource/CN=localhost" \
  -out /etc/ssl/certs/novnc_cert.pem -keyout /etc/ssl/private/novnc_key.pem \
  > /dev/null 2>&1

# Combine the certificate and private key into one file for NoVNC
cat /etc/ssl/certs/novnc_cert.pem /etc/ssl/private/novnc_key.pem \
  > /etc/ssl/private/novnc_combined.pem

# Change ownership of the combined file to the specified user and root group
chown -R ${USER}:root /etc/ssl/private/

# Change permissions of the combined file to be globally writable
chmod 666 /etc/ssl/private/novnc_combined.pem

echo "NoVNC SSL certificate generated and configured successfully."
