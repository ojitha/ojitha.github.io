---
layout: post
title:  Running AMD ROCm AI Workloads in Docker
date:   2026-03-07
maths: true
categories: [AI]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../../blog/assets/images/${filename}
excerpt: '<div class="image-text-container"><div class="image-column"><img src="https://raw.githubusercontent.com/ojitha/blog/master/assets/images/2026-03-07-ContainerRocm/rocm-container-ai.svg" alt="Scala Functors" width="150" height="150" /></div><div class="text-column">This guide demonstrates how to run AMD ROCm AI workloads on the MINISFORUM AI X1 Pro-470 mini PC powered by the AMD Ryzen AI 9 HX 470 (12-core Zen5, up to 5.2GHz), featuring the integrated Radeon 890M (gfx1150) GPU and an 86 TOPS NPU. Running Ubuntu with the OEM kernel, the setup covers installing ROCm 7.2, verifying HSA agents via <b>rocminfo</b>, and deploying PyTorch inside Docker containers. It also details configuring <b>MIGraphX</b> and <b>ONNX</b> Runtime with the MIGraphX Execution Provider via Docker Compose, enabling high-performance on-device ML inference — fully local, no discrete GPU required..</div></div>'
---

Brief introduction

<!--more-->

------

* TOC
{:toc}
------

## Introduction
**AI X1 Pro-470 form factor**[^5] is the **Zen5 12-core architecture**, the **86 TOPS NPU**, and the **Radeon 890M iGPU** — all of which directly contextualise why the OEM kernel requirement and ROCm APU-specific setup described in the post are necessary.

I have installed the rocm as explained in the documentation[^1]. 

> For ROCm on Ryzen, it is required to operate on the 6.14-1018 OEM kernel or newer.

I have installed:


```bash
uname -r
```

    6.17.0-14-generic


The install guide requires `--no-dkms` when running `amdgpu-install`, because **inbox drivers** (drivers built directly into the kernel) are required for ROCm on Ryzen APUs[^2]. 

The `oem` kernel flavour is maintained by Canonical's OEM team and contains **AMD-specific patches, and driver backports** that are not present in the mainline `generic` kernel. These include:

-   iGPU/APU-specific KFD (Kernel Fusion Driver) patches for Ryzen compute workloads
-   TTM shared memory management improvements AMD contributes to OEM kernels ahead of mainline
-   `amdgpu` inbox driver tuned for integrated graphics compute (gfx1100/gfx1151 series)

The `generic` kernel at 6.17 may not have these backports, even though it's a newer base version.

Check if the GPU is listed as an agent:


