---
layout: post
title:  Claude Extended Thinking on Amazon Bedrock
date: 2026-09-21
categories: [AI, Claude, AWS]
toc: true
mermaid: true
maths: true
typora-root-url: /User/ojitha/Github/ojitha.github.io
typora-copy-images-to: ../../blog/assets/images/${filename}
---

{% include video-summary.html
   id="xSAgNrgIvp0"
   content="<p>The provided text explains <strong>extended thinking</strong> for Claude models on <strong>Amazon Bedrock</strong>, a feature that allows the AI to use a dedicated internal &quot;scratchpad&quot; to process complex logic before generating a final answer. This mechanism improves performance for <strong>multi-step reasoning</strong> and technical tasks, though it increases <strong>latency and costs</strong> as reasoning tokens are billed as output. Modern Claude models utilise <strong>adaptive thinking</strong> to manage this process, while older versions require a manual token budget. For security, these internal monologues are protected by <strong>cryptographic signatures</strong> to prevent tampering during multi-turn conversations. Developers are encouraged to use <strong>quantitative evaluations</strong> to determine if the accuracy gains of extended thinking justify the additional resource consumption. Ultimately, the feature decouples <strong>internal problem decomposition</strong> from customer-facing text, ensuring cleaner and more logical responses.</p>" %}

<!--more-->

* TOC
{:toc}

---

## Extended thinking

Extended thinking gives Claude dedicated tokens to work through intermediate reasoning before outputting a final answer. Modern Claude models employ adaptive thinking with soft effort guidance, whereas earlier models rely on fixed token budgets. Reasoning output includes cryptographic signatures to prevent tampering in multi-turn contexts or encrypted payloads when flagged by safety systems. Always drive the decision to enable extended thinking with quantitative prompt evaluations to ensure the latency and cost additions yield proportional accuracy gains[^course].

---

-- rubric-driven AI judge --

A **quantitative prompt evaluation**{:gtxt} is a repeatable experiment, not a spot-check of a few outputs. Freeze a representative test set with a written success criterion. Score every run with the most objective method available: functional-correctness or exact-match checks where a ground truth exists, and a rubric-driven AI judge only where it doesn't[^A01]. Run the set once as a baseline with thinking off, then again with thinking on at more than one effort or budget setting. Record accuracy together with p50/p95 latency and cost per request, since the decision is about the trade-off rather than accuracy alone[^A02]. Reasoning-model practice treats verifiable scoring (answer parsing plus a checker) as a prerequisite for knowing whether extra reasoning helps at all.[^A03]

> Two cautions apply. Thinking runs at temperature 1.0 (see Parameter Restrictions), so outputs vary; run each item several times and report a mean and spread. Also, the open-ended demo prompt later in this post (key-value vs. document store) has no single correct answer, so it would need a rubric or judge rather than exact match. A practical summary metric is cost per correct answer with and without thinking.
{:.warn}

---

### Why and When to Use Extended Thinking (and When Not To)

Standard LLM generation forces models to produce output tokens sequentially without a dedicated draft space. _For complex mathematical derivations, multi-step system architectures, or subtle policy analysis, models can commit to sub-optimal reasoning paths early in the response generation_{:gtxt}. Standard autoregressive language models output tokens sequentially according to left-to-right conditional probability distributions, committing greedily or via sampling to early token selections without the ability to backspace or revise previous outputs. When faced with complex reasoning tasks, this token-by-token generation forces the model to solve high-entropy intermediate logic in the same step it formulates user-facing text, leading to error propagation and structural hallucinations [^2]. Extended thinking implements test-time compute allocation by introducing an internal scratchpad prior to generating final output tokens.

Test-time (inference-time) compute is the idea that answer quality can improve by spending more computation while answering, not only by training a larger model. Two families of technique exist:

1. One samples several candidate answers and selects among them (best-of-N, majority voting/self-consistency, or scoring with a verifier). 
2. The other has the model generate a longer sequential chain of reasoning tokens before it commits to an answer[^A04],[^A05].

> Extended thinking belongs to the second family. The "scratchpad" is ordinary generated text, so more thinking means more decoding steps, more latency and more cost. That is why it works as a dial you tune per task rather than a free upgrade. Returns also diminish, and they vary by task type, which is the reason the evaluation step above matters.
{:.ok} 

Decoupling intermediate problem decomposition (planning, state search, and self-correction) from final response generation enables the model to explore reasoning trees and verify logical consistency before emitting customer-facing text [^3]. Extended thinking solves this by giving Claude an internal monologue to work through complex problems prior to returning its final output.


We should evaluate extended thinking under specific conditions:

- **Complex multi-step logic:** Tasks requiring spatial reasoning, non-trivial algorithmic design, or legal and compliance analysis.
- **Prompt engineering limits:** Cases where prompt refinement, few-shot examples, and structural XML tags fail to meet required accuracy targets.
   Think of this as a ladder of cheaper levers to exhaust first: clear and explicit instructions, sufficient context, decomposing the task into simpler subtasks, and asking the model to reason step by step[^A06]. _Explicit chain-of-thought prompting is the manual precursor of extended thinking_{:gtxt}. It asks for the reasoning inside the visible output, whereas extended thinking moves it into a dedicated block that the API returns and signs separately.

   Two practical consequences follow:

   - If your prompts already say "think step by step," test whether removing that instruction changes accuracy or cost once thinking is on.
   - _A separate reasoning block keeps the final text block clean to parse, which inline chain-of-thought does not_{:gtxt}.

   The same reason-then-act idea underlies agent frameworks, which interleave reasoning with tool calls.[^A07]
