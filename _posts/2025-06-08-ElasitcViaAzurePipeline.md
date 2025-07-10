---
layout: post
title:  Azure DevOps pipeline to deploy Elasticsearch
date:   2025-06-08
categories: [Azure, ELK]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

<style>
/* Styles for the two-column layout */
.image-text-container {
    display: flex; /* Enables flexbox */
    flex-wrap: wrap; /* Allows columns to stack on small screens */
    gap: 20px; /* Space between the image and text */
    align-items: center; /* Vertically centers content in columns */
    margin-bottom: 20px; /* Space below this section */
}

.image-column {
    flex: 1; /* Allows this column to grow */
    min-width: 250px; /* Minimum width for the image column before stacking */
    max-width: 40%; /* Maximum width for the image column to not take up too much space initially */
    box-sizing: border-box; /* Include padding/border in element's total width/height */
}

.text-column {
    flex: 2; /* Allows this column to grow more (e.g., twice as much as image-column) */
    min-width: 300px; /* Minimum width for the text column before stacking */
    box-sizing: border-box;
}

/* Ensure image is responsive and centered within its column */
.image-column img {
    max-width: 100%;
    height: auto;
    display: block; /* Removes extra space below image */
    margin: 0 auto; /* Centers the image if it's smaller than its column */
}



/* For smaller screens, stack the columns */
@media (max-width: 768px) {
    .image-text-container {
        flex-direction: column; /* Stacks items vertically */
    }
    .image-column, .text-column {
        max-width: 100%; /* Take full width when stacked */
        min-width: unset; /* Remove min-width constraint when stacked */
    }
}
</style>

<div class="image-text-container">
    <div class="image-column">
        <img src="/assets/images/2025-06-08-ElasitcViaAzurePipeline/AzureDevOps4Elasticsearch.png" alt="Azure pipeline to deploy Elasticsearch" width="200" height="200">
    </div>
    <div class="text-column">
<p>This guide provides a comprehensive walkthrough for deploying an Elasticsearch application on an Azure Virtual Machine using an automated Azure DevOps pipeline. The process is broken down into four main parts: Azure VM Setup, Azure DevOps Pipeline Setup, Troubleshooting and Optimisation, and Security Recommendations.</p>
    </div>
</div>




<!--more-->

------

* TOC
{:toc}
------

## Setup

### Azure VM

Install Azure CLI if not already installed
```bash
# macOS:
brew install azure-cli

# Login to Azure
az login
```

Let's create the resources group

```bash
az group create \
  --name "rg-elasticsearch-dev" \
  --location "East US"
```

> 💥 It is essential to note that if you don't delete the resource group, it will continue to incur charges. Please check the end of this post.
{:.yellow}


Create a virtuale machine:

```bash
az vm create \
  --resource-group "rg-elasticsearch-dev" \
  --name "vm-elasticsearch-dev" \
  --image "Ubuntu2204" \
  --size "Standard_B2s" \
  --admin-username "azureuser" \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --location "East US"
```

Configure Public DNS (Recommended)

```bash
# Create a unique DNS prefix
DNS_PREFIX="elasticsearch-$(date +%s)"

az network public-ip update \
  --resource-group "rg-elasticsearch-dev" \
  --name "vm-elasticsearch-devPublicIP" \
  --dns-name "$DNS_PREFIX"
```

Open Required Ports

```bash
# HTTPS port for Kibana
az network nsg rule create \
  --resource-group "rg-elasticsearch-dev" \
  --nsg-name "vm-elasticsearch-devNSG" \
  --name "Allow-Kibana-HTTPS" \
  --priority 1001 \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 8443

# HTTP port for Kibana (redirects to HTTPS)
az network nsg rule create \
  --resource-group "rg-elasticsearch-dev" \
  --nsg-name "vm-elasticsearch-devNSG" \
  --name "Allow-Kibana-HTTP" \
  --priority 1002 \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 8080
```

If you need new rule, check what priorites are enabled

```bash
az network nsg rule list \
  --resource-group "rg-elasticsearch-dev" \
  --nsg-name "vm-elasticsearch-devNSG" \
  --query "[].{Name:name, Priority:priority, Port:destinationPortRange}" \
  --output table
```

Output:

```
Name                 Priority    Port
------------------   ----------  ------
default-allow-ssh    1000        22
Allow-Kibana-HTTPS   1001        8443
Allow-Kibana-HTTP    1002        8080
```

If you want to enable standard ports 443:

```bash
az network nsg rule create \
  --resource-group "rg-elasticsearch-dev" \
  --nsg-name "vm-elasticsearch-devNSG" \
  --name "Allow-HTTPS-Standard" \
  --priority 1003 \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 443
```

**📊 Azure NSG Priority System**

Azure NSG rules need unique priorities between **100-4096**:

