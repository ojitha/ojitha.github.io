---
layout: post
title:  Encrypting in Dockerfile and Decrypting in Python
date:   2024-12-30
categories: [Docker]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

This approach allows you to encrypt sensitive data (like a database password) during Docker build and decrypt it safely at runtime in your Python application.



<!--more-->

------

* TOC
{:toc}
------

## Create a Python Application with Decryption Logic

First, let's create a Python script that can decrypt the password:

```python
import os
import base64
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend
import hashlib

def derive_key(salt_key, salt):
    """Derive an encryption key from the salt key and salt."""
    key = hashlib.pbkdf2_hmac(
        'sha256',
        salt_key.encode(),
        salt,
        100000,  # Number of iterations
        32  # Key length in bytes
    )
    return key

def decrypt_password(encrypted_password, salt_key):
    """Decrypt a password using AES-256-CBC with the salt key."""
    # Base64 decode the encrypted password
    encrypted_data = base64.b64decode(encrypted_password)
    
    # Extract the salt (first 16 bytes) and IV (next 16 bytes)
    salt = encrypted_data[:16]
    iv = encrypted_data[16:32]
    ciphertext = encrypted_data[32:]
    
    # Derive the key from the salt key and salt
    key = derive_key(salt_key, salt)
    
    # Create a cipher object
    cipher = Cipher(
        algorithms.AES(key),
        modes.CBC(iv),
        backend=default_backend()
    )
    
    # Decrypt the ciphertext
    decryptor = cipher.decryptor()
    padded_data = decryptor.update(ciphertext) + decryptor.finalize()
    
    # Unpad the data
    unpadder = padding.PKCS7(128).unpadder()
    data = unpadder.update(padded_data) + unpadder.finalize()
    
    # Return the decrypted password
    return data.decode('utf-8')

# Usage example
if __name__ == "__main__":
    # Get encrypted password and salt key from environment variables
    encrypted_password = os.environ.get('ENCRYPTED_DB_PASSWORD')
    salt_key = os.environ.get('SALT_KEY')
    
    if encrypted_password and salt_key:
        try:
            db_password = decrypt_password(encrypted_password, salt_key)
            print(f"Successfully decrypted password: {db_password}")
            
            # In a real application, you would use this password to connect to your database
            # db = DatabaseConnection(password=db_password)
            # ...
        except Exception as e:
            print(f"Error decrypting password: {e}")
    else:
        print("Missing encrypted password or salt key!")
```

## Create the Encryption Script

Next, let's create a script to encrypt the password:

```bash
#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <secret_to_encrypt> <salt_key>"
    exit 1
fi

SECRET="$1"
SALT_KEY="$2"

# Generate a random 16-byte salt
SALT=$(openssl rand -hex 16 | xxd -r -p)

# Generate a random 16-byte IV
IV=$(openssl rand -hex 16 | xxd -r -p)

# Derive key from salt_key and salt using PBKDF2
KEY=$(echo -n "$SALT_KEY" | openssl dgst -sha256 -hmac "$SALT" -binary)

# Encrypt the secret using AES-256-CBC
# PKCS7 padding is automatically applied
ENCRYPTED=$(echo -n "$SECRET" | openssl enc -aes-256-cbc -K $(xxd -p -c 32 <<< "$KEY") -iv $(xxd -p -c 32 <<< "$IV") -nosalt -binary)

# Combine salt + IV + encrypted data and base64 encode
COMBINED=$(echo -n "$SALT$IV$ENCRYPTED" | base64 -w 0)

# Output the encrypted result
echo "$COMBINED"
```

## Create the Dockerfile

Now, let's create a Dockerfile that encrypts the database password at build time:

```dockerfile
# syntax=docker/dockerfile:1.2
FROM python:3.9-slim

WORKDIR /app

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    xxd \
    && rm -rf /var/lib/apt/lists/*

# Copy encryption script and make it executable
COPY encrypt.sh /tmp/
RUN chmod +x /tmp/encrypt.sh

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Secrets that should not be in the image
ARG DB_PASSWORD="my_super_secret_password"
ARG SALT_KEY="my_build_time_salt_key"

# Encrypt the database password during build
# The encrypted password will be stored in the environment variable, but the original password won't be in the image
RUN --mount=type=secret,id=salt_key,target=/run/secrets/salt_key \
    SALT_KEY=$(cat /run/secrets/salt_key) && \
    ENCRYPTED_DB_PASSWORD=$(/tmp/encrypt.sh "$DB_PASSWORD" "$SALT_KEY") && \
    echo "ENCRYPTED_DB_PASSWORD=$ENCRYPTED_DB_PASSWORD" >> /app/.env && \
    rm /tmp/encrypt.sh

# Set the entrypoint
CMD ["python", "app.py"]
```

## Create the Requirements File

Let's create a requirements.txt file for the Python dependencies:

```
cryptography>=39.0.0
python-dotenv>=0.19.0
```

to fix the xxd error

```
#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <secret_to_encrypt> <salt_key>"
    exit 1
fi

SECRET="$1"
SALT_KEY="$2"

# Generate a random 16-byte salt
SALT=$(openssl rand 16 | openssl base64 | head -c 16)

# Generate a random 16-byte IV
IV=$(openssl rand 16 | openssl base64 | head -c 16)

# Use OpenSSL's built-in password-based encryption instead of manually deriving keys
# This avoids the xxd issues
ENCRYPTED=$(echo -n "$SECRET" | openssl enc -aes-256-cbc -pass "pass:$SALT_KEY" -S $(echo -n "$SALT" | hexdump -v -e '/1 "%02x"') -iv $(echo -n "$IV" | hexdump -v -e '/1 "%02x"') -base64)

# Output the encrypted result with metadata so we can decrypt later
echo "$SALT:$IV:$ENCRYPTED"
```