- **Debugging requirement:** When transparency into the model's intermediate logic helps identify edge-case failures or wrong assumptions.

Conversely, avoid extended thinking for:

- **Simple factual lookups or translations:** Tasks where direct generation already achieves near-perfect accuracy.
- **Strict low-latency constraints:** Real-time applications like interactive voice agents or chat widgets where responsiveness supersedes deep reasoning.
- **Default global configuration:** Enabling thinking across all application prompts without evaluation data inflates token consumption without guaranteed benefits.


### Request and Response Structure

When extended thinking is enabled, Bedrock returns two distinct content blocks instead of a single text stream: a reasoning content block followed by the standard text response block.[^course]

```
 +-----------------------------------------------------------------------------------+
 |                                                                                   |
 |                             HOW EXTENDED THINKING WORKS                           |
 |                                                                                   |
 |   +-------------------+              +--------------------+                       |
 |   |                   |   Request    |                    |                       |
 |   |    User Prompt    | ------------>|    Claude Model    |                       |
 |   |                   |              | (Thinking Enabled) |                       |
 |   +-------------------+              +--------------------+                       |
 |                                                |                                  |
 |                                                | Generates 2-Part Response        |
 |                                                v                                  |
 |   +---------------------------------------------------------------------------+   |
 |   |                             CLAUDE RESPONSE                               |   |
 |   |                                                                           |   |
 |   |  +---------------------------------------------------------------------+  |   |
 |   |  | PART 1: REASONING CONTENT PART                                      |  |   |
 |   |  | [ Block Type: reasoning_content ]                                   |  |   |
 |   |  |                                                                     |  |   |
 |   |  |   * Claude's internal thinking process                              |  |   |
 |   |  |   * Step-by-step problem breakdown & considerations                 |  |   |
 |   |  |   * Internal monologue / "Scratchpad" transparency                  |  |   |
 |   |  |   * Signed cryptographically for security                           |  |   |
 |   |  +---------------------------------------------------------------------+  |   |
 |   |                                     |                                     |   |
 |   |                                     v Then outputs                        |   |
 |   |  +---------------------------------------------------------------------+  |   |
 |   |  | PART 2: TEXT PART                                                   |  |   |
 |   |  | [ Block Type: text ]                                                |  |   |
 |   |  |                                                                     |  |   |
 |   |  |   * The final response you actually wanted                          |  |   |
 |   |  |   * Clean, customer-facing output or answer                         |  |   |
 |   |  +---------------------------------------------------------------------+  |   |
 |   |                                                                           |   |
 |   +---------------------------------------------------------------------------+   |
 +-----------------------------------------------------------------------------------+
```


Figure 1: Claude processes requests by generating internal reasoning content before rendering the final text response.[^image-1]

### Adaptive Thinking vs. Manual Token Budgets

Model generations handle thinking configuration differently based on architectural model versions:

1. **Adaptive Thinking (Claude Sonnet 5, Opus 5):** On modern Claude models, adaptive thinking is enabled by default. The model dynamically adjusts its reasoning token usage based on request difficulty. Developers pass `type: "adaptive"` and `display: "summarized"` inside the request payload, adjusting the `effort` parameter to provide soft allocation guidance rather than managing hard token limits. Example:

    ```json
    additional_model_fields["thinking"] = {
        "type": "adaptive",
        "display": "summarized"
    }
    ```

2. **Manual Token Budgets (Claude 4.5 and earlier):** Legacy models like Claude Sonnet 4.5, Haiku 4.5, and Opus 4.5 require explicit configuration via `type: "enabled"` and a user-defined `budget_tokens` parameter, which carries a minimum requirement of 1024 tokens.

> Note that manual token budgets are deprecated on Claude Sonnet 4.6 and Opus 4.6, and will return an HTTP 400 error on Claude Opus 4.7 and 5-series models.[^course]
{:.warn}

### The Cryptographic Signature System and Redacted Content

To maintain conversational safety, Bedrock attaches a cryptographic signature to every generated reasoning block[^course]. In stateless LLM API architectures like Amazon Bedrock, multi-turn interactions require client applications to pass previous conversation history back to the model on every subsequent request. Because reasoning content blocks expose intermediate internal monologue tokens, malicious actors could tamper with historical thinking blocks—injecting jailbreaks, bypassing safety filters, or altering agent state history before sending the payload back in Turn 2 [^7]. Bedrock mitigates this attack vector by appending an HMAC (Hardware MAC) signature generated using AWS backend secret keys over the reasoning block payload. 

A message authentication code (MAC) is a keyed hash. Whoever holds the secret key can compute a short tag over a message, and nobody without the key can produce a valid tag for a message of their choosing. The textbook use case matches this design closely. A server hands a client state it doesn't want to store (a "stateless cookie") along with a tag, then recomputes the tag over whatever the client sends back. Any edit to the payload makes verification fail[^A08].

Bedrock's reasoning-block signature plays the same role. The API is stateless, so the client carries the reasoning back on the next turn, and only the service holds the key needed to validate it.

Know the limits of this guarantee:

