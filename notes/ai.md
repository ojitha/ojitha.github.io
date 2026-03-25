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

