Gemma 4 E4B running locally on a Ryzen AI 9 HX 470 mini-PC: 4.5B effective parameters, 128K context, full vLLM stack on ROCm 7.2 — verified Docker recipe inside.

Google DeepMind released the Gemma 4 family on 2 April 2026 under Apache 2.0. The E4B variant is a dense, decoder-only multimodal model with Per-Layer Embeddings — ~4.5B compute-active parameters but ~8–10 GB of weights in FP16. That makes it the right size for a 64 GiB UMA mini-PC.

The Minisforum AI X1 Pro pairs a 12-core Zen 5 CPU with the Radeon 890M iGPU (gfx1150, RDNA 3.5) and an XDNA 2 NPU rated at 86 TOPS. With ROCm 7.2 — the first stable release for gfx1150 production serving — vLLM serves Gemma 4 directly on the iGPU. The NPU stays free for an ONNX-RT or MIGraphX sidecar.

The trick that makes 128K context fit in a 16 GB-class memory budget: hybrid attention. Most layers use sliding-window attention with a 512-token window, so their KV cache stays constant in n. Only the periodic global layers grow with sequence length, and even those use unified K=V projections and proportional RoPE to halve the cost.

→ Verified working vLLM Docker command for ROCm 7.2 + gfx1150
→ KV-cache math for tuning 128K context on a 16 GB-class budget
→ When MIGraphX + ONNX-RT can offload to the XDNA 2 NPU
→ Quantisation choices and end-to-end benchmarking

Read the full guide:
https://ojitha.github.io/ai/2026/05/05/Gemma4.html

#Gemma4 #vLLM #ROCm #RyzenAI #GenerativeAI