-   A MAC provides integrity and authenticity, not confidentiality, which is why redacted reasoning is additionally encrypted.
-   It does not prove freshness, so an unmodified block can be replayed[^A08].
-   The signature therefore blocks editing of reasoning history. It does not by itself stop prompt injection arriving through user messages or tool results, which still needs input and output validation.

During subsequent turns, Bedrock validates the signature to confirm cryptographic integrity before processing conversation context, thereby preventing prompt injection and history tampering across API boundaries [^4]. When building multi-turn applications, re-submitting historical reasoning blocks requires passing the exact signature back to Bedrock to verify the text was not tampered with.

If Claude's reasoning triggers safety or content filters during execution, Bedrock returns a `redactedContent`[^1] structure instead of plaintext reasoning. This redacted block contains an encrypted payload that preserves context when sent back in multi-turn conversations without exposing raw reasoning text to developers.

```mermaid
graph LR
    A["Turn 1 Request"] --> B["Claude Generation"]
    B --> C["Reasoning Block + Signature / Redacted"]
    C --> D["Turn 2 Request Payload"]
    D --> E["Signature Validated by Bedrock"]
```
Figure 2: Re-submitting reasoning blocks across multi-turn exchanges requires preserving cryptographic signatures or encrypted redacted payloads intact.

### Latency and Cost Trade-offs

Extended thinking impacts runtime efficiency in two ways:

- **Latency:** Because the model generates thinking tokens before outputting the final answer, total response latency increases proportionally with reasoning length.[^course]
    
    An LLM produces one token per forward pass, so decoding time grows with the number of output tokens. A useful mental model is total latency ≈ time to first token (prompt processing) + output tokens × time per output token.[^A09]

    _Thinking tokens are output tokens_. A 2,000-token reasoning trace at the same decode speed therefore delays the first user-visible answer token by a proportional amount. Streaming a summarized trace can improve perceived responsiveness, but it does not shorten total latency.

    Cost follows the same logic. Providers typically price output tokens above input tokens, and _thinking tokens are billed as output_{:rtxt}.[^A10] When you evaluate, measure time to the first answer token, the tail of the latency distribution (p95/p99), and cost per request, not just averages.

- **Billing:** Billed usage includes all generated reasoning tokens in addition to the final text response tokens.[^course]

## Example with Claude Haiku-4-5

To enable extended thinking, you have to configure 

```python
# Modern Adaptive Thinking (Claude 5+)
additional_model_fields["thinking"] = {
    "type": "adaptive",
    "display": "summarized"  # Reveals reasoning text
}

# Legacy Manual Budget (Claude 4.5 and earlier)
additional_model_fields["thinking"] = {
    "type": "enabled",
    "budget_tokens": 1024   # Minimum requirement is 1024 tokens
}
```

As shown in the following code, the extended thinking is defined in the `AppSettings` class which is compatible with the Claude 4.5:

```python
...
    thinking_budget: int = Field(default=2048, ge=1024)
    max_tokens: int = Field(default=4096, ge=1024)
...    
```

Later use that in the `ReasoningBlock` to define the _Legacy Manual Budget (Claude 4.5 and earlier)_:

```python
    additional_fields = {
        "thinking": {
            "type": "enabled",
            "budget_tokens": cfg.thinking_budget,
        }
    }
```

Problem:

Recursive graph traversals require navigating node-edge relationships across arbitrary depths, which fundamentally conflicts with non-relational storage paradigms. In a distributed Key-Value store, each graph edge lookup requires individual key GET requests (or batched read operations), leading to sequential round trips across cluster nodes for a graph of branching factor b and depth d, creating severe N+1 query overhead and network amplification[^5]. Conversely, Document Stores allow hierarchical denormalization by embedding adjacency lists or sub-graphs directly within single JSON documents. While denormalization drastically reduces network round trips for bounded depths, it introduces write amplification, storage bloat, and concurrency bottlenecks during edge updates, requiring careful trade-off evaluations between read latency SLAs and mutation frequency[^6].





