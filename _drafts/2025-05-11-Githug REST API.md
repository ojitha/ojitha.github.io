---
layout: post
title:  SSO
date:   2025-05-11
categories: [Cat1, Cat2]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

Breif introduction

<!--more-->

------

* TOC
{:toc}
------

## Introduction

Nginx as an SSO layer in front of Kibana, with Active Directory (AD) as the identity store, leveraging LDAP for authentication.

This solution involves:

1. **Nginx** is acting as a reverse proxy.
2. An **LDAP authentication helper service** that Nginx will query to authenticate users against your Active Directory via LDAP.
3. **Elasticsearch** is configured with X-Pack security, including an LDAP realm set up for `proxy` authentication. This means Elasticsearch will trust the username provided in a header by Nginx (after Nginx has verified the user with the LDAP helper) and then use LDAP for role mapping (authorisation).
4. **Kibana** is configured to work with the secured Elasticsearch.

Kibana would handle the SAML redirects and assertions directly, and Nginx would primarily act as a reverse proxy (potentially for SSL termination).

- `worker_processes 1;`: This sets the number of worker processes Nginx will use. For a POC, `1` is sufficient. In production, this is typically set to the number of CPU cores for optimal performance.
- `events { worker_connections 1024; }`: This block defines the global event loop settings. 
- `worker_connections` specifies the maximum number of simultaneous connections that a single worker process can open.
- The `http` block contains configurations that apply to all virtual hosts (servers) within Nginx.
    - `include mime.types;`: Includes a file that maps file extensions to MIME types (e.g., `.html` to `text/html`).
    - `default_type application/octet-stream;`: Sets the default MIME type for files if Nginx can't determine it.
    - `sendfile on;`: Enables efficient direct copying of data between file descriptors, reducing CPU overhead.
    - `keepalive_timeout 65;`: Sets the timeout for keep-alive connections with clients.

```
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    gzip on;

    include /etc/nginx/conf.d/*.conf;
}
```

As shown in the last line, include `nginx/conf.d/kibana-sso.conf`

