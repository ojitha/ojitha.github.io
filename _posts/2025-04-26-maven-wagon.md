---
layout: post
title:  Maven Proxy handling
date:   2025-04-26
categories: [Maven]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

Here are the common challenges when working with development tools like Maven and VSCode behind a corporate proxy within a WSL 2 environment. 

Currently, my computer is behind the corporate proxy. As a Java Programmer, when I used Maven 3 on the WSL 2 Ubuntu 20.4 Linux environment, I had to set the proxy in the settings.xml under the `/home/user/.m2` folder. Although I've set the proxy, it doesn't work as expected: `mvn compile` complains about unresolved Scala dependencies. Another problem is that VSCode doesn't show the intellisense. I've already installed the Microsoft Java extension pack completely.

<!--more-->

------

* TOC
{:toc}
------

## Introduction

The key to resolving these issues lies in ensuring that both Maven and potentially VSCode have the correct network configuration to bypass or authenticate with your corporate proxy for accessing external resources like dependencies.

Here's a breakdown of potential missing settings in your `settings.xml` and considerations for `MAVEN_OPTS`, along with insights into your VSCode Intellisense problem:

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  ...
  <proxies>
    <proxy>
      <id>myproxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>your_proxy_host.com</host>
      <port>your_proxy_port</port>
      <username>your_proxy_username</username>
      <password>your_proxy_password</password>
      <nonProxyHosts>localhost|127.0.0.1|*.your_company.com</nonProxyHosts>
    </proxy>
     <proxy>
      <id>myproxy-https</id>
      <active>true</active>
      <protocol>https</protocol>
      <host>your_proxy_host.com</host>
      <port>your_proxy_port</port>
      <username>your_proxy_username</username>
      <password>your_proxy_password</password>
      <nonProxyHosts>localhost|127.0.0.1|*.your_company.com</nonProxyHosts>
    </proxy>
  </proxies>
  ...
</settings>
```



**Key elements to check and configure:**

- `<id>`: A unique identifier for the proxy configuration (e.g., `myproxy`).
- `<active>`: Must be set to `true` for this proxy configuration to be active.
- `<protocol>`: Specify the protocol, usually HTTP. **It's crucial to have separate entries for `http` and `https` if your proxy handles them differently or requires distinct configurations.** This is a common oversight.
- `<host>`: Your corporate proxy server's hostname or IP address.
- `<port>`: The port number the proxy server listens on.
- `<username>` and `<password>`: **These are often the missing pieces.** If your corporate proxy requires authentication, you must provide your corporate network username and password here. Ensure these are correct.
- `<nonProxyHosts>`: A list of hosts that Maven should connect to directly, bypassing the proxy. This is important for internal company repositories (like Nexus or Artifactory) or local addresses. The hosts are typically separated by the pipe symbol (`|`). Include `localhost` and `127.0.0.1`, and ideally, any internal domain suffixes used by your company.

However, you can define the proxy settings using `MAVEN_OPTS` instead of the settings.xml file such as **.bashrc**:

```bash
export MAVEN_OPTS="-Dhttp.proxyHost=your_proxy_host.com -Dhttp.proxyPort=your_proxy_port -Dhttps.proxyHost=your_proxy_host.com -Dhttps.proxyPort=your_proxy_port -Dhttp.nonProxyHosts='localhost|127.0.0.1|*.your_company.com'"
```

## Wagon

Maven Wagon is a transport abstraction that is used in Maven's artifact and repository handling code.

When you encounter SSL certificate issues in Maven, especially when behind a corporate proxy, it's usually because the Java environment Maven is running in doesn't trust the SSL certificate presented by the proxy or the target repository. Maven, through its Wagon HTTP provider (which handles connections over HTTP and HTTPS), relies on the Java Runtime Environment's (JRE) or Java Development Kit's (JDK) SSL configuration.

### Addressing SSL Certificate Requirements

The most secure and recommended way to handle this is to make the Java environment trust the necessary certificate. Due to security risks, bypassing SSL validation should generally be avoided in production environments.

**1. Importing the Corporate Proxy's SSL Certificate into the Java Truststore (Recommended Secure Approach)**

This is the standard solution when a corporate proxy intercepts SSL traffic and presents its own certificate. You need to obtain the proxy's SSL certificate and add it to the truststore of the JDK that Maven is using in your WSL 2 environment.

**Steps:**

- **Obtain the Corporate Proxy's SSL Certificate:**

    - Often, your IT department can provide this certificate.
    - Alternatively, you can sometimes export it from your web browser when accessing an external HTTPS site from a machine configured to use the corporate proxy. Look for certificate details in your browser's security information for a site like `https://repo.maven.apache.org/`. Export the root certificate of the certificate chain used by the proxy.
    - You might also be able to use tools like `openssl` or `keytool` to retrieve the certificate from a server through the proxy, though this can be more complex.