```python
"""Demonstration of Claude extended thinking on Amazon Bedrock using boto3 and Pydantic.

Required packages:
    boto3>=1.34.0
    pydantic>=2.0.0
    pydantic-settings>=2.0.0
"""

import json
import sys
from typing import Any, Dict, Optional
import boto3
from botocore.exceptions import ClientError
from pydantic import BaseModel, Field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class AppSettings(BaseSettings):
    """Configuration settings for Bedrock API requests.

    Guards against invalid AWS parameters and illegal token budget allocations
    before invoking remote API endpoints.
    """

    aws_region: str = Field(default="ap-southeast-2", validation_alias="AWS_REGION")
    model_id: str = Field(
        default="au.anthropic.claude-haiku-4-5-20251001-v1:0",
        validation_alias="BEDROCK_MODEL_ID",
    )
    thinking_budget: int = Field(default=2048, ge=1024)
    max_tokens: int = Field(default=4096, ge=1024)

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @model_validator(mode="after")
    def validate_budget_limit(self) -> "AppSettings":
        """Ensure total max tokens exceeds the thinking budget."""
        if self.max_tokens <= self.thinking_budget:
            raise ValueError(
                f"max_tokens ({self.max_tokens}) must be strictly greater than "
                f"thinking_budget ({self.thinking_budget})."
            )
        return self


class ReasoningBlock(BaseModel):
    """Schema for parsing reasoning output blocks.

    Guards against malformed model response payloads and ensures required
    response attributes exist.
    """

    thinking_text: Optional[str] = None
    signature: Optional[str] = None
    redacted_content: Optional[str] = None
    final_text: str = ""


def generate_with_thinking(
    prompt: str, settings: Optional[AppSettings] = None
) -> ReasoningBlock:
    """Sends a request to Claude on Bedrock with extended thinking enabled.

    Args:
        prompt: The user prompt to send to the model.
        settings: Optional application settings instance.

    Returns:
        ReasoningBlock containing parsed thinking and final text content.
    """
    cfg = settings or AppSettings()

    # We use boto3 as it is the standard AWS SDK for Bedrock, providing direct
    # access to the Bedrock Runtime Converse API without extra SDK dependencies.
    client = boto3.client("bedrock-runtime", region_name=cfg.aws_region)

    messages = [{"role": "user", "content": [{"text": prompt}]}]

    additional_fields = {
        "thinking": {
            "type": "enabled",
            "budget_tokens": cfg.thinking_budget,
        }
    }

    try:
        response = client.converse(
            modelId=cfg.model_id,
            messages=messages,
            inferenceConfig={"maxTokens": cfg.max_tokens, "temperature": 1.0},
            additionalModelRequestFields=additional_fields,
        )
    except ClientError as err:
        print(f"Bedrock API error: {err}", file=sys.stderr)
        raise

    output_message = response.get("output", {}).get("message", {})
    content_blocks = output_message.get("content", [])

    thinking_str = None
    sig_str = None
    redacted_str = None
    text_str = ""

    for block in content_blocks:
        if "reasoningContent" in block:
            reasoning = block["reasoningContent"]
            if "reasoningText" in reasoning:
                thinking_str = reasoning["reasoningText"].get("text")
                sig_str = reasoning["reasoningText"].get("signature")
            elif "redactedContent" in reasoning:
                redacted_str = str(reasoning["redactedContent"])
        elif "text" in block:
            text_str += block["text"]

    return ReasoningBlock(
        thinking_text=thinking_str,
        signature=sig_str,
        redacted_content=redacted_str,
        final_text=text_str,
    )

```

### Code Explanation

1. **`AppSettings` Model:** Inherits from `BaseSettings` to load environment configurations. The `@model_validator` enforces that `max_tokens` is strictly greater than `thinking_budget` before remote calls are made.
2. **`ReasoningBlock` Model:** Validates structure upon receiving response blocks from Bedrock, ensuring optional fields (`thinking_text`, `signature`, `redacted_content`) map safely without key errors.
3. **API Invocation:** Uses `client.converse` passing `additionalModelRequestFields` to convey the `thinking` dictionary. The loop iterates over `content` parts, differentiating `reasoningContent` from standard `text` blocks.

Let us examin the `AppSettings`:


```python
AppSettings.model_json_schema()  # Generate JSON schema for AppSettings
```




    {'description': 'Configuration settings for Bedrock API requests.\n\nGuards against invalid AWS parameters and illegal token budget allocations\nbefore invoking remote API endpoints.',
     'properties': {'AWS_REGION': {'default': 'ap-southeast-2',
       'title': 'Aws Region',
       'type': 'string'},
      'BEDROCK_MODEL_ID': {'default': 'au.anthropic.claude-haiku-4-5-20251001-v1:0',
       'title': 'Bedrock Model Id',
       'type': 'string'},
      'thinking_budget': {'default': 2048,
       'minimum': 1024,
       'title': 'Thinking Budget',
       'type': 'integer'},
      'max_tokens': {'default': 4096,
       'minimum': 1024,
       'title': 'Max Tokens',
       'type': 'integer'}},
     'title': 'AppSettings',
     'type': 'object'}



| **Feature / Model Generation** | **Claude Opus 5 (& Sonnet 5)** | **Claude Opus 4.7** | **Claude Opus 4.5 and Earlier** |
| --- | --- | --- | --- |
| **Adaptive Thinking Support** | Supported (On by default) | Supported | Not supported |
| **Configuration Type (`type`)** | `"adaptive"` | `"adaptive"` | `"enabled"` |
| **Budget Control Mechanism** | Guided via soft `effort` parameter | Guided via soft `effort` parameter | Hard manual `budget_tokens` (Min: 1,024) |
| **Manual Budget Request Handling** | **Rejected** (returns 400 Error) | **Rejected** (returns 400 Error) | **Required** to enable thinking |
| **Reasoning Display** | Omitted by default; set `display: "summarized"` to view | Set via `display` configuration | Returned in reasoning content block |
| **JSON Configuration Payload** | `{"thinking": {"type": "adaptive", "display": "summarized"}}` | `{"thinking": {"type": "adaptive", "effort": "..."}}` | `{"thinking": {"type": "enabled", "budget_tokens": 1024}}` |


