---
layout: notes 
title: Security
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

# Notes on Security
{:.no_toc}

---

* TOC
{:toc}

---

## Winodows certificates on WSL

To display the Windows certificate, use the `certmgr.msc`. To enable Windows certificates in WSL, you need to export them from Windows and import them into the WSL certificate store. Here are several methods:

Install the following packages to count the current certificates:

```bash
sudo apt install p11-kit p11-kit-modules
```

Count the existing certificates:

```bash
trust list | grep "pkcs11*" | wc -l
```

Create the following directories:

```bash
sudo mkdir -p /usr/local/share/ca-certificates/windows-certs
mkdir -p /mnt/c/temp/wsl-certs
```

Clear any existing temporary certificates 

```bash
rm -f /mnt/c/temp/wsl-certs/*.cer
```

Export Windows certificates using PowerShell with correct path handling

```bash
powershell.exe -Command "Get-ChildItem -Path Cert:\CurrentUser\Root | ForEach-Object { Export-Certificate -Cert \$_ -FilePath \"C:\\temp\\wsl-certs\\\$(\$_.Thumbprint).cer\" -Type CERT }"

```

Convert and import each certificate to WSL

```bash
#!/bin/bash
for cert in /mnt/c/temp/wsl-certs/*.cer; do
    if [ -f "$cert" ]; then
        dest="/usr/local/share/ca-certificates/windows-certs/$(basename ${cert%.*}).crt"
        sudo openssl x509 -inform DER -in "$cert" -out "$dest"
    fi
done
```

Update the CA certificate store

```bash
sudo update-ca-certificates
```

Now, when you run the command `trust list | grep "pkcs11*" | wc -l`, it should show you the difference value.

to lList only trusted CA certificates

```bash
trust list --filter=ca-anchors
```

List blacklisted certificates

```bash
trust list --filter=blacklist
```

Show details of specific certificate:

```bash
# First extract certificate to a file
trust extract --format=pem-bundle --filter=ca-anchors --purpose=server-auth /tmp/anchors.pem

# Then examine a specific certificate
openssl x509 -in /tmp/anchors.pem -text -noout
```

Extract certificates for specific purposes:

```bash
# Extract certificates trusted for server authentication
trust extract --format=pem-bundle --filter=ca-anchors --purpose=server-auth /tmp/server-auth.pem

# Extract certificates trusted for email
trust extract --format=pem-bundle --filter=ca-anchors --purpose=email /tmp/email.pem
```



### Show Windows Certificates

List certificates in Trusted Root store

```powershell
Get-ChildItem -Path Cert:\CurrentUser\Root
```

For more details on certificates

```bash
Get-ChildItem -Path Cert:\CurrentUser\Root | Format-List Subject, Issuer, Thumbprint, NotBefore, NotAfter
```

Filter by issuer example

```bash
Get-ChildItem -Path Cert:\CurrentUser\Root | Where-Object {$_.Issuer -like "*DigiCert*"}
```

List certificates in `ca-certificates.crt` bundle

```bash
awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt
```

View a specific certificate

```bash
openssl x509 -in /etc/ssl/certs/certificate-name.pem -text -noout
```

List all the certificates

```bash
dpkg -L ca-certificates
```

### Remove Certificates

Remove Winodows Certificates from WSL

```bash
# Remove the entire windows-certs directory
sudo rm -rf /usr/local/share/ca-certificates/windows-certs/

# Update the certificate store to apply changes
sudo update-ca-certificates --fresh
```

If you only want to remove specific certificates:

```bash
# List all imported Windows certificates
ls -la /usr/local/share/ca-certificates/windows-certs/

# Remove a specific certificate
sudo rm /usr/local/share/ca-certificates/windows-certs/CERTIFICATE_FILENAME.crt

# Update the certificate store
sudo update-ca-certificates
```

To remove using p11-Kit:

```bash
# List certificates to identify what to remove
trust list

# Remove a specific certificate by its path
sudo trust anchor --remove /usr/local/share/ca-certificates/windows-certs/CERTIFICATE_FILENAME.crt
```

### CURL_CA_BUNDLE Environment Variable

The `CURL_CA_BUNDLE` environment variable is used by curl and libcurl to specify the path to a certificate bundle file containing trusted Certificate Authority (CA) certificates.

Purpose:

- Tells `curl` which CA certificates to trust when making `HTTPS` connections
- Provides a way to override the default system certificate store
- Allows applications using `libcurl` to use custom certificate verification

System trust stores are:

```bash
# Debian/Ubuntu
sudo cp /path/to/self-signed-ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

# RHEL/CentOS/Fedora
sudo cp /path/to/self-signed-ca.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```

### Debugging Certificate Issues

```bash
# Show verbose output to diagnose certificate problems
curl -v https://example.com

# Even more detailed SSL information
curl --trace-ascii curl_trace.txt https://example.com
```