| Priority  | Typical Use                               |
| --------- | ----------------------------------------- |
| 100-299   | High priority (critical services)         |
| 300-999   | Standard services                         |
| 1000-1999 | Common services (SSH typically uses 1000) |
| 2000-4096 | Low priority rules                        |

Get VM Details

```bash
az vm show -d \
  --resource-group "rg-elasticsearch-dev" \
  --name "vm-elasticsearch-dev" \
  --query "{Name:name, PublicIP:publicIps, FQDN:fqdns, PrivateIP:privateIps}" \
  --output table
```

Test SSH Connection

```bash
# Replace with your VM's public IP or FQDN
ssh azureuser@YOUR_VM_IP_OR_FQDN
```

If you want to stop, deallocate 

```bash
az vm stop --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
az vm deallocate --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev"
```

and start again

```bash
az vm start --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" 
```



## Azure DevOps Pipeline Setup Guide

### Prerequisites

1. Azure VM created (above)
2. SSH access to the VM is working
3. Azure DevOps organization: `https://dev.azure.com/<your orginaisation>`

### Step 1: Create SSH Service Connection

#### 1.1 Get SSH Private Key
On your local machine (where you created the VM):
```bash
# Display your private key
cat ~/.ssh/id_rsa

# Copy the entire content including headers:
# -----BEGIN OPENSSH PRIVATE KEY-----
# ...key content...
# -----END OPENSSH PRIVATE KEY-----
```

#### 1.2 Create Service Connection in Azure DevOps
1. Go to **https://dev.azure.com/...**
2. Select your project
3. Navigate to **Project Settings** (bottom left)
4. Click **Service connections**
5. Click **Create service connection**
6. Choose **SSH** and click **Next**

#### 1.3 Configure SSH Connection
Fill in these details:
```
Connection name: elasticsearch-vm-connection
Host name: [YOUR_VM_PUBLIC_IP_OR_FQDN]
Port number: 22
User name: azureuser
Private key: [PASTE YOUR SSH PRIVATE KEY HERE]
```

#### 1.4 Verify Connection
Click **Verify** to test the connection, then **Save**.

### Step 2: Create Environment

#### 2.1 Create Production Environment
1. Go to **Pipelines** → **Environments**
2. Click **Create environment**
3. Configure:
   ```
   Name: elasticsearch-production
   Description: Production environment for Elasticsearch deployment
   ```
4. Click **Create**

### 2.2 Add VM Resource (Optional)
1. In the environment, click **Add resource**
2. Choose **Virtual machines**
3. Select **Linux**
4. Use the SSH connection details to add your VM

### Step 3: Set Up the Pipeline

#### 3.1 Update Pipeline Variables
Your `azure-pipelines.yml` already has good configuration. Verify these variables match your VM:

```yaml
variables:
  vmResourceGroup: 'rg-elasticsearch-dev'
  vmName: 'vm-elasticsearch-dev'
  vmAdminUser: 'azureuser'
  serverDomain: '[YOUR_VM_FQDN]'  # Update this!
```

#### 3.2 Update Server Domain
Replace `[YOUR_VM_FQDN]` with your actual VM domain. Get it by running:
```bash
az vm show -d \
  --resource-group "rg-elasticsearch-dev" \
  --name "vm-elasticsearch-dev" \
  --query "fqdns" \
  --output tsv
```

#### 3.3 Create the Pipeline
1. Go to **Pipelines** → **Pipelines**
2. Click **Create Pipeline**
3. Choose **Azure Repos Git** (or your repo location)
4. Select your repository
5. Choose an **Existing Azure Pipelines YAML file**
6. Select `/azure-pipelines.yml`
7. Click **Continue**

#### 3.4 Review and Save
1. Review the pipeline configuration
2. Click **Save and run**

### Step 4: Update Environment File for Remote Deployment

Your pipeline automatically handles this. The file `.env.template` will be copied and modified as required.

### Step 5: Run the Pipeline

#### 5.1 Manual Trigger
1. Go to your pipeline
2. Click **Run pipeline**
3. Select the branch (usually `main`)
4. Click **Run**

#### 5.2 Monitor Deployment
The pipeline will:
1. **Build Stage**: Prepare deployment artifacts
2. **Deploy Stage**: Deploy to your VM
3. **Post-Deployment**: Verify the deployment

#### 5.3 Check Deployment Logs
Monitor each stage for any issues:
- **Prepare VM Environment**: Install Docker, Docker Compose
- **Copy Application Files**: Transfer your code
- **Deploy Application**: Start the services
- **Verify Deployment**: Health checks

### Step 6: Verify Deployment

#### 6.1 Check Pipeline Success
Ensure all stages complete successfully.