```python
# example
test_prompt = (
    "Analyze the latency and cost implications of running recursive "
    "graph traversals in a distributed key-value store versus a document store."
)
result = generate_with_thinking(test_prompt)
if result.thinking_text:
    print("--- Reasoning Process ---")
    print(result.thinking_text)
    if result.signature:
        print(f"Signature: {result.signature[:20]}...")
elif result.redacted_content:
    print("--- Reasoning Process Encrypted (Redacted) ---")

print("\n--- Final Answer ---")
print(result.final_text)
```

    --- Reasoning Process ---
    This is a great technical question about distributed systems, specifically comparing two database paradigms when performing recursive graph traversals. Let me break this down comprehensively.
    
    I need to consider:
    1. Latency characteristics of each approach
    2. Cost implications (compute, storage, network)
    3. The specific challenge of recursive graph traversals
    4. Real-world trade-offs
    
    Let me structure a thorough analysis with concrete examples and metrics.
    Signature: ErQFCoQBCBIQARgCKkBG...
    
    --- Final Answer ---
    # Recursive Graph Traversals: KV Store vs Document Store Analysis
    
    ## Latency Profile Comparison
    
    ### Key-Value Store Pattern
    
    ```python
    # KV Store: Multi-hop traversal
    class KVGraphTraversal:
        def traverse_recursive(self, start_node, depth=0, max_depth=5):
            """
            Typical KV traversal pattern
            """
            if depth > max_depth:
                return []
            
            results = []
            # Hop 1: Get node
            node = self.kv_store.get(f"node:{start_node}")
            
            if not node:
                return []
            
            results.append(node)
            
            # Hop 2+: Get each edge
            edge_ids = json.loads(node['edges'])
            
            for edge_id in edge_ids:
                # LATENCY PENALTY: N+1 queries
                edge = self.kv_store.get(f"edge:{edge_id}")
                target = edge['target']
                
                # Recursive call = additional round trips
                results.extend(
                    self.traverse_recursive(target, depth + 1, max_depth)
                )
            
            return results
    
    # Latency breakdown for depth-3 graph with branching factor 3
    # Node 1: 1 fetch
    # Edges (3): 3 fetches
    # Node 2-4: 3 fetches
    # Edges (9): 9 fetches
    # Node 5-13: 9 fetches
    # TOTAL: 25+ requests, sequential or batched
    ```
    
    **Latency Impact:**
    - **Depth-1**: 2 round-trips (1 node + N edges)
    - **Depth-3, BF=3**: 13 round-trips = ~260-390ms @ 20-30ms per hop
    - **Network latency dominates**
    
    ### Document Store Pattern
    
    ```python
    # Document Store: Denormalized approach
    class DocGraphTraversal:
        def traverse_recursive(self, start_node, depth=0, max_depth=5):
            """
            Document store with embedded relationships
            """
            if depth > max_depth:
                return []
            
            results = []
            
            # Single fetch includes nested data
            doc = self.doc_store.find_one({
                '_id': start_node,
                # Projection to limit nested depth
                'neighbors': {
                    '$slice': 100  # Limit array size
                }
            })
            
            if not doc:
                return []
            
            results.append(doc)
            
            # Traverse embedded neighbors
            for neighbor in doc.get('neighbors', []):
                results.extend(
                    self.traverse_recursive(neighbor['id'], depth + 1)
                )
            
            return results
    
    # Document with embedded relationships (MongoDB example)
    example_doc = {
        "_id": "node-1",
        "data": "...",
        "neighbors": [
            {
                "id": "node-2",
                "weight": 0.8,
                "neighbors": [  # Pre-fetched
                    {"id": "node-5", "weight": 0.9},
                    {"id": "node-6", "weight": 0.7}
                ]
            },
            # ... more neighbors
        ]
    }
    ```
    
    **Latency Impact:**
    - **Single fetch** with partial nesting = 30-50ms
    - **Then recursive traversal on local data** = microseconds per hop
    - **Bounded by network latency of initial fetch**
    
    ## Detailed Cost Analysis
    
    ### Network Cost
    
    ```python
    # KV Store network amplification
    def calculate_kv_cost(depth, branching_factor, record_size_kb=1):
        """Network costs for KV traversal"""
        
        # Number of nodes at each level
        total_requests = sum(branching_factor**d for d in range(depth))
        
        # Each node fetch: ~1KB header + record
        # Each edge fetch: ~200 bytes header + edge
        network_cost_mb = (
            total_requests * (1 + 0.2) * record_size_kb / 1024
        )
        
        # Round-trips (critical bottleneck)
        round_trips = depth  # Minimum, with batching
        latency_ms = round_trips * 30  # 30ms per RT
        
        return {
            'network_mb': network_cost_mb,
            'latency_ms': latency_ms,
            'requests': total_requests
        }
    
    # Document Store denormalization cost
    def calculate_doc_cost(depth, branching_factor, denorm_factor=0.8):
        """
        Denormalization bloat vs. fetch efficiency
        """
        # Embedded data increases document size
        # But reduces requests dramatically
        
        bloat_multiplier = 1 + (branching_factor * denorm_factor * depth * 0.1)
        doc_size_kb = 100 * bloat_multiplier  # Instead of 1KB per fetch
        
        # Single or dual fetch needed
        network_mb = doc_size_kb / 1024
        latency_ms = 35  # Primarily single round-trip
        
        return {
            'network_mb': network_mb,
            'latency_ms': latency_ms,
            'storage_bloat': f'{(bloat_multiplier - 1) * 100:.1f}%'
        }
    
    # Example: Depth 3, BF 3
    kv_costs = calculate_kv_cost(3, 3, record_size_kb=1)
    doc_costs = calculate_doc_cost(3, 3)
    
    print("KV Store:", kv_costs)  
    # {'network_mb': 0.043, 'latency_ms': 90, 'requests': 40}
    
    print("Document Store:", doc_costs)  
    # {'network_mb': 0.118, 'latency_ms': 35, 'storage_bloat': '23.1%'}
    ```
    
    ### Compute Cost Breakdown
    
    ```python
    class CostAnalysis:
        """Compare total cost of ownership"""
        
        @staticmethod
        def kv_store_tco(monthly_queries=1_000_000, avg_depth=3):
            """Key-value store TCO"""
            
            # Requests per query
            requests_per_query = 40  # depth-3, BF-3 example
            total_requests = monthly_queries * requests_per_query
            
            costs = {
                'read_units': total_requests * 0.001,  # DynamoDB units
                'read_cost_usd': total_requests * 0.0000002,  # $0.2 per million
                'storage_gb': 500,  # lean storage
                'storage_cost_usd': 500 * 0.25,  # $0.25/GB
                'network_gb': monthly_queries * 0.04 / 1024,
                'network_cost_usd': (monthly_queries * 0.04 / 1024) * 0.12,
                'compute_cost_usd': 200,  # app servers handling N+1
            }
            
            costs['total_monthly'] = sum([
                costs['read_cost_usd'],
                costs['storage_cost_usd'],
                costs['network_cost_usd'],
                costs['compute_cost_usd']
            ])
            
            return costs
        
        @staticmethod
        def doc_store_tco(monthly_queries=1_000_000, avg_depth=3):
            """Document store TCO"""
            
            costs = {
                'read_units': monthly_queries * 5,  # Fewer but larger reads
                'read_cost_usd': (monthly_queries / 1_000_000) * 5 * 1.25,
                'storage_gb': 800,  # 60% larger due to denormalization
                'storage_cost_usd': 800 * 0.25,
                'network_gb': monthly_queries * 0.12 / 1024,
                'network_cost_usd': (monthly_queries * 0.12 / 1024) * 0.12,
                'compute_cost_usd': 100,  # Less compute for graph logic
            }
            
            costs['total_monthly'] = sum([
                costs['read_cost_usd'],
                costs['storage_cost_usd'],
                costs['network_cost_usd'],
                costs['compute_cost_usd']
            ])
            
            return costs
    
    # Results
    kv_tco = CostAnalysis.kv_store_tco()
    doc_tco = CostAnalysis.doc_store_tco()
    
    print("KV Store TCO: ${:.2f}".format(kv_tco['total_monthly']))
    # Output: KV Store TCO: $325.48
    
    print("Document Store TCO: ${:.2f}".format(doc_tco['total_monthly']))
    # Output: Document Store TCO: $303.82
    ```
    
    ## Hybrid Optimization Strategy
    
    ```python
    class HybridGraphStore:
        """Best of both worlds approach"""
        
        def __init__(self, kv_store, doc_store, cache_layer):
            self.kv = kv_store
            self.doc = doc_store
            self.cache = cache_layer
        
        def traverse_optimized(self, start_node, depth=0, max_depth=3):
            """
            Hybrid strategy:
            - Depth 0-1: Use document store (embedded)
            - Depth 2+: Use KV store with batching
            """
            
            # Try cache first
            cache_key = f"graph:{start_node}:depth:{max_depth}"
            cached = self.cache.get(cache_key)
            if cached:
                return cached
            
            if depth <= 1:
                # Document store: fast single fetch
                doc = self.doc.find_one({
                    '_id': start_node,
                    'level_0_edges': 1,
                    'level_1_edges': 1
                })
                results = [doc]
            else:
                # KV store: efficient for deep traversal with batching
                results = self._batch_traverse_kv(start_node, depth, max_depth)
            
            self.cache.set(cache_key, results, ttl=3600)
            return results
        
        def _batch_traverse_kv(self, node_id, depth, max_depth):
            """Batch KV reads to reduce round-trips"""
            
            if depth > max_depth:
                return []
            
            # Get current node
            current = self.kv.get(f"node:{node_id}")
            if not current:
                return []
            
            results = [current]
            edge_ids = json.loads(current.get('edges', '[]'))
            
            # Batch fetch all edges
            edges = self.kv.mget([f"edge:{e}" for e in edge_ids])
            
            # Extract targets and batch fetch those
            targets = [e['target'] for e in edges if e]
            next_nodes = self.kv.mget([f"node:{t}" for t in targets])
            results.extend(next_nodes)
            
            # Recurse on each
            for node in next_nodes:
                if node:
                    results.extend(
                        self._batch_traverse_kv(
                            node['_id'], depth + 1, max_depth
                        )
                    )
            
            return results
    ```
    
    ## Decision Matrix
    
    | Factor | KV Store | Document Store | Winner |
    |--------|----------|-----------------|--------|
    | **Latency (depth-3)** | 90-120ms | 35-50ms | **Doc Store** |
    | **Network Calls** | 40+ | 2-3 | **Doc Store** |
    | **Storage Cost** | Low (500GB) | High (800GB) | **KV Store** |
    | **Update Complexity** | Simple | Complex (denorm) | **KV Store** |
    | **Query Flexibility** | High | Low | **KV Store** |
    | **Cache Efficiency** | Medium | High | **Doc Store** |
    | **Developer Experience** | Tedious | Intuitive | **Doc Store** |
    
    ## Recommendations
    
    ### Use KV Store when:
    - **Graph is highly dynamic** (frequent mutations)
    - **Update patterns are unpredictable**
    - **Storage costs critical** (IoT, metrics)
    - **Query patterns vary widely**
    
    ### Use Document Store when:
    - **Read-heavy workloads** (80/20+ read/write)
    - **Bounded graph depth** (max 3-4 levels)
    - **Latency SLA < 50ms**
    - **Graph structure stable**
    
    ### Use Hybrid when:
    - **Mixed workload** with both deep and wide traversals
    - **Budget for both storage and latency**
    - **Can accept operational complexity**
    
    The decision ultimately hinges on **write-to-read ratio** and **acceptable latency**—document stores excel at reads but suffer on updates, while KV stores provide flexibility at the cost of latency and developer ergonomics.


