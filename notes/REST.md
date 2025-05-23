---
layout: notes
title: REST
mermaid: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

# Notes on REST
{:.no_toc}

---

* TOC
{:toc}

---

## Richardson Maturity Model

1. Level 0: Swamp of POX
    - Use HTTP to tunnel through. Ex: SOAP, XML-RPC
    - Usually use HTTP POST
2. Level 1: Resources
    - Multiple URIs to distinguish releated nouns. Ex: /person/1
3. Level 2: HTTP Verbs
    - Leverage transport-native properties to enhance service.
    - Use idimatic HTTP controls like status codes and headers
4. Level 3: Hypermedia Controls (HATEOAS)
    - No a prior knowledge of service required. Navigation is provided by service and hypermodia controls.
    - Promotes longevity through a uniform interface.

For more information, visit [Richardson Maturity Model](https://martinfowler.com/articles/richardsonMaturityModel.html).

## GitHub REST access
Before accessing the GitHub API[^1], it is better to authenticate first to increase the rate limit. You can get the access token from the GitHub App.

Before running the following REST access, I've exported the GITHUB_TOKEN environment variable.

```bash
curl --request GET \
--url "https://api.github.com/repos/ojitha/learn-ai" \
--header "Accept: application/vnd.github+json" \
--header "Authorization: Bearer $GITHUB_TOKEN"
```

If you are passing JWT, you must use `Authorization: Bearer`.

GitHub recommends using the built-in `GITHUB_TOKEN` instead of creating a token (what I did above is not the recommended way).
{:.warning}



Above command, you can run in the Powershell as follows

```powershell
Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/ojitha/learn-ai" -Headers @{
    "Accept" = "application/vnd.github+json"
    "Authorization" = "Bearer $env:GITHUB_TOKEN"
}
```



```bash
curl --request GET \
--url "https://api.github.com/events?per_page=2&page=1" \
--header "Accept: application/vnd.github+json" \
--header "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/events

```



## Monitoring network traffic

Any machine that communicates over the network has at least one network adapter. All the components between this adapter and an application form a networking stack[^5]: a set of networking components that process and move networking traffic. In traditional scenarios, the networking stack is small, and all the packet routing and switching happens in external devices.

![[Microsoft: networking stack](https://learn.microsoft.com/en-us/windows-server/networking/technologies/pktmon/media/networking-stack.png)](https://learn.microsoft.com/en-us/windows-server/networking/technologies/pktmon/media/networking-stack.png)

However, with the advent of network virtualization, the size of the networking stack has multiplied.

![[Microsoft: network virtualisation](https://learn.microsoft.com/en-us/windows-server/networking/technologies/pktmon/media/packet-capture.png)](https://learn.microsoft.com/en-us/windows-server/networking/technologies/pktmon/media/packet-capture.png)

Packet Monitor intercepts packets at multiple locations throughout the networking stack, exposing the packet route. The microsoft tool **pktmon**[^6] supports TXT log analysis based on **TcpDump** packet parsing.

Network interfaces are built to perform filtering, not to overwhelm the receiving operating system. They check the media access control (MAC) address in the frame's destination[^2]. 

The frame is the *layer two headers* for communication on the local, physical network. If the destination MAC address (belongs to IP) matches the address associated with the network interface (the physical address), the associated packet is forwarded to the OS. 

To find network interfaces:

```bash
tcpdump -D
```

![tcpdump network interfaces](/assets/images/REST/tcpdump_network_interfaces.jpg)

> To run tcpdump, you need sudo access.

### tcpdump

You can run tcpdump[^4] on the br-xxx(from the above command, find the bridge interface) interface for Docker:

```bash
tcpdump -i br-1eb30f278167
```

![tcpdump On Interface](/assets/images/REST/tcpdumpOnInterface.jpg)

Berkeley Packet Filters (BPF) to limit. BPF is a simple language that indicates elements of packets you want to filter on.

For example, if you want to see only the network traffic for the GitHub API

```bash
sudo tcpdump host 4.237.22.34
```

Use the `nslookup api.github.io` to get the above IP address. Only for source or destination use `src` or `dst` instead of `host`.

### tshark

In many cases, the host will have one more interface. For example in the WSL:

```bash
ip link
```

![ip link](/assets/images/REST/ubuntu_ip_link.jpg)

you can use following command to find the route for example in the docker:

```bash
ip route
```

For example, see how ubuntu and the dockers are bound on the

![Docker connect to Ubuntu via network interface](/assets/images/REST/Docker_connect_to_Ubuntu_via interface.jpg)

To find all scanable interfaces, Tshark also provides the `-D` or `--list-interfaces` arguments that will list all scannable interfaces.

```bash
tshark -D
```

To run on the above interface:

```bash
tshark -i br-1eb30f278167
```

![tshark run on interface](/assets/images/REST/tshark_run_on_interface.jpg)

If you are runing a docker the better command is:

```bash
ip -brie a  | grep br- | awk '{print $1}' | xargs tshark -i
```

Above is the bridge network where dockers are connected.

To save to the file:

```bash
tshark -w FILENAME.pcap -i br-1eb30f278167
```

To read the file

```bash
tshark -r FILENAME.pcap
```

To export in JSON:

```bash
tshark -T json -i br-1eb30f278167
```

If you only want `http`:

```bash
tshark -f "port http" -i br-1eb30f278167
```

```bash
tshark -f "icmp[icmptype]==icmp-echo" -i br-1eb30f278167
```

You can use tshark the same way you can use tpcdump.

```bash
sudo tshark host 4.237.22.34
```

To display only specific fields in tshark, you can use the switch `-Tfields`[^3].

```bash
tshark -Tfields -e ip.src
```

At a high level, 

1. When initiating a TCP connection between a client and server, the client sends the server a "SYN" request, asking for a connection to be established. 
2. Once the server has processed the response, a "SYN-ACK" response is sent back to the client, acknowledging receipt. 
3. The client answers with an "ACK," and communication is established once the server receives it. This three-phase sequence of events is called the TCP 3-way handshake.

```mermaid
sequenceDiagram
    participant Client
    participant Server
    
    Note over Client,Server: TCP 3-Way Handshake
    
    Client->>Server: 1. SYN: Synchronize
    Note right of Client: Client initiates connection<br>with synchronization request
    
    Server->>Client: 2. SYN-ACK: Synchronize-Acknowledge
    Note left of Server: Server acknowledges and<br>sends its own synchronization
    
    Client->>Server: 3. ACK: Acknowledge
    Note right of Client: Client acknowledges<br>server's synchronization
    
    Note over Client,Server: Connection Established
```



### nmap

To install

```bash
sudo apt install nmap -y
```

*TCP Connect Scan* uses the full TCP 3-way handshake to establish a connection to a host and see what ports are: 

| State           | Comment                                                      |
| :-------------- | :----------------------------------------------------------- |
| Open            | Service that is accepting TCP, UDP, SCTP packets.            |
| Closed          | A port with no active service taking requests.               |
| Filtered        | Unable to differentiate as the packets are being filtered, preventing the probes from reaching the port. |
| Open/Filtered   | Unable to determine between Open or Filtered and occurs when open ports typically do not give a response. |
| Closed/Filtered | Unable to determine between Closed or Filtered.              |

#### TCP Connect Scan (-sT)

*TCP Connect Scan* uses the full TCP 3-way handshake to establish a connection to a host:

```bash
nmap -sT 4.237.22.34
```



![nmap on Github](/assets/images/REST/nmap_on_Github.jpg)

To limit the ports

```bash
nmap -sT -p 1-100 4.237.22.34
```

The following are the TCP connection scans:

| Status   | Response                | Comment                                   |
| :------- | :---------------------- | :---------------------------------------- |
| Open     | TCP SYN-ACK             | The service is listening on the port.     |
| Closed   | TCP RST                 | The service is not listening on the port. |
| Filtered | No response from target | The port is firewalled.                   |

#### TCP SYN Scan (-sS)

*TCP SYN Scan* is the most popular scan when using Nmap and is often called "half-open scanning".

For TCP SYN use `-sS` insted of `-sT`.

| Status   | Response                                                | Comment                                   |
| :------- | :------------------------------------------------------ | :---------------------------------------- |
| Open     | TCP SYN-ACK                                             | The service is listening on the port.     |
| Closed   | TCP RST                                                 | The Service is not listening on the port. |
| Filtered | No response from target or ICMP destination unreachable | The port is firewalled.                   |

For the specific port:

```bash
nmap -sS -p 443 4.237.22.34
```

![TCP SYN Scan](/assets/images/REST/TCP_SYN_Scan.jpg)

#### TCP FIN Scan (-sF)

Use TCP FIN Scan if a firewall has spotted a SYN or TCP Connect scan. This type of scan sends a FIN packet to a target port and expects an RST packet back. If the port is open, it would have ignored the FIN packet; however, if the port is closed, an RST packet is sent.

```bash
sudo nmap -sF -p 443 4.237.22.34
```

![TCP FIN Scan](/assets/images/REST/TCP_FIN_Scan.jpg)

Status codes can be marked as follows:

| Status        | Response                        | Comment                              |
| :------------ | :------------------------------ | :----------------------------------- |
| Filtered      | ICMP unreachable error received | Closed port should respond with RST. |
| Closed        | RST packet received             | Closed port should respond with RST. |
| Open/Filtered | No response received            | Open port should drop FIN.           |

#### Host discovery

By default, the scan sends an ICMP echo request, TCP SYN to port 443, TCP ACK to port 80, and an ICMP timestamp request.

```bash
 sudo nmap -sn 4.237.22.34
```

![nmap Host scanning](/assets/images/REST/nmap_Host_scanning.jpg)





[^1]: [Quickstart for GitHub REST API - GitHub Docs](https://docs.github.com/en/rest/quickstart?apiVersion=2022-11-28)

[^2]: [Interactive Lab: Security Testing and Monitoring with Kali Linux: Capturing Network Traffic Using tcpdump](https://learning.oreilly.com/interactive-lab/security-testing-and/9781098110857/lab/)

[^3]: [Wireshark · Display Filter Reference: Index](https://www.wireshark.org/docs/dfref/)

[^4]: [tcpdump(1) man page | TCPDUMP & LIBPCAP](https://www.tcpdump.org/manpages/tcpdump.1.html)

[^5]: [Packet Monitor (Pktmon) | Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/networking/technologies/pktmon/pktmon)

[^6]: [Pktmon command formatting | Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/networking/technologies/pktmon/pktmon-syntax)