```bash
rocminfo
```

    ROCk module is loaded
    =====================    
    HSA System Attributes    
    =====================    
    Runtime Version:         1.18
    Runtime Ext Version:     1.15
    System Timestamp Freq.:  1000.000000MHz
    Sig. Max Wait Duration:  18446744073709551615 (0xFFFFFFFFFFFFFFFF) (timestamp count)
    Machine Model:           LARGE                              
    System Endianness:       LITTLE                             
    Mwaitx:                  DISABLED
    XNACK enabled:           NO
    DMAbuf Support:          YES
    VMM Support:             YES
    
    ==========               
    HSA Agents               
    ==========               
    *******                  
    Agent 1                  
    *******                  
      Name:                    AMD Ryzen AI 9 HX 470 w/ Radeon 890M
      Uuid:                    CPU-XX                             
      Marketing Name:          AMD Ryzen AI 9 HX 470 w/ Radeon 890M
      Vendor Name:             CPU                                
      Feature:                 None specified                     
      Profile:                 FULL_PROFILE                       
      Float Round Mode:        NEAR                               
      Max Queue Number:        0(0x0)                             
      Queue Min Size:          0(0x0)                             
      Queue Max Size:          0(0x0)                             
      Queue Type:              MULTI                              
      Node:                    0                                  
      Device Type:             CPU                                
      Cache Info:              
        L1:                      49152(0xc000) KB                   
      Chip ID:                 0(0x0)                             
      ASIC Revision:           0(0x0)                             
      Cacheline Size:          64(0x40)                           
      Max Clock Freq. (MHz):   5297                               
      BDFID:                   0                                  
      Internal Node ID:        0                                  
      Compute Unit:            24                                 
      SIMDs per CU:            0                                  
      Shader Engines:          0                                  
      Shader Arrs. per Eng.:   0                                  
      WatchPts on Addr. Ranges:1                                  
      Memory Properties:       
      Features:                None
      Pool Info:               
        Pool 1                   
          Segment:                 GLOBAL; FLAGS: FINE GRAINED        
          Size:                    57217068(0x369102c) KB             
          Allocatable:             TRUE                               
          Alloc Granule:           4KB                                
          Alloc Recommended Granule:4KB                                
          Alloc Alignment:         4KB                                
          Accessible by all:       TRUE                               
        Pool 2                   
          Segment:                 GLOBAL; FLAGS: EXTENDED FINE GRAINED
          Size:                    57217068(0x369102c) KB             
          Allocatable:             TRUE                               
          Alloc Granule:           4KB                                
          Alloc Recommended Granule:4KB                                
          Alloc Alignment:         4KB                                
          Accessible by all:       TRUE                               
        Pool 3                   
          Segment:                 GLOBAL; FLAGS: KERNARG, FINE GRAINED
          Size:                    57217068(0x369102c) KB             
          Allocatable:             TRUE                               
          Alloc Granule:           4KB                                
          Alloc Recommended Granule:4KB                                
          Alloc Alignment:         4KB                                
          Accessible by all:       TRUE                               
        Pool 4                   
          Segment:                 GLOBAL; FLAGS: COARSE GRAINED      
          Size:                    57217068(0x369102c) KB             
          Allocatable:             TRUE                               
          Alloc Granule:           4KB                                
          Alloc Recommended Granule:4KB                                
          Alloc Alignment:         4KB                                
          Accessible by all:       TRUE                               
      ISA Info:                
    *******                  
    Agent 2                  
    *******                  
      Name:                    gfx1150                            
      Uuid:                    GPU-XX                             
      Marketing Name:          AMD Radeon Graphics                
      Vendor Name:             AMD                                
      Feature:                 KERNEL_DISPATCH                    
      Profile:                 BASE_PROFILE                       
      Float Round Mode:        NEAR                               
      Max Queue Number:        128(0x80)                          
      Queue Min Size:          64(0x40)                           
      Queue Max Size:          131072(0x20000)                    
      Queue Type:              MULTI                              
      Node:                    1                                  
      Device Type:             GPU                                
      Cache Info:              
        L1:                      32(0x20) KB                        
        L2:                      2048(0x800) KB                     
      Chip ID:                 5390(0x150e)                       
      ASIC Revision:           5(0x5)                             
      Cacheline Size:          128(0x80)                          
      Max Clock Freq. (MHz):   3100                               
      BDFID:                   50432                              
      Internal Node ID:        1                                  
      Compute Unit:            16                                 
      SIMDs per CU:            2                                  
      Shader Engines:          1                                  
      Shader Arrs. per Eng.:   2                                  
      WatchPts on Addr. Ranges:4                                  
      Coherent Host Access:    FALSE                              
      Memory Properties:       APU
      Features:                KERNEL_DISPATCH 
      Fast F16 Operation:      TRUE                               
      Wavefront Size:          32(0x20)                           
      Workgroup Max Size:      1024(0x400)                        
      Workgroup Max Size per Dimension:
        x                        1024(0x400)                        
        y                        1024(0x400)                        
        z                        1024(0x400)                        
      Max Waves Per CU:        32(0x20)                           
      Max Work-item Per CU:    1024(0x400)                        
      Grid Max Size:           4294967295(0xffffffff)             
      Grid Max Size per Dimension:
        x                        2147483647(0x7fffffff)             
        y                        65535(0xffff)                      
        z                        65535(0xffff)                      
      Max fbarriers/Workgrp:   32                                 
      Packet Processor uCode:: 31                                 
      SDMA engine uCode::      14                                 
      IOMMU Support::          None                               
      Pool Info:               
        Pool 1                   
          Segment:                 GLOBAL; FLAGS: COARSE GRAINED      
          Size:                    12582912(0xc00000) KB              
          Allocatable:             TRUE                               
          Alloc Granule:           4KB                                
          Alloc Recommended Granule:2048KB                             
          Alloc Alignment:         4KB                                
          Accessible by all:       FALSE                              
        Pool 2                   
          Segment:                 GLOBAL; FLAGS: EXTENDED FINE GRAINED
          Size:                    12582912(0xc00000) KB              
          Allocatable:             TRUE                               
          Alloc Granule:           4KB                                
          Alloc Recommended Granule:2048KB                             
          Alloc Alignment:         4KB                                
          Accessible by all:       FALSE                              
        Pool 3                   
          Segment:                 GROUP                              
          Size:                    64(0x40) KB                        
          Allocatable:             FALSE                              
          Alloc Granule:           0KB                                
          Alloc Recommended Granule:0KB                                
          Alloc Alignment:         0KB                                
          Accessible by all:       FALSE                              
      ISA Info:                
        ISA 1                    
          Name:                    amdgcn-amd-amdhsa--gfx1150         
          Machine Models:          HSA_MACHINE_MODEL_LARGE            
          Profiles:                HSA_PROFILE_BASE                   
          Default Rounding Mode:   NEAR                               
          Default Rounding Mode:   NEAR                               
          Fast f16:                TRUE                               
          Workgroup Max Size:      1024(0x400)                        
          Workgroup Max Size per Dimension:
            x                        1024(0x400)                        
            y                        1024(0x400)                        
            z                        1024(0x400)                        
          Grid Max Size:           4294967295(0xffffffff)             
          Grid Max Size per Dimension:
            x                        2147483647(0x7fffffff)             
            y                        65535(0xffff)                      
            z                        65535(0xffff)                      
          FBarrier Max Size:       32                                 
        ISA 2                    
          Name:                    amdgcn-amd-amdhsa--gfx11-generic   
          Machine Models:          HSA_MACHINE_MODEL_LARGE            
          Profiles:                HSA_PROFILE_BASE                   
          Default Rounding Mode:   NEAR                               
          Default Rounding Mode:   NEAR                               
          Fast f16:                TRUE                               
          Workgroup Max Size:      1024(0x400)                        
          Workgroup Max Size per Dimension:
            x                        1024(0x400)                        
            y                        1024(0x400)                        
            z                        1024(0x400)                        
          Grid Max Size:           4294967295(0xffffffff)             
          Grid Max Size per Dimension:
            x                        2147483647(0x7fffffff)             
            y                        65535(0xffff)                      
            z                        65535(0xffff)                      
          FBarrier Max Size:       32                                 
    *******                  
    Agent 3                  
    *******                  
      Name:                    aie2p                              
      Uuid:                    AIE-XX                             
      Marketing Name:          RyzenAI-npu4                       
      Vendor Name:             AMD                                
      Feature:                 AGENT_DISPATCH                     
      Profile:                 BASE_PROFILE                       
      Float Round Mode:        NEAR                               
      Max Queue Number:        1(0x1)                             
      Queue Min Size:          64(0x40)                           
      Queue Max Size:          64(0x40)                           
      Queue Type:              SINGLE                             
      Node:                    0                                  
      Device Type:             DSP                                
      Cache Info:              
        L2:                      2048(0x800) KB                     
      Chip ID:                 0(0x0)                             
      ASIC Revision:           0(0x0)                             
      Cacheline Size:          0(0x0)                             
      Max Clock Freq. (MHz):   0                                  
      BDFID:                   0                                  
      Internal Node ID:        0                                  
      Compute Unit:            0                                  
      SIMDs per CU:            0                                  
      Shader Engines:          0                                  
      Shader Arrs. per Eng.:   0                                  
      WatchPts on Addr. Ranges:0                                  
      Memory Properties:       
      Features:                AGENT_DISPATCH
      Pool Info:               
        Pool 1                   
          Segment:                 GLOBAL; FLAGS: KERNARG, COARSE GRAINED
          Size:                    57217068(0x369102c) KB             
          Allocatable:             TRUE                               
          Alloc Granule:           4KB                                
          Alloc Recommended Granule:4KB                                
          Alloc Alignment:         4KB                                
          Accessible by all:       TRUE                               
        Pool 2                   
          Segment:                 GLOBAL; FLAGS: COARSE GRAINED      
          Size:                    65536(0x10000) KB                  
          Allocatable:             TRUE                               
          Alloc Granule:           4KB                                
          Alloc Recommended Granule:0KB                                
          Alloc Alignment:         4KB                                
          Accessible by all:       TRUE                               
        Pool 3                   
          Segment:                 GLOBAL; FLAGS: COARSE GRAINED      
          Size:                    57217068(0x369102c) KB             
          Allocatable:             TRUE                               
          Alloc Granule:           4KB                                
          Alloc Recommended Granule:4KB                                
          Alloc Alignment:         4KB                                
          Accessible by all:       TRUE                               
      ISA Info:                
    *** Done ***             


