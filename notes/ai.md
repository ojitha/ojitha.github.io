---
layout: notes 
title: Artificial Intelligence
mermaid: true
typora-root-url: ~/GitHub/ojitha.github.io
typora-copy-images-to: ../../blog/assets/images/${filename}
---

---

* TOC
{:toc}

---

# Antigravity

## 1. Installing Google Antigravity 2.0 (Desktop App)

To install Google Antigravity 2.0 (the desktop application) on your Ubuntu 24.04 LTS (x86_64)  machine, follow these steps:  

- Step 1: Download the Linux x64 Archive  
  The official build is distributed as a .tar.gz archive from https://antigravity.google/download.
  Run the following command to download the latest release:                                       
                                                                                                   

    curl -fSL "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.12.2-6298742303883264/linux-x64/Antigravity.tar.gz" -o /tmp/Antigravity.tar.gz      

- Step 2: Extract and Install  

  You can install it either locally for your user account (recommended, no `sudo` needed) or system-
  wide. 

  Recommended: User-Level Install (`~/.local/`) 

  ```bash
  # 1. Create installation directory 
  mkdir -p ~/.local/share/antigravity                                                           
  # 2. Extract into the target directory
  tar -xzf /tmp/Antigravity.tar.gz -C ~/.local/share/antigravity --strip-components=1   
  
  # 3. Create a symlink to ~/.local/bin (already in your PATH)                       
  ln -sf ~/.local/share/antigravity/antigravity ~/.local/bin/antigravity                        
  # 4. Clean up archive                                                             
  rm /tmp/Antigravity.tar.gz  
  ```

- Step 3: Add Desktop Launcher (Ubuntu App Menu)  

  To launch Antigravity from Ubuntu's application dashboard / search: 

  ```bash
  cat << 'EOF' > ~/.local/share/applications/antigravity.desktop 
  [Desktop Entry]
  Name=Google Antigravity 2.0
  Comment=Google Antigravity Desktop Orchestrator
  Exec=/home/ojitha/.local/share/antigravity/antigravity %U
  Terminal=false
  Type=Application
  Categories=Development;IDE;
  StartupWMClass=Antigravity
  EOF
  ```

  Update your desktop database:

  ```bash
  update-desktop-database ~/.local/share/applications
  ```

- To run in command line

  ```bash
  antigravity &
  // to kill
  pkill antigravity || true
  ```



This guide covers installing, updating, and connecting **Google Antigravity 2.0** (Desktop Orchestrator) and the standalone **Antigravity IDE**.

---

## 2. Updating Google Antigravity 2.0

### Option A: In-App (Automatic)
1. Open **Google Antigravity 2.0**.
2. Click **Settings** (gear icon in the bottom-left sidebar).
3. Under **App Settings**, make sure **Auto-check for updates** is enabled.
4. When a new version is detected, click **Update / Replace** and restart the app.

### Option B: Terminal (Manual Overwrite)
```bash
pkill antigravity || true
curl -fSL "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.12.2-6298742303883264/linux-x64/Antigravity.tar.gz" -o /tmp/Antigravity.tar.gz
tar -xzf /tmp/Antigravity.tar.gz -C ~/.local/share/antigravity --strip-components=1
rm /tmp/Antigravity.tar.gz
```

*(To update the Antigravity CLI tool, simply run `agy update`.)*

---

## 3. Installing Antigravity IDE

To install the full AI-native code editor (built on VS Code):

```bash
# 1. Download Antigravity IDE (Linux x64)
curl -fSL "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.5.5-4923483625488384/linux-x64/Antigravity%20IDE.tar.gz" -o /tmp/antigravity-ide.tar.gz

# 2. Create the target directory and extract
mkdir -p ~/.local/share/antigravity-ide
tar -xzf /tmp/antigravity-ide.tar.gz -C ~/.local/share/antigravity-ide --strip-components=1

# 3. Create a symlink to ~/.local/bin
ln -sf ~/.local/share/antigravity-ide/bin/antigravity-ide ~/.local/bin/antigravity-ide

# 4. Add desktop application shortcut
cat << 'EOF' > ~/.local/share/applications/antigravity-ide.desktop
[Desktop Entry]
Name=Google Antigravity IDE
Comment=AI-First Code Editor
Exec=/home/ojitha/.local/share/antigravity-ide/bin/antigravity-ide %F
Icon=/home/ojitha/.local/share/antigravity-ide/resources/app/resources/linux/code.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=Antigravity IDE
EOF

# 5. Update desktop database & clean up
update-desktop-database ~/.local/share/applications
rm /tmp/antigravity-ide.tar.gz
```

Launch it directly with:
```bash
antigravity-ide &
```

---

## 4. Accessing the IDE from Antigravity 2.0