## Pitfalls and Constraints

- **Modifying Reasoning Text:** Editing reasoning text in conversation history invalidates its cryptographic signature, causing API rejections in subsequent turns.
- **Hardcoding Manual Budgets:** Relying solely on `budget_tokens` will break applications when migrating to Claude 5 adaptive thinking models.
- **Skipping Evaluation Baselines:** Enabling extended thinking without prior prompt evaluation makes it impossible to verify whether output quality gains justify added costs.

### Token Budget Inequality Constraint

Let $T_{\text{max}}$ be the maximum total output tokens permitted (`max_tokens`) and $T_{\text{budget}}$ be the designated thinking token budget (`budget_tokens`). To ensure adequate token allowance remains for generating the final response text, we must enforce:

$$ T_{\text{max}} > T_{\text{budget}} $$

where $T_{\text{max}}$ represents total output capacity and $T_{\text{budget}}$ represents the reasoning allocation limit . Setting $T_{\text{max}} \le T_{\text{budget}}$ results in request failures or truncated answer outputs.

### Streaming Thinking Output

When invoking model streams on Bedrock with extended thinking, reasoning tokens arrive in distinct `thinking_delta` event chunks prior to the primary text response stream. Applications must assemble streaming reasoning tokens separately from standard text deltas.

### Tool Use and Multi-Turn Interactions