Your system has **3 HSA Agents** detected — a CPU, a GPU, and an NPU. Here's a breakdown:

* * *

### System-Level Attributes

| Attribute | Value | Meaning |
| --- | --- | --- |
| Runtime Version | 1.18 | ROCm HSA runtime installed and working |
| XNACK enabled | NO  | Page fault retry for GPU memory is off (normal for APUs) |
| DMAbuf Support | YES | GPU can share buffers with other devices via Linux DMA-buf |
| VMM Support | YES | Virtual Memory Management is supported |

* * *

### Agent 1 — CPU

**AMD Ryzen AI 9 HX 470 w/ Radeon 890M**

-   24 compute units, max clock 5297 MHz
-   Has 4 memory pools totalling ~55.7 GB (your system RAM), all accessible by all agents — this is the **unified memory** characteristic of an APU
-   Pool types cover Fine Grained, Extended Fine Grained, Kernarg, and Coarse Grained — used for different levels of CPU/GPU memory coherency

* * *

### Agent 2 — GPU ✅ (The important one for ROCm)

**AMD Radeon Graphics — `gfx1150`**

This is your Radeon 890M iGPU. Key specs:

| Property | Value |
| --- | --- |
| ISA Target | `amdgcn-amd-amdhsa--gfx1150` |
| Compute Units | 16  |
| SIMDs per CU | 2   |
| Max Clock | 3100 MHz |
| Wavefront Size | 32  |
| Max Workgroup Size | 1024 |
| Fast F16 | TRUE |
| Memory Pool | ~12 GB (shared from system RAM via TTM) |