1. Open **Google Antigravity 2.0**.
2. Click the **Projects** icon (folder with a `+`) in the left sidebar to create or select a project.
3. Click the **Open in IDE** / **Open in Editor** button in the project header (or press `Ctrl+P` and type `Open in Editor`).
4. To configure your editor preference:
   - Go to **Settings** → **Preferences** → **Default Editor**.
   - Select **Antigravity IDE** (or your preferred editor).

---

## 5. Alternative: Using Existing VS Code

If you prefer to continue using your existing VS Code installation (`/snap/bin/code`):

1. Open VS Code: `code`
2. Open the Extensions sidebar (`Ctrl+Shift+X`).
3. Search for and install the official **Google Antigravity** extension.
4. In Antigravity 2.0 under **Settings** → **Preferences**, set the default editor to **VS Code**.




# Lemonade

## Lemonade Server installation

Lemonade server was installed via a Debian package (.deb).                    

<u>Install method: dpkg / .deb package</u>                                         

  - Package: lemonade-server version 10.0.0 (amd64)                             
  - Source .deb file: /home/ojitha/Downloads/lemonade-server_10.0.0_amd64.deb   
  - Binaries installed to: /usr/bin/lemonade-server, /usr/bin/lemonade-web-app  
  - Also in: /opt/bin/ (lemonade-router, lemonade-server, lemonade-web-app)     
  - Config: /etc/lemonade/lemonade.conf and secrets.conf                        
  - Systemd service: /usr/lib/systemd/system/lemonade-server.service            
  - VS Code extension: lemonade-sdk.lemonade-sdk-0.0.7 also installed           
                                                                                

  To reinstall or upgrade, you can run: sudo dpkg -i                            
  /home/ojitha/Downloads/lemonade-server_10.0.0_amd64.deb

## Install FLM models in Lemonde Server

> The model location for the Lemonade server is `export HF_HOME=/opt/var/lib/lemonade/.cache/huggingface'`

Check what FLM itself knows

```bash
flm list
```

Pull via FLM directly, example `gemma3:4b`:

```bash
flm pull gemma3:4b
```

Then register it with lemonade under the user namespace

```bash
lemonade-server pull user.Gemma3-4b-it-FLM \
  --checkpoint gemma3:4b \
  --recipe flm
```

The `--checkpoint` value should match whatever `flm list` shows as the model identifier (likely `gemma3:4b` based on the upstream registry metadata).

Verify FLM is actually present:

```bash
which flm
flm --version
```
> The default location for the FLM models are `~/.config/flm/models/`.

## Ollama

Here is my current Ollama models:

```bash
ollama ls
```



![image-20260523111937157](/../../../../blog/assets/images/ai/image-20260523111937157.jpg)

# Ollama ROCm Setup on OJAI Machine

## Hardware

| Component | Detail |
|-----------|--------|
| Machine | MINISFORUM AI X1 Pro Mini PC |
| CPU | AMD Ryzen AI 9 HX 470 (Zen5, 12-core) |
| iGPU | AMD Radeon 890M (gfx1150, RDNA 3.5) |
| NPU | 86 TOPS (aie2p / RyzenAI-npu4) |
| OS | Ubuntu 24.04.4 |
| Kernel | 6.17.0-1012-oem |
| ROCm | 7.2.0 |
| MIGraphX | 2.15.0.dev+20250912 |

---

## Problem 1 — Ollama Server Already Running

Attempting to start Ollama failed because port `11434` was already bound:

```
Error: listen tcp 127.0.0.1:11434: bind: address already in use
```

> **Note:** `ollama stop` stops a *model*, not the server daemon — it requires a model name argument.

### Fix

```bash
sudo fuser -k 11434/tcp
```

---

## Problem 2 — Ollama Not Detecting ROCm / GPU

Running the debug check returned no output:

```bash
OLLAMA_DEBUG=1 ollama serve 2>&1 | grep -i "gpu\|rocm\|gfx"
```

This indicated Ollama was not recognising the **gfx1150** GPU — it is too new for Ollama's bundled ROCm to detect by default.

### Fix — Override GFX Version

```bash
HSA_OVERRIDE_GFX_VERSION=11.5.0 ollama serve &
```

#### To make permanent via systemd

```bash
sudo systemctl edit ollama
```

Add:

```ini
[Service]
Environment="HSA_OVERRIDE_GFX_VERSION=11.5.0"
```

Then reload:

```bash
sudo systemctl daemon-reload && sudo systemctl restart ollama
```

---

## Verification

GPU utilisation confirmed at **98%** via `rocm-smi --showuse`:

```
GPU[0] : GPU use (%): 98
```

Ollama is fully offloading inference to the Radeon 890M via ROCm. ✅

---

## Models Available

| Model | Size |
|-------|------|
| gemma4:26b | 17 GB |
| gemma4:e4b | 9.6 GB |

> `gemma4:31b` (19 GB) was removed with `ollama rm gemma4:31b`.