In agentic workflows involving tool calls, thinking blocks are generated prior to outputting tool request schemas. An agent loop works like this. The model emits a tool request, your code executes it, you append the result, and you call the model again, repeating until it returns a final answer[^A11]. Because Bedrock is stateless, each call must resend the full history. With thinking enabled, that history includes the reasoning blocks (signed or redacted) from the turn that requested the tool.

Keeping them lets the model continue the plan it formed before the tool call instead of re-deriving it. This mirrors the ***reason–act–observe pattern*** used by agent frameworks[A12]. In practice, append the assistant message exactly as returned, with all content blocks in their original order. _Do not filter it down to only the `text` and `toolUse` blocks, then add the `toolResult` message_{:.message color="brown"}. 

When building tool response loops, the model's intermediate thinking blocks, signatures, or redacted blocks must be retained in history to preserve context state across tool turns.

### Parameter Restrictions

At each step an LLM produces a probability distribution over the next token, and the sampling strategy decides how one token is drawn from it. Temperature rescales the logits before the softmax: lower values sharpen the distribution toward greedy decoding, and higher values flatten it. `Top-k` and `top-p` (nucleus) sampling truncate the candidate set to the $k$ most likely tokens, or to the smallest set whose cumulative probability exceeds `p`[^A13],[^A14].

With thinking enabled, the provider pins temperature at 1.0 and restricts truncation. This likely protects the reasoning trace from being distorted by reshaping the model's native distribution, though it is worth checking the current Bedrock documentation for exact per-model limits.

There are two consequences:

-   You cannot get deterministic behaviour by lowering temperature, so measure variance with repeated runs.
-   The same prompt can yield reasoning traces of different lengths, and therefore different latency and cost[^A13].

> When extended thinking is enabled, sampling controls like `temperature` must remain set to `1.0` (or omitted), while custom `top_p` or `top_k` settings are disabled or restricted by the model provider.
{:.ok}

### Cost Accounting

All thinking tokens count directly toward output token consumption and are billed at the standard model output rate.

## Key Takeaways

- Extended thinking improves model accuracy on complex logic by exposing an internal reasoning process.
- Use adaptive thinking (`type: "adaptive"`) for modern Claude models, reserving manual token budgets (`budget_tokens >= 1024`) for legacy architectures.
- Preserve cryptographic signatures and redacted blocks without modification when appending history in multi-turn conversations.
- Always validate performance through prompt evaluations before rolling out extended thinking to production.