Two important things to note:

-   **Memory Properties: `APU`** — confirms this is a unified memory APU, not a discrete GPU
-   **Two ISAs are registered**: `gfx1150` (exact target) and `gfx11-generic` (fallback) — this means ROCm kernels compiled for the generic gfx11 family will also run on your chip
-   **Accessible by all: FALSE** on GPU pools — GPU VRAM pools are not directly CPU-accessible without explicit mapping (normal APU behaviour despite unified memory)

* * *

### Agent 3 — NPU (Neural Processing Unit)

**RyzenAI-npu4 (`aie2p`)**

-   This is the **AMD XDNA NPU** (AI Engine 2+) embedded in the Ryzen AI 9 HX 470
-   Device type is `DSP`, feature is `AGENT_DISPATCH` (not `KERNEL_DISPATCH` like the GPU)
-   It uses system RAM pools but is **not a general-purpose compute target** for ROCm — it's used via the separate ONNX/Vitis AI runtime path
-   Max queue size is only 64 (single queue) — very different from the GPU's 128 queues



ROCm utilises a shared system memory pool and is configured by default to half the system memory.

> AMD recommends setting the minimum dedicated VRAM in the BIOS (0.5GB), and setting the TTM limit to a larger amount.

Using `amd-ttm --set <NUM>` set the shared memory. Current value is:


```bash
amd-ttm
```

    💻 Current TTM pages limit: 3145728 pages (12.00 GB)
    💻 Total system memory: 54.57 GB


You can clear the above settings by `amd-ttm --clear`.

I've updated the kernel to include Canonical drivers: `sudo apt update && sudo apt install linux-oem-24.04c`.

Verify the new oem version:


```bash
uname -r
```

    6.17.0-1012-oem


## Install PyTorch for ROCm
I used the Docker approach[^3] in his case, 



```bash
cat > docker-compose.yaml << 'EOF'
services:
  rocm-pytorch:
    image: rocm/pytorch:rocm7.2_ubuntu24.04_py3.12_pytorch_release_2.9.1
    stdin_open: true
    tty: true
    cap_add:
      - SYS_PTRACE
    security_opt:
      - seccomp=unconfined
    devices:
      - /dev/kfd
      - /dev/dri
    group_add:
      - video
    ipc: host
    shm_size: 8g
EOF
```

The key mappings from `docker run` flags:

| `docker run` flag | `docker-compose` key |
| --- | --- |
| `-it` | `stdin_open: true` + `tty: true` |
| `--cap-add` | `cap_add` |
| `--security-opt` | `security_opt` |
| `--device` | `devices` |
| `--group-add` | `group_add` |
| `--ipc` | `ipc` |
| `--shm-size` | `shm_size` |

You can run PyTorch using `docker compose run --rm rocm-pytorch`.

Verify if Pytorch is installed and is detecting the GPU compute device:


```bash
docker run --rm \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add video \
  --ipc=host \
  --shm-size 8G \
  rocm/pytorch:rocm7.2_ubuntu24.04_py3.12_pytorch_release_2.9.1 \
  bash -c "python3 -c 'import torch' 2> /dev/null && echo 'Success' || echo 'Failure'"
```

    Success


test if the GPU is available.


