---
layout: notes 
title: Artificial Intelligence
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

---

* TOC
{:toc}

---

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