```bash
upstream kibana {
    server kibana:5601;
}

# Map to extract username from cookie
map $cookie_kibana_session $auth_user {
    default "";
    ~^authenticated_(.+)$ $1;
}

server {
    listen 80;
    server_name kibana.localhost localhost;

    # Session configuration
    set $session_name "kibana_session";
    
    # Serve the test HTML page
    location = /login-test {
        default_type text/html;
        return 200 '<!DOCTYPE html>
<html>
<head>
    <title>Kibana SSO Test Login</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
        .login-box { border: 1px solid #ccc; padding: 20px; border-radius: 5px; background-color: #f9f9f9; margin-bottom: 20px; }
        button { padding: 10px 20px; margin: 5px; cursor: pointer; background-color: #007bff; color: white; border: none; border-radius: 3px; }
        button:hover { background-color: #0056b3; }
        .status { margin-top: 20px; padding: 10px; border: 1px solid #ddd; background-color: #fff; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>Kibana SSO Browser Test</h1>
    <div class="login-box">
        <h2>Quick Login</h2>
        <button onclick="window.location.href=\'/saml/simple-auth?user=user1\'">Login as User1</button>
        <button onclick="window.location.href=\'/saml/simple-auth?user=admin\'">Login as Admin</button>
        <button onclick="window.location.href=\'/saml/simple-auth?user=user2\'">Login as User2</button>
    </div>
    <div class="login-box">
        <h2>Actions</h2>
        <button onclick="window.location.href=\'/saml/status\'">Check Status</button>
        <button onclick="window.location.href=\'/saml/logout\'">Logout</button>
        <button onclick="window.location.href=\'/\'">Go to Kibana</button>
    </div>
</body>
</html>';
    }
    
    # Test endpoint
    location = /test {
        default_type text/plain;
        return 200 "Nginx is working!\n";
    }
    
    # SAML Login endpoint - now returns instructions for curl testing
    location /saml/login {
        default_type text/html;
        return 200 '<html>
<head><title>SAML Login Test</title></head>
<body>
<h1>Static SAML Authentication Test</h1>
<p>Use curl to POST a SAML response to /saml/acs</p>
<pre>
# Test with user1 (regular user) - use query parameters:
curl -X POST "http://localhost/saml/acs?SAMLResponse=user1&RelayState=/" \
  -c cookies.txt

# Or use the simple auth endpoint:
curl "http://localhost/saml/simple-auth?user=admin" -c cookies.txt -L

# Then check status:
curl -b cookies.txt http://localhost/saml/status
</pre>
</body>
</html>';
    }

    # SAML Assertion Consumer Service (ACS) - accepts static SAML for testing
    location = /saml/acs {
        # Set default relay state
        set $relay_state $arg_RelayState;
        if ($relay_state = "") {
            set $relay_state "/";
        }

        # Check query parameters for SAMLResponse
        if ($arg_SAMLResponse = "user1") {
            add_header Set-Cookie "kibana_session=authenticated_user1; Path=/; HttpOnly" always;
            add_header X-Auth-User "user1" always;
            return 302 $relay_state;
        }
        
        if ($arg_SAMLResponse = "user2") {
            add_header Set-Cookie "kibana_session=authenticated_user2; Path=/; HttpOnly" always;
            add_header X-Auth-User "user2" always;
            return 302 $relay_state;
        }
        
        if ($arg_SAMLResponse = "admin") {
            add_header Set-Cookie "kibana_session=authenticated_admin; Path=/; HttpOnly" always;
            add_header X-Auth-User "admin" always;
            return 302 $relay_state;
        }

        # Default response for any other user
        if ($arg_SAMLResponse ~ "^(.+)$") {
            set $saml_user $1;
            add_header Set-Cookie "kibana_session=authenticated_${saml_user}; Path=/; HttpOnly" always;
            return 302 $relay_state;
        }
        
        # No SAML response provided
        return 400 "Bad Request: Missing SAMLResponse in query parameters\n";
    }

    # Simplified authentication endpoint
    location = /saml/simple-auth {
        # Simple GET-based authentication for easier testing
        if ($arg_user ~ "^(.+)$") {
            set $auth_user $1;
            add_header Set-Cookie "kibana_session=authenticated_${auth_user}; Path=/; HttpOnly" always;
            return 302 "/";
        }
        return 400 "Missing user parameter\n";
    }

    # SAML Logout endpoint
    location = /saml/logout {
        add_header Set-Cookie "kibana_session=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly" always;
        return 302 /;
    }

    # SAML Metadata endpoint
    location = /saml/metadata {
        default_type application/xml;
        return 200 '<?xml version="1.0"?>
<EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata" entityID="http://kibana.localhost">
  <SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</NameIDFormat>
    <AssertionConsumerService index="0" isDefault="true"
      Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
      Location="http://localhost/saml/acs" />
    <SingleLogoutService 
      Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect"
      Location="http://localhost/saml/logout" />
  </SPSSODescriptor>
</EntityDescriptor>';
    }

    # Test endpoint to check authentication status
    location = /saml/status {
        default_type application/json;
        add_header Content-Type "application/json" always;
        
        if ($cookie_kibana_session = "") {
            return 200 '{"authenticated": false, "message": "No session cookie found"}';
        }
        
        if ($cookie_kibana_session ~ "^authenticated_(.+)$") {
            set $extracted_user $1;
            return 200 '{"authenticated": true, "user": "$1", "session": "$cookie_kibana_session"}';
        }
        
        return 200 '{"authenticated": false, "session": "$cookie_kibana_session", "message": "Invalid session format"}';
    }

    # Main location block
    location / {
        # Check authentication
        if ($cookie_kibana_session !~ "^authenticated_") {
            return 302 /saml/login?RelayState=$request_uri;
        }

        # Proxy to Kibana
        proxy_pass http://kibana;
        proxy_redirect off;
        proxy_buffering off;

        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Authorization "";
        proxy_set_header kbn-xsrf true;
        
        # Pass user info from session to Kibana (using map variable)
        proxy_set_header X-Authenticated-User $auth_user;
    }

    # Allow Kibana resources without auth
    location ~ ^/(api/status|bundles|built_assets|ui/fonts|bootstrap.js) {
        proxy_pass http://kibana;
        proxy_set_header Host $host;
        proxy_set_header kbn-xsrf true;
    }
}

```