```bash
docker run --rm \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add video \
  --ipc=host \
  --shm-size 8G \
  rocm/pytorch:rocm7.2_ubuntu24.04_py3.12_pytorch_release_2.9.1 \
  bash -c "python3 -c 'import torch; print(torch.cuda.is_available())'"
```

    True


display installed GPU device name:


```bash
docker run --rm \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add video \
  --ipc=host \
  --shm-size 8G \
  rocm/pytorch:rocm7.2_ubuntu24.04_py3.12_pytorch_release_2.9.1 \
  bash -c 'python3 -c "import torch; print(f\"device name [0]:\", torch.cuda.get_device_name(0))"'
```

    device name [0]: AMD Radeon Graphics


display component information within the current PyTorch environment


```bash
docker run --rm \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add video \
  --ipc=host \
  --shm-size 8G \
  rocm/pytorch:rocm7.2_ubuntu24.04_py3.12_pytorch_release_2.9.1 \
  bash -c 'python3 -m torch.utils.collect_env'
```

    <frozen runpy>:128: RuntimeWarning: 'torch.utils.collect_env' found in sys.modules after import of package 'torch.utils', but prior to execution of 'torch.utils.collect_env'; this may result in unpredictable behaviour
    Collecting environment information...
    PyTorch version: 2.9.1+rocm7.2.0.git7e1940d4
    Is debug build: False
    CUDA used to build PyTorch: N/A
    ROCM used to build PyTorch: 7.2.26015-fc0010cf6a
    
    OS: Ubuntu 24.04.3 LTS (x86_64)
    GCC version: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0
    Clang version: Could not collect
    CMake version: Could not collect
    Libc version: glibc-2.39
    
    Python version: 3.12.3 (main, Jan  8 2026, 11:30:50) [GCC 13.3.0] (64-bit runtime)
    Python platform: Linux-6.17.0-1012-oem-x86_64-with-glibc2.39
    Is CUDA available: True
    CUDA runtime version: Could not collect
    CUDA_MODULE_LOADING set to: 
    GPU models and configuration: AMD Radeon Graphics (gfx1150)
    Nvidia driver version: Could not collect
    cuDNN version: Could not collect
    Is XPU available: False
    HIP runtime version: 7.2.26015
    MIOpen runtime version: 3.5.1
    Is XNNPACK available: True
    
    CPU:
    Architecture:                            x86_64
    CPU op-mode(s):                          32-bit, 64-bit
    Address sizes:                           48 bits physical, 48 bits virtual
    Byte Order:                              Little Endian
    CPU(s):                                  24
    On-line CPU(s) list:                     0-23
    Vendor ID:                               AuthenticAMD
    Model name:                              AMD Ryzen AI 9 HX 470 w/ Radeon 890M
    CPU family:                              26
    Model:                                   36
    Thread(s) per core:                      2
    Core(s) per socket:                      12
    Socket(s):                               1
    Stepping:                                0
    Frequency boost:                         enabled
    CPU(s) scaling MHz:                      47%
    CPU max MHz:                             5297.2979
    CPU min MHz:                             621.6220
    BogoMIPS:                                3992.31
    Flags:                                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm constant_tsc rep_good amd_lbr_v2 nopl xtopology nonstop_tsc cpuid extd_apicid aperfmperf rapl pni pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt tce topoext perfctr_core perfctr_nb bpext perfctr_llc mwaitx cpuid_fault cpb cat_l3 cdp_l3 hw_pstate ssbd mba perfmon_v2 ibrs ibpb stibp ibrs_enhanced vmmcall fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid cqm rdt_a avx512f avx512dq rdseed adx smap avx512ifma clflushopt clwb avx512cd sha_ni avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves cqm_llc cqm_occup_llc cqm_mbm_total cqm_mbm_local user_shstk avx_vnni avx512_bf16 clzero irperf xsaveerptr rdpru wbnoinvd cppc arat npt lbrv svm_lock nrip_save tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold avic v_vmsave_vmload vgif x2avic v_spec_ctrl vnmi avx512vbmi umip pku ospke avx512_vbmi2 gfni vaes vpclmulqdq avx512_vnni avx512_bitalg avx512_vpopcntdq rdpid bus_lock_detect movdiri movdir64b overflow_recov succor smca fsrm avx512_vp2intersect flush_l1d amd_lbr_pmc_freeze
    Virtualization:                          AMD-V
    L1d cache:                               576 KiB (12 instances)
    L1i cache:                               384 KiB (12 instances)
    L2 cache:                                12 MiB (12 instances)
    L3 cache:                                24 MiB (2 instances)
    NUMA node(s):                            1
    NUMA node0 CPU(s):                       0-23
    Vulnerability Gather data sampling:      Not affected
    Vulnerability Ghostwrite:                Not affected
    Vulnerability Indirect target selection: Not affected
    Vulnerability Itlb multihit:             Not affected
    Vulnerability L1tf:                      Not affected
    Vulnerability Mds:                       Not affected
    Vulnerability Meltdown:                  Not affected
    Vulnerability Mmio stale data:           Not affected
    Vulnerability Old microcode:             Not affected
    Vulnerability Reg file data sampling:    Not affected
    Vulnerability Retbleed:                  Not affected
    Vulnerability Spec rstack overflow:      Mitigation; IBPB on VMEXIT only
    Vulnerability Spec store bypass:         Mitigation; Speculative Store Bypass disabled via prctl
    Vulnerability Spectre v1:                Mitigation; usercopy/swapgs barriers and __user pointer sanitization
    Vulnerability Spectre v2:                Mitigation; Enhanced / Automatic IBRS; IBPB conditional; STIBP always-on; PBRSB-eIBRS Not affected; BHI Not affected
    Vulnerability Srbds:                     Not affected
    Vulnerability Tsa:                       Not affected
    Vulnerability Tsx async abort:           Not affected
    Vulnerability Vmscape:                   Mitigation; IBPB on VMEXIT
    
    Versions of relevant libraries:
    [pip3] numpy==2.4.1
    [pip3] torch==2.9.1+rocm7.2.0.lw.git7e1940d4
    [pip3] torchaudio==2.9.0+rocm7.2.0.gite3c6ee2b
    [pip3] torchvision==0.24.0+rocm7.2.0.gitb919bd0c
    [pip3] triton==3.5.1+rocm7.2.0.gita272dfa8
    [conda] Could not collect


