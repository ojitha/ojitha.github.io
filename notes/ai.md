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