- **Identify the JDK Maven is Using:**

    - In your WSL 2 terminal, run `mvn --version`. This will show you the Java version and the JAVA_HOME path that Maven uses. Note down the `JAVA_HOME` path.

- **Import the Certificate using `keytool`:**

    - Open your WSL 2 terminal.
    - Navigate to the JDK's security directory. Navigate to the JDK's security directory. This is typically located at `$JAVA_HOME/lib/security/` (for newer JDKs) or `$JAVA_HOME/jre/lib/security/` (for older JDKs)[^1]. 
    - The default Java truststore file is `cacerts`[^2].   
    - Execute the following command to import the certificate. Replace `/path/to/your/proxy.cer` with the actual path to the certificate file you obtained, and `your_alias_name` with a memorable alias (e.g., `corporate-proxy-cert`):

  ```bash
  sudo keytool -import -trustcacerts -alias your_alias_name -file /path/to/your/proxy.cer -keystore cacerts
  ```

    - You will be prompted for the truststore password. The default password for the `cacerts` file is usually `changeit`. You will also be asked to confirm trusting the certificate.

- **Verify the Import:**

    - You can list the certificates in the truststore to verify that yours was added:
    
        ```bash
        keytool -list -keystore cacerts
        ```
    
        
    
    - Enter the truststore password when prompted.
    
- **Restart WSL 2 and Maven:**

    - Shut down your WSL 2 distribution (`wsl --shutdown` in PowerShell or Command Prompt on Windows).
    - Restart WSL 2 and try running your Maven command (`mvn compile`) again.

Maven should now be able to trust the corporate proxy's certificate and connect to external repositories over HTTPS.

### Bypassing SSL Certificate Validation (Less Secure)

This approach tells Maven (specifically the Wagon HTTP provider) to ignore SSL certificate errors. **Only use this in trusted internal networks or for temporary debugging, as it makes your connection vulnerable to Man-in-the-Middle attacks.**

You can set the following Java system properties via the `MAVEN_OPTS` environment variable or by passing them directly to the `mvn` command:

Using `MAVEN_OPTS` (add to your `~/.bashrc` or `~/.zshrc` in WSL 2):

```bash
export MAVEN_OPTS="-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true"
```

Passing directly to maven command:

```bash
mvn compile -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true
```

**For Maven 3.9.0 and later**, which use a different transport by default, you might need to use:

```bash
export MAVEN_OPTS="-Daether.connector.https.securityMode=insecure"
```

or 

```bash
mvn compile -Daether.connector.https.securityMode=insecure
```

### Create customer trust store

Modifying the default `cacerts` file in your JDK will affect all Java applications using that JDK. If you need a more isolated solution, you could create a custom truststore and configure Maven to use it via `MAVEN_OPTS`:

```bash
export MAVEN_OPTS="-Djavax.net.ssl.trustStore=/path/to/your/custom_truststore.jks -Djavax.net.ssl.trustStorePassword=your_password"
```

Then, import the certificate into this custom truststore instead of the default `cacerts`.

[^1]: [Import security certificate to the JRE Keystore - IBM Documentation](https://www.ibm.com/docs/en/tnpm/1.4.2?topic=security-import-certificate-jre-keystore)

[^2]: [Importing certificates into Java default truststore - IBM Documentation](https://www.ibm.com/docs/en/manta-data-lineage?topic=articles-importing-certificates-into-java-default-truststore)

