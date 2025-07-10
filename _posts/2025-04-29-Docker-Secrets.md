---
layout: post
title:  Encrypting in Dockerfile and Decrypting in Python
date:   2024-12-30
categories: [Docker]
toc: true
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
import hashlib

def decrypt_password(encrypted_data, salt_key):
    """
    Decrypt a password that was encrypted with the simple MD5-based script.
    """
    # Split the components
    encoded_secret, stored_key = encrypted_data.split(':')
    
    # Generate MD5 hash from salt key
    key = hashlib.md5(salt_key.encode()).hexdigest()
    
    # Verify the key matches
    if key != stored_key:
        raise ValueError("Invalid salt key")
    
    # Base64 decode the secret
    secret = base64.b64decode(encoded_secret).decode('utf-8')
    
    return secret

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

# Generate a simple MD5 hash of the salt key
KEY=$(echo -n "$SALT_KEY" | md5sum | cut -d' ' -f1)

# Base64 encode the secret
ENCODED=$(echo -n "$SECRET" | base64)

# Combine the encoded secret with the MD5 hash as a simple "encryption"
ENCRYPTED="$ENCODED:$KEY"

# Output the encrypted result
echo "$ENCRYPTED"
```

## Create the Dockerfile

Now, let's create a Dockerfile that encrypts the database password at build time:

```dockerfile
# syntax=docker/dockerfile:1.2
FROM amazonlinux:2

# Install required packages (minimal requirements)
RUN yum update -y && \
    yum install -y python3 python3-pip && \
    yum clean all

WORKDIR /app

# Copy encryption script and make it executable
COPY encrypt_md5_simple.sh /tmp/
RUN chmod +x /tmp/encrypt_md5_simple.sh

# Copy application code
COPY decrypt_md5_simple.py ./app.py

# Secrets that should not be in the image
ARG DB_PASSWORD="my_super_secret_password"
ARG SALT_KEY="my_build_time_salt_key"

# Encrypt the database password during build
RUN --mount=type=secret,id=salt_key,target=/run/secrets/salt_key \
    SALT_KEY=$(cat /run/secrets/salt_key) && \
    ENCRYPTED_DB_PASSWORD=$(/tmp/encrypt_md5_simple.sh "$DB_PASSWORD" "$SALT_KEY") && \
    echo "ENCRYPTED_DB_PASSWORD=$ENCRYPTED_DB_PASSWORD" >> /app/.env && \
    rm /tmp/encrypt_md5_simple.sh

# Set the entrypoint
CMD ["python3", "app.py"]
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