## MIGraphX for Radeon GPUs
After ROCm installation (verified with PyTorch), the next step is to install MIGraphX, the graph inference engine that accelerates machine learning model inference and can be used to accelerate workloads within the Torch MIGraphX and ONNX Runtime backend frameworks.

```bash
sudo apt install migraphx
```

Verify the installation:


```bash
dpkg -l | grep migraphx
```

    ii  migraphx                                      2.15.0.70200-43~24.04                    amd64        AMD graph optimizer
    ii  migraphx-dev                                  2.15.0.70200-43~24.04                    amd64        AMD graph optimizer



```bash
dpkg -l | grep half
```

    ii  half                                          1.12.0.70200-43~24.04                    amd64        HALF-PRECISION FLOATING POINT LIBRARY


Perform a simple inference with MIGraphX to verify the installation:


```bash
/opt/rocm-7.2.0/bin/migraphx-driver perf --test
```

    Running [ MIGraphX Version: 2.15.0.20250912-17-195-g1afd1b89c ]: /opt/rocm-7.2.0/bin/migraphx-driver perf --test
    [2026-03-08 11:26:14]
    Compiling ... 
    module: "main"
    @0 = check_context::migraphx::gpu::context -> float_type, {}, {}
    main:#output_0 = @param:main:#output_0 -> float_type, {4, 3}, {3, 1}
    b = @param:b -> float_type, {5, 3}, {3, 1}
    a = @param:a -> float_type, {4, 5}, {5, 1}
    @4 = gpu::code_object[code_object=4656,symbol_name=mlir_dot,global=256,local=256,output_arg=2,](a,b,main:#output_0) -> float_type, {4, 3}, {3, 1}
    
    
    Allocating params ... 
    Running performance report ... 
    @0 = check_context::migraphx::gpu::context -> float_type, {}, {}: 0.00028068ms, 3%
    main:#output_0 = @param:main:#output_0 -> float_type, {4, 3}, {3, 1}: 0.00022842ms, 3%
    b = @param:b -> float_type, {5, 3}, {3, 1}: 0.0002194ms, 3%
    a = @param:a -> float_type, {4, 5}, {5, 1}: 0.00021078ms, 3%
    @4 = gpu::code_object[code_object=4656,symbol_name=mlir_dot,global=256,local=256,output_arg=2,](a,b,main:#output_0) -> float_type, {4, 3}, {3, 1}: 0.00880674ms, 91%
    
    Summary:
    gpu::code_object::mlir_dot: 0.00880674ms / 1 = 0.00880674ms, 91%
    @param: 0.0006586ms / 3 = 0.000219533ms, 7%
    check_context::migraphx::gpu::context: 0.00028068ms / 1 = 0.00028068ms, 3%
    
    Batch size: 1
    Rate: 83845.5 inferences/sec
    Total time: 0.0119267ms (Min: 0.011309ms, Max: 0.022467ms, Mean: 0.0125111ms, Median: 0.0119195ms)
    Percentiles (90%, 95%, 99%): (0.013382ms, 0.016197ms, 0.021636ms)
    Total instructions time: 0.00974602ms
    Overhead time: 0.00045574ms, 0.00218068ms
    Overhead: 4%, 18%
    [2026-03-08 11:26:15]
    [ MIGraphX Version: 2.15.0.20250912-17-195-g1afd1b89c ] Complete(0.945651s): /opt/rocm-7.2.0/bin/migraphx-driver perf --test


## ONNX
Open Neural Network Exchange (ONNX)[^4] is an open standard format for representing machine learning models, originally created by Microsoft and Meta in 2017 and now governed by the Linux Foundation. The Core Problem It Solves:

Every ML framework (PyTorch, TensorFlow, JAX, scikit-learn) has its own internal model format. Without ONNX, a model trained in PyTorch cannot be directly deployed in a TensorFlow serving environment. ONNX acts as a universal interchange format — train anywhere, deploy anywhere.

```
PyTorch ──┐
TensorFlow─┤──► ONNX model (.onnx) ──► Any runtime / hardware
JAX ───────┘
```

Key Concepts
    - **ONNX Model** — a `.onnx` file that encodes the model's computation graph (nodes, edges, operators) in a hardware-agnostic way using Google's Protocol Buffers.
    - **ONNX Operators** — a standardised set of operations (Conv, MatMul, ReLU, etc.) that all compliant frameworks must support.
    - **ONNX Runtime (ORT)** — Microsoft's high-performance inference engine for `.onnx` models. It is separate from the ONNX format itself and is what you install via `pip install onnxruntime`.

**Execution Providers (EPs)** — ORT's plugin system for hardware acceleration. Rather than running on the CPU by default, EPs delegate computation to specific hardware:

| Execution Provider | Hardware |
| --- | --- |
| `CPUExecutionProvider` | Any CPU |
| `MIGraphXExecutionProvider` | AMD ROCm GPUs (via MIGraphX) |
| `ROCMExecutionProvider` | AMD ROCm GPUs (direct) |
| `CUDAExecutionProvider` | NVIDIA CUDA GPUs |
| `TensorrtExecutionProvider` | NVIDIA TensorRT |
| `CoreMLExecutionProvider` | Apple Silicon |

Typical workflow:

1. Train model in PyTorch
2. Export to ONNX
   
```python
        torch.onnx.export(model, dummy_input, "model.onnx")
```
   
3. Run inference via ONNX Runtime
   
```python
       sess = ort.InferenceSession("model.onnx",
                 providers=["MIGraphXExecutionProvider"])
       output = sess.run(None, {"input": data})
```

> AMD Radeon 890M (`gfx1150`), the **MIGraphX EP** compiles the ONNX graph using AMD's MIGraphX graph optimiser at inference time, fusing operators and generating GPU-optimised kernels — giving you significantly better performance than the CPU fallback.
{:.green}

Here is the Dockerfile:


```bash
cat > Dockerfile << 'EOF'
FROM rocm/pytorch:rocm7.2_ubuntu24.04_py3.12_pytorch_release_2.9.1

# Install MIGraphX (prerequisite for ONNX Runtime MIGraphX EP)
RUN apt-get update && apt-get install -y \
    migraphx \
    migraphx-dev \
    half \
    && rm -rf /var/lib/apt/lists/*

# Downgrade numpy (v2.0 is incompatible with onnxruntime-migraphx wheels)
RUN pip3 install numpy==1.26.4

# Install ONNX Runtime with MIGraphX Execution Provider
RUN pip3 uninstall -y onnxruntime-migraphx || true && \
    pip3 install onnxruntime-migraphx -f https://repo.radeon.com/rocm/manylinux/rocm-rel-7.2/

WORKDIR /workspace
EOF
```

create a docker compose file to make things easier:


```bash
cat > docker-compose.yaml << 'EOF'
services:
  rocm-onnx:
    build: .
    image: rocm-onnx:rocm7.2
    cap_add:
      - SYS_PTRACE
    security_opt:
      - seccomp=unconfined
    devices:
      - /dev/kfd
      - /dev/dri
    group_add:
      - video
    ipc: host
    shm_size: 8g
    volumes:
      - ./workspace:/workspace
EOF
```

The `volumes` mount maps a local `./workspace` directory into the container so you can drop `.onnx` model files there and run inference without rebuilding the image.
Build the Docker instance using the above files: `docker compose build`.

To verify:


```bash
docker compose run --rm rocm-onnx \
  python3 -c "import onnxruntime as ort; print(ort.get_available_providers())"
```

    [?25l[0G[+] create 1/1
     ✔ Network blogs_default Created                                            0.0s
    [?25h[?25l[2A[0G[+]  1/1
     ✔ Network blogs_default Created                                            0.0s
    [?25hContainer blogs-rocm-onnx-run-315e1fcece42 Creating 
    Container blogs-rocm-onnx-run-315e1fcece42 Created 
    ['MIGraphXExecutionProvider', 'CPUExecutionProvider']


Verify MIGraphX works:


```bash
docker compose run --rm rocm-onnx \
  /opt/rocm-7.2.0/bin/migraphx-driver perf --test
```

    Container blogs-rocm-onnx-run-9472d6713026 Creating 
    Container blogs-rocm-onnx-run-9472d6713026 Created 
    Running [ MIGraphX Version: 2.15.0.20250912-17-195-g1afd1b89c ]: /opt/rocm-7.2.0/bin/migraphx-driver perf --test
    [2026-03-08 00:36:46]
    Compiling ... 
    module: "main"
    @0 = check_context::migraphx::gpu::context -> float_type, {}, {}
    main:#output_0 = @param:main:#output_0 -> float_type, {4, 3}, {3, 1}
    b = @param:b -> float_type, {5, 3}, {3, 1}
    a = @param:a -> float_type, {4, 5}, {5, 1}
    @4 = gpu::code_object[code_object=4656,symbol_name=mlir_dot,global=256,local=256,output_arg=2,](a,b,main:#output_0) -> float_type, {4, 3}, {3, 1}
    
    
    Allocating params ... 
    Running performance report ... 
    @0 = check_context::migraphx::gpu::context -> float_type, {}, {}: 0.00028054ms, 3%
    main:#output_0 = @param:main:#output_0 -> float_type, {4, 3}, {3, 1}: 0.00022022ms, 3%
    b = @param:b -> float_type, {5, 3}, {3, 1}: 0.0002111ms, 3%
    a = @param:a -> float_type, {4, 5}, {5, 1}: 0.00020764ms, 3%
    @4 = gpu::code_object[code_object=4656,symbol_name=mlir_dot,global=256,local=256,output_arg=2,](a,b,main:#output_0) -> float_type, {4, 3}, {3, 1}: 0.0089923ms, 91%
    
    Summary:
    gpu::code_object::mlir_dot: 0.0089923ms / 1 = 0.0089923ms, 91%
    @param: 0.00063896ms / 3 = 0.000212987ms, 7%
    check_context::migraphx::gpu::context: 0.00028054ms / 1 = 0.00028054ms, 3%
    
    Batch size: 1
    Rate: 99657.6 inferences/sec
    Total time: 0.0100344ms (Min: 0.009097ms, Max: 0.03133ms, Mean: 0.0133908ms, Median: 0.009989ms)
    Percentiles (90%, 95%, 99%): (0.025579ms, 0.026391ms, 0.029907ms)
    Total instructions time: 0.0099118ms
    Overhead time: 0.00045108ms, 0.00012256ms
    Overhead: 4%, 1%
    [2026-03-08 00:36:46]
    [ MIGraphX Version: 2.15.0.20250912-17-195-g1afd1b89c ] Complete(0.666102s): /opt/rocm-7.2.0/bin/migraphx-driver perf --test


[^1]: [Install Ryzen Software for Linux with ROCm](https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/install/installryz/native_linux/install-ryzen.html){:target="_blank"}

[^2]: [amd](https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/install/installryz/native_linux/install-ryzen.html){:target="_blank"}

[^3]: [Install PyTorch for ROCm ](https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/install/installrad/native_linux/install-pytorch.html){:target="_blank"}

[^4]: [Install ONNX Runtime for Radeon GPUs — Use ROCm on Radeon and Ryzen](https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/install/installrad/native_linux/install-onnx.html){:target="_blank"}

[^5]: [MINISFORUM AI X1 Pro Mini PC](https://au.minisforum.com/products/minisforum-ai-x1-pro-470){:target="_blank"}


{:gtxt: .message color="green"}
{:ytxt: .message color="yellow"}
{:rtxt: .message color="red"}

```bash

```