[^course]: Anthropic Academy, "Extended thinking," [Claude with Amazon Bedrock](https://academy.claude.com/courses/claude-with-amazon-bedrock/extended-thinking){:target="_blank" rel="noopener noreferrer"}.

[^image-1]: [with thinking image](https://academy.claude.com/assets/media/7737b60029d867e83be1ad7abaea1c521cfb6cedbbad66a74b5560b6aed71a0e.png){:target="_blank" rel="noopener noreferrer"}

[^1]: [Redacted Content](https://academy.claude.com/courses/claude-with-amazon-bedrock/extended-thinking#redacted-content){:target="_blank" rel="noopener noreferrer"}

[^2]: "Chapter 3: Large Language Model Architectures and Inference" in Generative AI on AWS by Chris Fregly, Antje Barth, and Shelbee Eigenbrode (O'Reilly, 2023).

[^3]: "Chapter 6: Chain-of-Thought and Advanced Reasoning Patterns" in Prompt Engineering for Generative AI by James Phoenix and Mike Taylor (O'Reilly, 2024).

[^7]: "Chapter 7: Security and Privacy in LLM Applications" in Building LLM-Powered Applications by Valentino Zocca (O'Reilly, 2024).

[^4]: "Chapter 8: Securing LLM Applications and Infrastructure" in Developing Apps with GPT-4 and ChatGPT 
by Olivier Caelen and Marie-Alice Blete (O'Reilly, 2023).

[^5]: "Chapter 2: Data Models and Query Languages" in Designing Data-Intensive Applications by Martin Kleppmann (O'Reilly, 2017).

[^6]: "Chapter 6: Partitioning" in Designing Data-Intensive Applications by Martin Kleppmann (O'Reilly, 2017).

[^A01]: "Chapter 3: Evaluation Methodology" (sections "Exact Evaluation" and "AI as a Judge") in [AI Engineering](https://www.oreilly.com/library/view/ai-engineering/9781098166298/ch03.html){:target="_blank" rel="noopener noreferrer"} by Chip Huyen (O'Reilly, 2025). 

[^A02]: "Chapter 4: Evaluate AI Systems" (sections "Cost and Latency" and "Design Your Evaluation Pipeline") in [AI Engineering](https://www.oreilly.com/library/view/ai-engineering/9781098166298/ch04.html){:target="_blank" rel="noopener noreferrer"} by Chip Huyen (O'Reilly, 2025).

[^A03]: "Chapter 3: Evaluating Reasoning Models" in [Build a Reasoning Model (From Scratch)](https://learning.oreilly.com/library/view/-/9781633434677/){:target="_blank" rel="noopener noreferrer"} by Sebastian Raschka (Manning, 2026).

[^A04]: "Chapter 2: Understanding Foundation Models" (section "Test Time Compute") in [AI Engineering](https://www.oreilly.com/library/view/ai-engineering/9781098166298/ch02.html){:target="_blank" rel="noopener noreferrer"} by Chip Huyen (O'Reilly, 2025).

[^A05]: "Chapter 4: Improving Reasoning with Inference-Time Scaling" in [Build a Reasoning Model (From Scratch)](https://learning.oreilly.com/library/view/-/9781633434677/){:target="_blank" rel="noopener noreferrer"} by Sebastian Raschka (Manning, 2026).

[^A06]: "Chapter 5: Prompt Engineering" (section "Give the Model Time to Think") in [AI Engineering](https://www.oreilly.com/library/view/ai-engineering/9781098166298/ch05.html){:target="_blank" rel="noopener noreferrer"} by Chip Huyen (O'Reilly, 2025).

[^A07]: "Chapter 6: Autonomous Agents with Memory and Tools" in [Prompt Engineering for Generative AI](https://www.oreilly.com/library/view/prompt-engineering-for/9781098153427/ch06.html){:target="_blank" rel="noopener noreferrer"} by James Phoenix and Mike Taylor (O'Reilly, 2024).

[^A08]: "Chapter 3: Message Authentication Codes" (sections 3.1 "Stateless cookies, a motivating example for MACs", 3.3 "Security properties of a MAC", 3.5.1 "HMAC") in [Real-World Cryptography](https://www.oreilly.com/library/view/real-world-cryptography/9781617296710/Text/ch03_Wong.htm){:target="_blank" rel="noopener noreferrer"} by David Wong (Manning, 2021).

[^A09]: "Chapter 9: Inference Optimization" (section "Inference Performance Metrics") in [AI Engineering](https://www.oreilly.com/library/view/ai-engineering/9781098166298/ch09.html){:target="_blank" rel="noopener noreferrer"} by Chip Huyen (O'Reilly, 2025).

[^A10]: "Chapter 4: Evaluate AI Systems" (section "Cost and Latency") in [AI Engineering](https://www.oreilly.com/library/view/ai-engineering/9781098166298/ch04.html){:target="_blank" rel="noopener noreferrer"} by Chip Huyen (O'Reilly, 2025). 

[^A11]: "Chapter 6: RAG and Agents" (sections "Tools" and "Planning") in [AI Engineering](https://www.oreilly.com/library/view/ai-engineering/9781098166298/ch06.html){:target="_blank" rel="noopener noreferrer"} by Chip Huyen (O'Reilly, 2025).

[^A12]: "Chapter 6: Autonomous Agents with Memory and Tools" in [Prompt Engineering for Generative AI](https://www.oreilly.com/library/view/prompt-engineering-for/9781098153427/ch06.html){:target="_blank" rel="noopener noreferrer"} by James Phoenix and Mike Taylor (O'Reilly, 2024).

[^A13]: "Chapter 2: Understanding Foundation Models" (sections "Sampling Fundamentals", "Sampling Strategies" and "The Probabilistic Nature of AI") in [AI Engineering](https://www.oreilly.com/library/view/ai-engineering/9781098166298/ch02.html){:target="_blank" rel="noopener noreferrer"} by Chip Huyen (O'Reilly, 2025).

[^A14]: "Chapter 2: A Deep Dive into the OpenAI API" (section "Playing with temperature and top\_p") in [Developing Apps with GPT-4 and ChatGPT, 2nd Edition](https://www.oreilly.com/library/view/developing-apps-with/9781098168094/ch02.html){:target="_blank" rel="noopener noreferrer"} by Olivier Caelen and Marie-Alice Blete (O'Reilly, 2024).

{:gtxt: .message color="green"}

{:ytxt: .message color="yellow"}

{:rtxt: .message color="red"}

