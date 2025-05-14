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

Information for the [Jupyter in WSL](https://github.com/amaiya/devsetup/blob/main/wsl.md).

## Python Requests

A CA-bundle (Certificate Authority bundle) is a collection of trusted root certificates combined into a single file that applications use to verify the authenticity of SSL/TLS connections.

What It Is:

- A file containing multiple certificate authorities (CA) certificates concatenated together
- Typically in PEM format (text-based with `.crt`, `.pem`, or `.bundle` extension)
- Contains base64-encoded certificates with BEGIN/END CERTIFICATE markers
- Used as a trust store for verifying server certificates

Key Purposes:

- Provides a set of trusted root certificates to verify website identity
- Allows verification of SSL/TLS connections without requiring individual certificate installations
- Establishes the chain of trust for secure communications
- Enables applications to determine which certificate issuers to trust

common locations:

```bash
# Debian/Ubuntu
/etc/ssl/certs/ca-certificates.crt

# RHEL/CentOS/Fedora
/etc/pki/tls/certs/ca-bundle.crt

# macOS
/etc/ssl/cert.pem

# Windows
C:\Windows\System32\curl-ca-bundle.crt (for curl)
```

### Using SSL Certificates

Basic Certificate Verification

```python
import requests

# Basic HTTPS request (uses system CA bundle)
response = requests.get('https://example.com')

# Specify a custom CA bundle
response = requests.get('https://example.com', verify='/path/to/ca-bundle.crt')

# Disable certificate verification (not recommended for production)
response = requests.get('https://example.com', verify=False)
# This will show a warning unless you disable it:
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
```

### Using Client Certificates (mTLS)

```python
# Client certificate and key in separate files
response = requests.get('https://example.com', 
                      cert=('/path/to/client.crt', '/path/to/client.key'))

# Client certificate with key in single file
response = requests.get('https://example.com', 
                      cert='/path/to/client.pem')

# With password-protected private key
response = requests.get('https://example.com',
                      cert=('/path/to/client.crt', ('/path/to/client.key', 'password')))
```

### Using Session Objects (for multiple requests)

```python
session = requests.Session()
session.verify = '/path/to/ca-bundle.crt'
session.cert = ('/path/to/client.crt', '/path/to/client.key')

response1 = session.get('https://example.com/endpoint1')
response2 = session.get('https://example.com/endpoint2')
```

### Using environment variables

```python
# Set these before running your Python script
import os
os.environ['REQUESTS_CA_BUNDLE'] = '/path/to/ca-bundle.crt'

# Now all requests will use this CA bundle by default
requests.get('https://example.com')
```

### Advanced Certificate Handling

```python
import ssl
import requests

# Create a custom SSL context
context = ssl.create_default_context(cafile='/path/to/ca-bundle.crt')
context.load_cert_chain('/path/to/client.crt', '/path/to/client.key')
context.verify_mode = ssl.CERT_REQUIRED

# Use with requests via an adapter (more advanced)
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.poolmanager import PoolManager

class SSLAdapter(HTTPAdapter):
    def __init__(self, ssl_context=None, **kwargs):
        self.ssl_context = ssl_context
        super().__init__(**kwargs)
        
    def init_poolmanager(self, *args, **kwargs):
        kwargs['ssl_context'] = self.ssl_context
        return super().init_poolmanager(*args, **kwargs)

session = requests.Session()
adapter = SSLAdapter(ssl_context=context)
session.mount('https://', adapter)
response = session.get('https://example.com')
```

### Error Handling

```python
try:
    response = requests.get('https://example.com', verify='/path/to/ca-bundle.crt')
    response.raise_for_status()
except requests.exceptions.SSLError as e:
    print(f"SSL Error: {e}")
except requests.exceptions.RequestException as e:
    print(f"Request failed: {e}")
```

### Full certificate chain

Connect to a server and show the full certificate chain. The `-showcerts` option with `s_client` will display the entire chain as presented by the server. Look for multiple `BEGIN CERTIFICATE` blocks.

```bash
openssl s_client -connect example.com:443 -showcerts
```

Step 1: Extract and Save the Certificate Chain

```bash
# Save the full certificate chain to a file
openssl s_client -connect example.com:443 -showcerts </dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > certificate_chain.pem
```

Step 2: Using with curl

```bash
# Use the entire chain
curl --cacert certificate_chain.pem https://example.com

# Or set as environment variable
export CURL_CA_BUNDLE=certificate_chain.pem
curl https://example.com
```

To extract individual certificates if needed:

```bash
# Split the PEM file into individual certificates
csplit -f cert- certificate_chain.pem '/-----BEGIN CERTIFICATE-----/' '{*}'
```

Step 3: Using with Python Requests

```python
import requests

# Basic usage with certificate chain
response = requests.get('https://example.com', verify='certificate_chain.pem')

# For a session (multiple requests)
session = requests.Session()
session.verify = 'certificate_chain.pem'
response = session.get('https://example.com')

# Using environment variable approach
import os
os.environ['REQUESTS_CA_BUNDLE'] = 'certificate_chain.pem'
response = requests.get('https://example.com')
```

To extract only the root or a specific certificate:

```bash
# Get the first certificate (usually the server certificate)
openssl s_client -connect example.com:443 </dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | head -n 25 > server_cert.pem

# Extract all individual certificates from the chain
openssl s_client -connect example.com:443 -showcerts </dev/null | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".pem"; print >out}'
```

For client certificate authentication:

```bash
# With curl
curl --cacert certificate_chain.pem --cert client.crt --key client.key https://example.com

# With Python
response = requests.get('https://example.com', 
                      verify='certificate_chain.pem',
                      cert=('client.crt', 'client.key'))
```

```
nested_schema = StructType([
    ("id", StringType()),
    ("user", StructType([
        ("name", StringType()),
        ("profile", StructType([
            ("age", IntegerType()),
            ("email", StringType())
        ]))
    ]))
])
```