#### 6.2 Test Remote Access
Replace `[YOUR_VM_FQDN]` with your actual domain:
```bash
# Test HTTP (should redirect to HTTPS)
curl -I http://[YOUR_VM_FQDN]:8080

# Test HTTPS (ignore SSL warnings for self-signed cert)
curl -k https://[YOUR_VM_FQDN]:8443/api/status
```

#### 6.3 Access Kibana
Open in browser:
```
https://[YOUR_VM_FQDN]:8443
```

**Default credentials:**
- Username: `elastic`
- Password: `changeme`

## Troubleshooting

### Common Issues

It is essential to know that

- **Use `runOptions: 'inline'`** instead of `runOptions: 'commands'` for complex conditionals.
- **The `inline` option** treats your code as a proper bash script.
- **The `commands` option** has parsing limitations with multi-line if statements.

**Method 1: Chained Commands (Simple cases)**

```yaml
# OLD (Broken)
commands: |
  cd $(deploymentPath)
  docker-compose up -d

# NEW (Fixed)
commands: |
  cd $(deploymentPath) && docker-compose up -d
```

**Method 2: Single Script Session (Complex cases)**

```yaml
# For tasks with multiple directory-dependent commands
runOptions: 'inline'  # This runs as a single script!
inline: |
  #!/bin/bash
  set -e
  cd $(deploymentPath)
  # All commands run in same session now
  docker-compose up -d
  ./manage.sh health
```

#### **Upgrade to 16GB RAM (Recommended):**

bash

```bash
az vm stop --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
az vm deallocate --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
az vm resize --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" --size "Standard_B4ms" && \
az vm start --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
echo "✅ VM upgraded to 16GB RAM (Standard_B4ms)"
```

#### **Upgrade to 8GB RAM (Budget Option):**

bash

```bash
az vm stop --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
az vm deallocate --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
az vm resize --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" --size "Standard_D2s_v3" && \
az vm start --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
echo "✅ VM upgraded to 8GB RAM (Standard_D2s_v3)"
```

#### **Upgrade to 32GB RAM (High Performance):**

bash

```bash
az vm stop --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
az vm deallocate --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
az vm resize --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" --size "Standard_D8s_v3" && \
az vm start --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" && \
echo "✅ VM upgraded to 32GB RAM (Standard_D8s_v3)"
```

#### 🔧 After Resize - Update Elasticsearch

#### **Get VM Connection Info:**

bash

```bash
az vm show -d --resource-group "rg-elasticsearch-dev" --name "vm-elasticsearch-dev" --query "{IP:publicIps, FQDN:fqdns}" --output table
```

#### 1. SSH Connection Fails
```bash
# Test manual SSH
ssh azureuser@[YOUR_VM_IP]

# Check if port 22 is open
az network nsg rule list \
  --resource-group "rg-elasticsearch-dev" \
  --nsg-name "vm-elasticsearch-devNSG" \
  --query "[?name=='default-allow-ssh']"
```

#### 2. Docker Installation Fails
The pipeline installs Docker automatically, but if it fails:
```bash
# SSH into VM and install manually
ssh azureuser@[YOUR_VM_IP]
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
```

#### 3. Services Don't Start
```bash
# SSH into VM and check
ssh azureuser@[YOUR_VM_IP]
cd /opt/elasticsearch
sudo docker-compose logs -f
```

#### 4. Firewall Issues
```bash
# Check Ubuntu firewall
sudo ufw status

# Allow ports if needed
sudo ufw allow 8443
sudo ufw allow 8080
```

### Pipeline Failure Recovery

If the pipeline fails:
1. **Check the logs** in Azure DevOps
2. **Fix the issue** in your code
3. **Commit and push** the changes
4. **Re-run the pipeline**

### Manual Deployment (Fallback)

If the pipeline doesn't work, you can deploy manually:
```bash
# SSH into VM
ssh azureuser@[YOUR_VM_IP]

# Install dependencies
sudo apt update
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER

# Clone your repo or copy files
git clone [YOUR_REPO_URL]
cd [YOUR_PROJECT_FOLDER]

# Start services
./manage.sh start
```

## Security Recommendations

### Change Default Passwords
Before production use:
1. Update `.env` file with strong passwords
2. Redeploy the application
3. Update any documentation with new credentials

### SSL Certificates
For production, consider:
1. **Let's Encrypt** for free SSL certificates
2. **Azure Key Vault** for certificate management
3. **Custom domain** for better branding

## Delete resource group

As a first step, list the subscriptions:

```bash
az account list --query "[?state=='Enabled'].{Name:name, SubscriptionId:id}" --output table
```

If you have one more active subscription, you have to set.

```bash
az account set --subscription "<your-subscription-id>"
```

To delete the resource group:

```bash
az group delete --name rg-elasticsearch-dev --yes --no-wait
```

