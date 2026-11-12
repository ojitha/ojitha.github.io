---
layout: post
title:  "LangChain Agent on Bedrock"
date: 2026-11-07
categories: [AI, AWS, LangChain]
toc: true
mermaid: true
maths: false
typora-root-url: /User/ojitha/Github/ojitha.github.io
typora-copy-images-to: ../../blog/assets/images/${filename}
---
{% include video-summary.html
   id="ZvMqxxKkTuo"
   content="<p>This post provides a comprehensive technical walkthrough for constructing <strong>LangChain agents on AWS Bedrock</strong> using <code>uv</code> package management and foundation models such as Anthropic Claude, OpenAI, and Google Gemma via the Bedrock Converse API. It compares lightweight <strong>ReAct agents (</strong> <strong>create_agent</strong> <strong>)</strong> designed for single-purpose tasks against feature-rich <strong>deep agents (</strong> <strong>create_deep_agent</strong> <strong>)</strong>. Furthermore, the guide details <strong>short-term memory checkpoints</strong> and demonstrates optimizing <strong>Model Context Protocol (MCP)</strong> tool execution via <strong>&quot;Code Mode&quot;</strong>, presenting tools as sandbox-executed code wrappers to preserve data privacy, enable control loops, and decrease token waste by up to <strong>98.7%</strong>.</p>" %}

<!--more-->

* TOC
{:toc}

## Agent on Bedrock

Here is my current pyproject.toml:

```
[project]
name = "learn-langgraph"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.12.11"
dependencies = [
    "email-validator>=2.3.0",
    "instructor>=1.11.2",
    "ipykernel>=6.30.1",
    "jupyter>=1.1.1",
    "langchain-openai>=0.3.32",
    "langgraph>=0.6.6",
    "langgraph-cli[inmem]>=0.4.1",
    "pydantic-ai>=1.0.1",
    "python-dotenv>=1.1.1",
]
```

Before add new packages update the python environment to latest:


```python
!uv lock --upgrade
!uv sync
```

    Resolved 217 packages in 329ms                                       
    Resolved 217 packages in 4ms
    Checked 211 packages in 2ms


After installation, here the latest running packages:


```python
!uv tree --depth 1
```

    Resolved 217 packages in 1ms
    learn-langgraph v0.1.0
    ├── email-validator v2.3.0
    ├── instructor v1.17.0
    ├── ipykernel v7.4.0
    ├── jupyter v1.1.1
    ├── langchain-openai v1.7.4
    ├── langgraph v1.2.20
    ├── langgraph-cli[inmem] v0.4.42
    ├── pydantic-ai v2.38.0
    └── python-dotenv v1.2.4


Install LangChain’s AWS package and use the Bedrock Converse provider. It reads the credentials you already set up in `~/.aws`, so you don’t need an API key in your code.


```python
!uv add langchain
```

    Resolved 218 packages in 971ms                                       
    Prepared 1 package in 22ms                                                   langchain            ------------------------------ 167.64 KiB/167.64 KiB       [1A[1A
    Installed 1 package in 2ms                                  
     + langchain==1.4.9


Without the `langchain` module, you cannot access the `init_chat_model`:


```python
from langchain.chat_models import init_chat_model
```

To access bedrock models, need `langchain-aws` package installed:


```python
!uv add langchain-aws
```

    Resolved 224 packages in 156ms                                       
    Prepared 4 packages in 807ms                                                 numpy                ------------------------------ 15.67 MiB/15.95 MiB         [1Anumpy                ------------------------------ 14.55 MiB/15.95 MiB         [2Anumpy                ------------------------------ 268.34 KiB/15.95 MiB        [3A[3A[2A[2A[2A[2A[2A[2A[2A[2A[2A[2A[2A[2A[2A[2A[1A
    Uninstalled 1 package in 1ms
    Installed 7 packages in 23ms                                
     + boto3==1.43.126
     + botocore==1.43.126
     + jmespath==1.1.0
     + langchain-aws==1.9.2
     + numpy==2.5.4
     - python-dateutil==4.0.0
     + python-dateutil==2.9.0.post0
     + s3transfer==0.19.3


### Bedrock Model

You have to find the Anthropic model.

Let's find all the available models in the `ap-southeast-2`:


```python
!aws bedrock list-foundation-models --by-provider anthropic --query "modelSummaries[*].modelId" --output table
```

    -----------------------------------------------
    |            ListFoundationModels             |
    +---------------------------------------------+
    |  anthropic.claude-haiku-4-5-20251001-v1:0   |
    |  anthropic.claude-opus-5-5                  |
    |  anthropic.claude-fable-5                   |
    |  anthropic.claude-haiku-5-5                 |
    |  anthropic.claude-sonnet-4-6                |
    |  anthropic.claude-opus-4-6-v1               |
    |  anthropic.claude-opus-5                    |
    |  anthropic.claude-opus-4-8                  |
    |  anthropic.claude-opus-4-7                  |
    |  anthropic.claude-sonnet-4-5-20250929-v1:0  |
    |  anthropic.claude-fable-5-1                 |
    |  anthropic.claude-sonnet-5-5                |
    |  anthropic.claude-sonnet-5                  |
    |  anthropic.claude-opus-4-5-20251101-v1:0    |
    +---------------------------------------------+
    

Access the bedrock model:


```python
model = init_chat_model("au.anthropic.claude-haiku-4-5-20251001-v1:0",
    model_provider="bedrock_converse",
    region_name="ap-southeast-2"
)
```


```python
response = model.invoke("What is the capital of Australia?")
```


```python
from pprint import pprint
pprint(response.model_dump())
```

    {'additional_kwargs': {},
     'content': 'The capital of Australia is Canberra. It was purpose-built as the '
                'capital city and is located in the Australian Capital Territory '
                '(ACT), positioned between the major cities of Sydney and '
                'Melbourne.',
     'id': 'lc_run--01a1b30d-f273-734e-ac89-290f0731d6b0-0',
     'invalid_tool_calls': [],
     'name': None,
     'response_metadata': {'ResponseMetadata': {'HTTPHeaders': {'connection': 'keep-alive',
                                                                'content-length': '509',
                                                                'content-type': 'application/json',
                                                                'date': 'Fri, 06 '
                                                                        'Nov 2026 '
                                                                        '22:49:58 '
                                                                        'GMT',
                                                                'x-amzn-requestid': '46823e9f-a710-4455-a37e-c9ad96e57073'},
                                                'HTTPStatusCode': 200,
                                                'RequestId': '46823e9f-a710-4455-a37e-c9ad96e57073',
                                                'RetryAttempts': 0},
                           'metrics': {'latencyMs': [750]},
                           'model_name': 'au.anthropic.claude-haiku-4-5-20251001-v1:0',
                           'model_provider': 'bedrock_converse',
                           'stopReason': 'end_turn'},
     'tool_calls': [],
     'type': 'ai',
     'usage_metadata': {'input_token_details': {'cache_creation': 0,
                                                'cache_read': 0},
                        'input_tokens': 14,
                        'output_tokens': 44,
                        'total_tokens': 58}}


### Other models on Bedrock

Let's access the OpenAI models:


```python
!aws bedrock list-foundation-models --by-provider openai --query "modelSummaries[*].modelId" --output table
```

    -----------------------------------
    |      ListFoundationModels       |
    +---------------------------------+
    |  openai.gpt-6-astra             |
    |  openai.gpt-5.6-terra           |
    |  openai.gpt-oss-120b-1:0        |
    |  openai.gpt-6.1-terra           |
    |  openai.gpt-6.1-sol             |
    |  openai.gpt-oss-20b-1:0         |
    |  openai.gpt-oss-safeguard-120b  |
    |  openai.gpt-6-sol               |
    |  openai.gpt-6-luna              |
    |  openai.gpt-5.6-luna            |
    |  openai.gpt-5.6-sol             |
    |  openai.gpt-5.4                 |
    |  openai.gpt-5.5                 |
    |  openai.gpt-oss-safeguard-20b   |
    +---------------------------------+
    


```python
model = init_chat_model("openai.gpt-oss-safeguard-20b",
    model_provider="bedrock_converse",
    region_name="ap-southeast-2"
)
```


```python
response = model.invoke("What is the capital of Sri Lanka?")
```


```python
pprint(response.model_dump())
```

    {'additional_kwargs': {},
     'content': [{'reasoning_content': {'signature': '',
                                        'text': 'The user asks: "What is the '
                                                'capital of Sri Lanka?" '
                                                'Straightforward. The answer: Sri '
                                                'Jayawardenapura Kotte is the '
                                                'official capital (administrative '
                                                'headquarters), while Colombo is '
                                                'the commercial capital and '
                                                'largest city. Maybe mention both. '
                                                'Provide concise answer.'},
                  'type': 'reasoning_content'},
                 {'text': 'The official capital of Sri\u202fLanka is **Sri\u202f'
                          'Jayawardenepura Kotte** (commonly known as Kotte).  \n'
                          'The nation’s largest city and commercial hub, '
                          '**Colombo**, is often referred to as the city’s de '
                          'facto capital.',
                  'type': 'text'}],
     'id': 'lc_run--01a1b317-28c1-73ab-a03f-742144e4a00f-0',
     'invalid_tool_calls': [],
     'name': None,
     'response_metadata': {'ResponseMetadata': {'HTTPHeaders': {'connection': 'keep-alive',
                                                                'content-length': '735',
                                                                'content-type': 'application/json',
                                                                'date': 'Fri, 06 '
                                                                        'Nov 2026 '
                                                                        '23:00:02 '
                                                                        'GMT',
                                                                'x-amzn-requestid': '42ed654a-07d0-49d9-a246-dc7b966737f3'},
                                                'HTTPStatusCode': 200,
                                                'RequestId': '42ed654a-07d0-49d9-a246-dc7b966737f3',
                                                'RetryAttempts': 0},
                           'metrics': {'latencyMs': [545]},
                           'model_name': 'openai.gpt-oss-safeguard-20b',
                           'model_provider': 'bedrock_converse',
                           'stopReason': 'end_turn'},
     'tool_calls': [],
     'type': 'ai',
     'usage_metadata': {'input_token_details': {'cache_creation': 0,
                                                'cache_read': 0},
                        'input_tokens': 75,
                        'output_tokens': 117,
                        'total_tokens': 192}}


Let's access Google `Gemma`:


```python
!aws bedrock list-foundation-models --by-provider google --query "modelSummaries[*].modelId" --output table
```

    ---------------------------
    |  ListFoundationModels   |
    +-------------------------+
    |  google.gemma-3-12b-it  |
    |  google.gemma-3-4b-it   |
    |  google.gemma-3-27b-it  |
    +-------------------------+
    


```python
model = init_chat_model("google.gemma-3-12b-it",
    model_provider="bedrock_converse",
    region_name="ap-southeast-2"
)
```

    Streaming disabled for model 'google.gemma-3-12b-it': provider 'google' is not verified as streaming-capable with ChatBedrockConverse, so calls will fall back to the non-streaming Converse API. If this model does support streaming, pass disable_streaming=False to override.



```python
response = model.invoke("What is the capital of Sri Lanka?")
```


```python
pprint(response.model_dump())
```

    {'additional_kwargs': {},
     'content': 'Sri Lanka has two capitals:\n'
                '\n'
                '*   **Sri Jayawardenepura Kotte** is the administrative capital. '
                'It houses the Parliament and most government ministries.\n'
                '*   **Colombo** is the commercial capital and largest city.\n'
                '\n'
                '\n'
                '\n'
                'So, depending on what you mean by "capital," either city could be '
                'considered the capital!',
     'id': 'lc_run--01a1b322-e69f-776a-8fc3-506adbb8672b-0',
     'invalid_tool_calls': [],
     'name': None,
     'response_metadata': {'ResponseMetadata': {'HTTPHeaders': {'connection': 'keep-alive',
                                                                'content-length': '515',
                                                                'content-type': 'application/json',
                                                                'date': 'Fri, 06 '
                                                                        'Nov 2026 '
                                                                        '23:12:53 '
                                                                        'GMT',
                                                                'x-amzn-requestid': '05b36bd4-f63b-4b52-b0aa-0ce6c71abba2'},
                                                'HTTPStatusCode': 200,
                                                'RequestId': '05b36bd4-f63b-4b52-b0aa-0ce6c71abba2',
                                                'RetryAttempts': 0},
                           'metrics': {'latencyMs': [2124]},
                           'model_name': 'google.gemma-3-12b-it',
                           'model_provider': 'bedrock_converse',
                           'stopReason': 'end_turn'},
     'tool_calls': [],
     'type': 'ai',
     'usage_metadata': {'input_token_details': {'cache_creation': 0,
                                                'cache_read': 0},
                        'input_tokens': 17,
                        'output_tokens': 68,
                        'total_tokens': 85}}


## Agent vs Deep Agent

They aren't competing things; they're two layers of the same stack. LangGraph is the graph runtime. LangChain's `create_agent` is a minimal agent harness on top of it. Deep Agents[^LangChain-DeepAgent] is a more opinionated harness on top of `create_agent` — same building blocks, but with filesystem, sub-agents, context management, and skills bundled in.

**LangChain Agent (`create_agent`)**
- Runs a fixed *ReAct*{:.hl} cycle (think → tool → execute → observe → think) and requires only a model name and a list of tools.
- You add behaviour through middleware, and the middleware parameter is a complete replacement: only the middleware you specify is used, nothing is added automatically like in `create_deep_agent`, so if you need `TodoListMiddleware` you must add it explicitly.
- Good for short, focused tasks: a support bot calling a few tools, a structured-output extractor, etc.

**Deep Agent (`create_deep_agent`, from the `deepagents` package)**
- The same core tool-calling loop everyone hand-rolls, but **with the planner, the filesystem, the subagents, and the sensible defaults built in**{:.message color="green"}.
- Out of the box you get a todo/planning tool, a virtual filesystem (`read_file`, `write_file`, `edit_file`…), a `task` tool for spawning subagents, context summarisation for long runs, skills, and memory. For memory, MemoryMiddleware loads AGENTS.md files into the system prompt at agent startup, and the agent can update its own memory files that persist across threads.
- It is model-agnostic and backend-pluggable, so the filesystem can be in-state, a persistent store, or a real sandbox.
- Good for long-horizon work — research, coding, multi-step analysis — where the agent needs to plan, offload context to files, and delegate.

> Use Deep Agents when you want the full harness — planning, context management, delegation — out of the box. Use LangChain's `create_agent` when you want a lighter harness without the bundled middleware. Drop to LangGraph when the agent loop itself isn't the right shape and you need a custom graph. A sensible middle ground is to use `create_agent` and pull in just the Deep Agents middleware you need (e.g. `FilesystemMiddleware`) without the subagent overhead.
{:.note}

Initialise and invoke agent:


```python
from langchain.agents import create_agent
agent = create_agent(model=model)
```


```python
from langchain.messages import HumanMessage
response = agent.invoke(
    {"messages": [HumanMessage(content="what is the capital of the Mars?")]}
)
```

    {'messages': [HumanMessage(content='what is the capital of the Mars?', additional_kwargs={}, response_metadata={}, id='b5c3cd0a-9142-4cdd-a6e0-df0ac4dd74cf'),
                  AIMessage(content="This is a trick question! Mars doesn't have a capital city. It's a planet, not a country. \n\nWhile there's been a lot of speculation and fictional depictions of Martian cities, no one has ever established a permanent settlement or government on Mars. \n\nSome areas, like **Gale Crater (where the Curiosity rover is located)** and **Jezero Crater (where the Perseverance rover is located)** are often discussed in the context of potential future human settlements, but they aren't capitals.\n\n\n\n", additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '9bdb2446-438d-40b9-bc85-8c56c795721d', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Fri, 06 Nov 2026 23:18:14 GMT', 'content-type': 'application/json', 'content-length': '704', 'connection': 'keep-alive', 'x-amzn-requestid': '9bdb2446-438d-40b9-bc85-8c56c795721d'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [3079]}, 'model_provider': 'bedrock_converse', 'model_name': 'google.gemma-3-12b-it'}, id='lc_run--01a1b327-c8c8-7375-aaf6-ea0b9076977a-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 17, 'output_tokens': 109, 'total_tokens': 126, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}})]}



```python
from langchain_core.load import dumps
print(dumps(response, pretty=True))
```

    {
      "messages": [
        {
          "lc": 1,
          "type": "constructor",
          "id": [
            "langchain",
            "schema",
            "messages",
            "HumanMessage"
          ],
          "kwargs": {
            "content": "what is the capital of the Mars?",
            "type": "human",
            "id": "b5c3cd0a-9142-4cdd-a6e0-df0ac4dd74cf"
          }
        },
        {
          "lc": 1,
          "type": "constructor",
          "id": [
            "langchain",
            "schema",
            "messages",
            "AIMessage"
          ],
          "kwargs": {
            "content": "This is a trick question! Mars doesn't have a capital city. It's a planet, not a country. \n\nWhile there's been a lot of speculation and fictional depictions of Martian cities, no one has ever established a permanent settlement or government on Mars. \n\nSome areas, like **Gale Crater (where the Curiosity rover is located)** and **Jezero Crater (where the Perseverance rover is located)** are often discussed in the context of potential future human settlements, but they aren't capitals.\n\n\n\n",
            "response_metadata": {
              "ResponseMetadata": {
                "RequestId": "9bdb2446-438d-40b9-bc85-8c56c795721d",
                "HTTPStatusCode": 200,
                "HTTPHeaders": {
                  "date": "Fri, 06 Nov 2026 23:18:14 GMT",
                  "content-type": "application/json",
                  "content-length": "704",
                  "connection": "keep-alive",
                  "x-amzn-requestid": "9bdb2446-438d-40b9-bc85-8c56c795721d"
                },
                "RetryAttempts": 0
              },
              "stopReason": "end_turn",
              "metrics": {
                "latencyMs": [
                  3079
                ]
              },
              "model_provider": "bedrock_converse",
              "model_name": "google.gemma-3-12b-it"
            },
            "type": "ai",
            "id": "lc_run--01a1b327-c8c8-7375-aaf6-ea0b9076977a-0",
            "usage_metadata": {
              "input_tokens": 17,
              "output_tokens": 109,
              "total_tokens": 126,
              "input_token_details": {
                "cache_creation": 0,
                "cache_read": 0
              }
            },
            "tool_calls": [],
            "invalid_tool_calls": []
          }
        }
      ]
    }



```python
response['messages'][-1].content
```




    "This is a trick question! Mars doesn't have a capital city. It's a planet, not a country. \n\nWhile there's been a lot of speculation and fictional depictions of Martian cities, no one has ever established a permanent settlement or government on Mars. \n\nSome areas, like **Gale Crater (where the Curiosity rover is located)** and **Jezero Crater (where the Perseverance rover is located)** are often discussed in the context of potential future human settlements, but they aren't capitals.\n\n\n\n"



Let's simulate the conversation using the `AIMessage`:


```python
from langchain.messages import AIMessage
response = agent.invoke(
    {'messages': [HumanMessage(content="What is the capital of Australia?"),
                  AIMessage(content="The capital of the Canberra"),
                  HumanMessage(content="Then, why Sydney is most popular?")
                  ]}
)
```


```python
pprint(response)
```

    {'messages': [HumanMessage(content='What is the capital of Australia?', additional_kwargs={}, response_metadata={}, id='b4081e27-087f-4cdc-9730-2f0ff620189f'),
                  AIMessage(content='The capital of the Canberra', additional_kwargs={}, response_metadata={}, id='8deaa254-c474-4546-8968-0751396a1669', tool_calls=[], invalid_tool_calls=[]),
                  HumanMessage(content='Then, why Sydney is most popular?', additional_kwargs={}, response_metadata={}, id='e7886218-5827-4603-b342-1e537cec3592'),
                  AIMessage(content="You're right to ask that! It's a common point of confusion. Here's why Sydney is so popular despite Canberra being the capital:\n\n*   **Historical Reasons:** Initially, after Federation in 1901, there was a dispute between Sydney and Melbourne about which city should be the capital. To avoid choosing either, a neutral site was selected – Canberra. Sydney was already a very established and large city at the time, and had served as the seat of government for the colony of New South Wales.\n*   **Size & Population:** Sydney is by far the largest city in Australia, both in terms of population and geographic size. It’s simply a major hub.\n*   **Economic Importance:** Sydney is a major financial and economic center, attracting businesses and investment.\n*   **Cultural and Tourist Appeal:** Sydney boasts iconic landmarks like the Sydney Opera House and Harbour Bridge, beautiful beaches, a vibrant arts scene, and a generally appealing lifestyle. It's a popular tourist destination.\n*   **Recognition & Branding:** Due to its prominence over the years, Sydney is often the first place people think of when they think of Australia, even though it's not the capital.\n\n\n\n**Essentially, Canberra is the *political* center, while Sydney is a *major urban, cultural, and economic* center.**", additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': 'a7508a4b-6d28-4cc9-bff0-03b841d8844c', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Fri, 06 Nov 2026 23:34:32 GMT', 'content-type': 'application/json', 'content-length': '1506', 'connection': 'keep-alive', 'x-amzn-requestid': 'a7508a4b-6d28-4cc9-bff0-03b841d8844c'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [7689]}, 'model_provider': 'bedrock_converse', 'model_name': 'google.gemma-3-12b-it'}, id='lc_run--01a1b336-a3c4-755d-9166-0d7e2d2625f8-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 39, 'output_tokens': 275, 'total_tokens': 314, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}})]}


To avoid the latency, you can use streaming:


```python
for token, metadata in agent.stream(
    {'messages': [HumanMessage(content="What is the capital of Australia?"),
                AIMessage(content="The capital of the Canberra"),
                HumanMessage(content="Then, why Sydney is most popular?")
                ]},
                stream_mode="messages"
):
    if token.content:
        print(token.content, end="", flush=True)
```

    You've hit on a really common question! It's true that Sydney is far more well-known internationally and often comes to mind when people think of Australia. Here's why, despite Canberra being the official capital:
    
    *   **Historical Reasons:** Initially, after federation, there was disagreement about which city should be the capital. Melbourne and Sydney were the two biggest contenders. To settle the argument, a new city, Canberra, was purpose-built as a compromise.
    *   **Larger Population & Economy:** Sydney is Australia's largest city and has a much larger population than Canberra. It's a major economic hub, a global financial center, and a significant port.
    *   **Iconic Landmarks:** Sydney boasts world-famous landmarks like the Sydney Opera House and the Sydney Harbour Bridge. These are instantly recognizable and heavily promoted in tourism marketing, making Sydney synonymous with Australia in the global imagination.
    *   **Lifestyle & Culture:** Sydney is known for its beaches, vibrant culture, diverse population, and outdoor lifestyle. This makes it a more appealing destination for tourists.
    *   **Media & Representation:** Sydney is a major media hub, and often features prominently in films, TV shows, and other media portraying Australia.
    
    
    
    Essentially, while Canberra is the seat of government, Sydney has become the face of Australia for many people around the world.

To generate structured output, you can use `pydantic`:


```python
from pydantic import BaseModel

class CityInfo(BaseModel):
    name: str
    country: str

agent = create_agent(model=model,
                     system_prompt="You are a explore",response_format=CityInfo)
question = HumanMessage(content="What is the capital of Australia?")

response = agent.invoke(
    {"messages": [question]}
)

response
```




    CityInfo(name='Canberra', country='Australia')




```python
print(f'{response["structured_response"] = }',
      f'{response["structured_response"].name = }',
      f'{response["structured_response"].country = }',
      sep="\n"
      )
```

    response["structured_response"] = CityInfo(name='Canberra', country='Australia')
    response["structured_response"].name = 'Canberra'
    response["structured_response"].country = 'Australia'


## Tool call
You have to find tool supporting model. For example,


```bash
%%bash
aws bedrock list-foundation-models --region ap-southeast-2 \
  --query "modelSummaries[?contains(modelId,'nova') || contains(modelId,'gpt-oss')].{
    ModelId: modelId,
    Input: join(', ', inputModalities),
    Output: join(', ', outputModalities),
    Streaming: responseStreamingSupported,
    Inference: join(', ', inferenceTypesSupported),
    Status: modelLifecycle.status
  }" \
  --output table
```

    --------------------------------------------------------------------------------------------------------------------------
    |                                                  ListFoundationModels                                                  |
    +-------------------------------+---------------------+---------------------------------+---------+---------+------------+
    |           Inference           |        Input        |             ModelId             | Output  | Status  | Streaming  |
    +-------------------------------+---------------------+---------------------------------+---------+---------+------------+
    |  ON_DEMAND                    |  TEXT               |  openai.gpt-oss-120b-1:0        |  TEXT   |  ACTIVE |  True      |
    |  INFERENCE_PROFILE            |  TEXT, IMAGE, VIDEO |  amazon.nova-2-lite-v1:0        |  TEXT   |  ACTIVE |  True      |
    |  ON_DEMAND                    |  TEXT               |  openai.gpt-oss-20b-1:0         |  TEXT   |  ACTIVE |  True      |
    |  ON_DEMAND                    |  TEXT               |  openai.gpt-oss-safeguard-120b  |  TEXT   |  ACTIVE |  True      |
    |  ON_DEMAND                    |  TEXT               |  openai.gpt-oss-safeguard-20b   |  TEXT   |  ACTIVE |  True      |
    |  INFERENCE_PROFILE, ON_DEMAND |  TEXT, IMAGE, VIDEO |  amazon.nova-pro-v1:0           |  TEXT   |  ACTIVE |  True      |
    |  INFERENCE_PROFILE, ON_DEMAND |  TEXT, IMAGE, VIDEO |  amazon.nova-lite-v1:0          |  TEXT   |  ACTIVE |  True      |
    |  INFERENCE_PROFILE, ON_DEMAND |  TEXT               |  amazon.nova-micro-v1:0         |  TEXT   |  ACTIVE |  True      |
    +-------------------------------+---------------------+---------------------------------+---------+---------+------------+


Price can be found for the Sydney:


```bash
%%bash
aws pricing get-products --region us-east-1 \
  --service-code AmazonBedrock \
  --filters "Type=TERM_MATCH,Field=regionCode,Value=ap-southeast-2" \
  --output json \
| jq -r '
  .PriceList[] | fromjson
  | select((.product.attributes | tostring | ascii_downcase) | contains("gpt-oss"))
  | .product.attributes as $a
  | .terms.OnDemand[].priceDimensions[]
  | [($a.model // $a.usagetype), .unit, .pricePerUnit.USD, .description]
  | @tsv' \
| grep -- '-standard' \
| sort -t $'\t' -k3,3 -g \
| column -t -s $'\t'
```

    gpt-oss-20b             1K tokens  0.0000721000  $0.0000721 per 1K token for openai.gpt-oss-20b-mantle-input-tokens-standard in Asia Pacific (Sydney)
    GPT OSS Safeguard 20B   1K tokens  0.0000721000  $0.0000721 per 1K token for openai.gpt-oss-safeguard-20b-mantle-input-tokens-standard in Asia Pacific (Sydney)
    gpt-oss-120b            1K tokens  0.0001545000  $0.0001545 per 1K token for openai.gpt-oss-120b-mantle-input-tokens-standard in Asia Pacific (Sydney)
    GPT OSS Safeguard 120B  1K tokens  0.0001545000  $0.0001545 per 1K token for openai.gpt-oss-safeguard-120b-mantle-input-tokens-standard in Asia Pacific (Sydney)
    GPT OSS Safeguard 20B   1K tokens  0.0002060000  $0.000206 per 1K token for openai.gpt-oss-safeguard-20b-mantle-output-tokens-standard in Asia Pacific (Sydney)
    gpt-oss-20b             1K tokens  0.0003090000  $0.000309 per 1K token for openai.gpt-oss-20b-mantle-output-tokens-standard in Asia Pacific (Sydney)
    gpt-oss-120b            1K tokens  0.0006180000  $0.000618 per 1K token for openai.gpt-oss-120b-mantle-output-tokens-standard in Asia Pacific (Sydney)
    GPT OSS Safeguard 120B  1K tokens  0.0006180000  $0.000618 per 1K token for openai.gpt-oss-safeguard-120b-mantle-output-tokens-standard in Asia Pacific (Sydney)



```python
from langchain.tools import tool

@tool("square_root_double_as_rounded_int")
def tool_sr(x: int) -> int:
    """Calculate the dobule of the square root of a number and return rounted int"""
    return round((x ** 0.5) * 2)
```


```python
# example direct invoke
tool_sr.invoke({"x":10})
```




    6



When you create agent, you have to specify the tools:


```python
model = init_chat_model("openai.gpt-oss-20b-1:0",
    model_provider="bedrock_converse",
    region_name="ap-southeast-2"
)

agent = create_agent(model=model,
                     tools=[tool_sr],
                     system_prompt="Using given tools, calculate the square root and get the dobule of that rounded integer."
                     )

question = HumanMessage(content="What is the square root of 10?")

response = agent.invoke(
    {"messages": [question]}
)

response["messages"][-1].content
```




    'The square root of\u202f10 is about\u202f3.1623. Doubling that gives approximately\u202f6.3246, which rounds to **6**.'




```python
pprint(response)
```

    {'messages': [HumanMessage(content='What is the square root of 10?', additional_kwargs={}, response_metadata={}, id='707a1906-eda9-4957-b709-54e9875ef607'),
                  AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'We need to use the function. The user asks: "What is the square root of 10?" We must calculate sqrt(10), double it, and round to integer. We have a function square_root_double_as_rounded_int that takes x. We\'ll call with x:10.', 'signature': ''}}, {'type': 'tool_use', 'name': 'square_root_double_as_rounded_int', 'input': {'x': 10}, 'id': 'tooluse_otQX5LByhkU0RJG1ExPi0A'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': 'd6c5a9ee-4eea-4ef7-a31c-75fc145ec597', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 01:25:33 GMT', 'content-type': 'application/json', 'content-length': '590', 'connection': 'keep-alive', 'x-amzn-requestid': 'd6c5a9ee-4eea-4ef7-a31c-75fc145ec597'}, 'RetryAttempts': 0}, 'stopReason': 'tool_use', 'metrics': {'latencyMs': [457]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b39c-6466-73b0-ae24-2c5ce2c02b2a-0', tool_calls=[{'name': 'square_root_double_as_rounded_int', 'args': {'x': 10}, 'id': 'tooluse_otQX5LByhkU0RJG1ExPi0A', 'type': 'tool_call'}], invalid_tool_calls=[], usage_metadata={'input_tokens': 166, 'output_tokens': 87, 'total_tokens': 253, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}),
                  ToolMessage(content='6', name='square_root_double_as_rounded_int', id='3b555da6-d2ba-4d6a-ac20-abdc051a8197', tool_call_id='tooluse_otQX5LByhkU0RJG1ExPi0A'),
                  AIMessage(content='The square root of\u202f10 is about\u202f3.1623. Doubling that gives approximately\u202f6.3246, which rounds to **6**.', additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '8bb17945-ca8b-4560-9a9a-d07f90d3159c', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 01:25:34 GMT', 'content-type': 'application/json', 'content-length': '313', 'connection': 'keep-alive', 'x-amzn-requestid': '8bb17945-ca8b-4560-9a9a-d07f90d3159c'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [303]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b39c-6659-731b-88f4-2dbd7a298c2d-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 279, 'output_tokens': 36, 'total_tokens': 315, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}})]}



```python
for msg in response["messages"]:
    if getattr(msg, "tool_calls", None):
        for call in msg.tool_calls:
            print("Tool call:", call["name"], call["args"])
    elif msg.type == "tool":
        print("Tool result:", msg.name, "->", msg.content)
```

    Tool call: square_root_double_as_rounded_int {'x': 10}
    Tool result: square_root_double_as_rounded_int -> 6


To search latest information newer than model knowledge, need web search tool:


```python
question = HumanMessage(content="How uptodate your training knowladge?")
print(agent.invoke({"messages": [question]})['messages'][-1].content)
```

    [{'type': 'reasoning_content', 'reasoning_content': {'text': 'The user says: "Using given tools, calculate the square root and get the dobule of that rounded integer." Then they ask: "How uptodate your training knowladge?" The user may be asking two separate things. The system message instructs: "Using given tools, calculate the square root and get the dobule of that rounded integer." They likely want us to use the function to compute sqrt? However the user didn\'t provide a number. I think the user perhaps expects the assistant to check its training knowledge cutoff: "How uptodate your training knowladge?" So they want to know that the knowledge cutoff is 2024-06. We can comply with that answer.\n\nWe should comply with not using disallowed content. The user wants a direct answer. We\'ll respond stating that my training knowledge is up to date until June 2024. Also, we need to mention that I can use the tool. But the user hasn\'t provided an x. We might ask for a number. Probably we should just explain how to use the function or ask what number they want. The question appears twofold. Let\'s respond: "My training knowledge is up to date until June 2024. To calculate the square root double, you need to call the function with a number." So we should request a number or show example usage. Perhaps best to ask "What number would you like me to calculate?"', 'signature': ''}}, {'type': 'text', 'text': 'My training data are current through **June\u202f2024** – that is the most recent information I have been trained on.\n\nIf you’d like me to compute “the double of the square root of a number, rounded to the nearest integer,” just give me the number. For example:\n\n```json\n{\n  "x": 16\n}\n```\n\nWhen you provide the value, I can call the `square_root_double_as_rounded_int` tool to give you the result.'}]


### Tool Configuration (Tavily)
Before use Tavily for as web search tool, you have to install that.


```python
#!uv add tavily
```

    Resolved 225 packages in 384ms                                       
    Installed 1 package in 2ms                                       ░░░░░░░░░░░░░░░░░░░░ [0/0] Installing wheels...                                 
     + tavily==1.1.0



```python
from tavily import TavilyClient
from typing import Dict, Any
from langchain.tools import tool

tavily_client = TavilyClient()

@tool
def web_seaerch(query: str) -> Dict[str, Any]:
    """Search the web for information"""
    return tavily_client.search(query)

sys_prompt = """
You are a professional trip planner. The user will give you a start and end locations of their trip.
Using the web search tool, search the web for locations and accomodations which are cheaper and pet friendly (at least 4 star rated) for each location 
in between start and end locations.
Return 
- suggestions of the best time for the trip
- table with location and the accomodation/s (at least one) in each location
- list what are the main attactions in those pleases
Keep the output in table format. 
"""

model = init_chat_model("openai.gpt-oss-20b-1:0",
    model_provider="bedrock_converse",
    region_name="ap-southeast-2"
)

agent = create_agent(model=model,
                     tools=[web_seaerch],
                     system_prompt=sys_prompt
                     )

question = HumanMessage(content="I want to visit Sydney to Eden.")

response = agent.invoke(
    {"messages": [question]}
)

```


```python
print(response["messages"][-1].content)
```

    <reasoning>Search results just list motels not 4-star. This is tough.
    
    Maybe answer with approximate best suggestions and note they should check booking.com for current rates. Provide table with sample hotels known to be pet-friendly 4-star.
    
    Also suggest best time: Nov-Mar for Australia warm season, but avoid school holidays.
    
    But easier: mention that best time is late spring to early autumn (Oct-April) outside school holidays.
    
    Also include attractions:
    
    Sydney: Harbour Bridge, Bondi, Blue Mountains
    
    Cooma: Snowy Mountains, Thredbo
    
    Bega: Bega Cheese, Bega Valley region
    
    Eden: Booderee National Park, Eden Killer Whale museum, shark shows.
    
    Let's prepare tables.**Best Timing for the Sydney → Eden Journey**  
    | Season (Southern Hemisphere) | Highlights | Why it’s a good choice |
    |---|---|---|
    | **Mid‑October – Mid‑April** | Mild to warm weather; most coastal and inland attractions are at their peak | Lower temperatures mean more comfortable inland driving and the beaches of the Southern Coast are still sunny. |
    | **Avoid school holidays** (early Apr – May, late Jul – Aug, Dec – Jan) | Reduced tourist crowds & fewer crowds at pet‑friendly hotels | Easier to book at preferred pet‑friendly 4★ properties and enjoy a quieter experience. |
    
    ---
    
    ## Suggested Pet‑Friendly 4★ Accommodations en‑Route  
    
    > (Prices vary with dates; always book directly from the hotel or a verified reseller like Booking.com. Check the “pet policy” and extra fees before confirming.)
    
    | Location (Start → End) | Best‑Rated Pet‑Friendly 4★ Accommodation | Approx. Nightly Rate (AUD) | Pet Policy (brief) |
    |---|---|---|---|
    | **Sydney** | **Ovolo Woolloomooloo** – Boutique 4★ hotel in the heart of Sydney, pet‑friendly rooms available for an extra $35/night. | $250‑$320 | Pets allowed, 3 kg limit; bring suitable supplies. |
    | | **Aero Lodge – Sydney Harbour** – 4★ lodging, pets welcomed for $40 extra/night. | $270‑$330 | Dogs up to 20 kg, no barking. |
    | **Cooma** | **The Cooma Motel (High Country Motel)** – 4★‑rated, pet‑friendly rooms, $120/night. | $110‑$150 | Pets welcome, no additional fee (check policy). |
    | | **The Snowy 4•Star Lodge** – gift‑table zzz 4★, pet‑friendly rooms, $135/night. | $120‑$180 | Dogs up to 25 kg, extra nightly fee $20. |
    | **Bega** | **Bega Village Motor Inn** – 4★‑rated, pet‑friendly rooms, $80/night. | $70‑$100 | Pets welcomed, small dogs only, no extra charge. |
    | | **The Bega River Lodge** – 4★ beachfront, pet‑friendly rooms available for $90/night. | $80‑$110 | Dogs up to 25 kg, extra fee $15. |
    | **Eden** | **Eden Lodge (Eden Whale Museum Inn)** – 4★‑rated, pet‑friendly rooms, $110/night. | $100‑$140 | Pets allowed, 20 kg limit, extra fee $20. |
    | | **Mount Dallachy Lodge** – 4★, pet‑friendly mountain lodge, $115/night. | $110‑$160 | Pets up to 30 kg, extra fee $25. |
    
    ---
    
    ## Main Attractions along the Route  
    
    | Town / Area | Key Attractions | Why it’s worth visiting |
    |---|---|---|
    | **Sydney** | Sydney Harbour Bridge, Darling Harbour, Barangaroo Reserve, Blue Mountains (day‑trip) | Iconic landmarks, easy water‑friendly strolls for pets. |
    | **Cooma** | Thredbo ski fields, Snowy Mountains National Park, Lake Jindabyne | Outdoor adventure for families and pets; scenic trails. |
    | **Bega** | Bega Cheese Heritage Centre, Bega Valley Regional Gallery, local orchards | Taste local produce, rural charm, easy pet walks. |
    | **Eden** | Booderee National Park, Prison Bay Whale & Shark Show, Eden Killer Whale Museum | Wildlife encounters, marine life shows, coastal trails. |
    | **Eden (across the Zygos)** | Scenic coastal drive, Pelican Point, Albion Canyon | Lush coastal views, less‑crowded beaches for pet‑friendly walks. |
    
    ---
    
    ### Quick Takeaway  
    - **When to Go:** Mid‑October through mid‑April, steering clear of public holidays.  
    - **Where to Stay:** Use the table above as a starting point; confirm pet‑friendly availability and check for any special promotions.  
    - **What to See:** Each stop offers unique natural attractions that are generally pet‑friendly, from Sydney’s urban vistas to Eden’s coastal wildlife shows.
    
    Enjoy a safe, dog‑friendly road trip through New South Wales!


## Checkpoint for short term memory


```python
from langchain.agents import create_agent
from langchain.chat_models import init_chat_model
from langgraph.checkpoint.memory import InMemorySaver
from langchain.messages import HumanMessage, AIMessage

model = init_chat_model("openai.gpt-oss-20b-1:0",
    model_provider="bedrock_converse",
    region_name="ap-southeast-2"
)

agent = create_agent(model=model,
                     checkpointer=InMemorySaver())

config = {"configurable": {"thread_id": "1"}}

question = HumanMessage("Hello, my name is Ojitha and my favorite colour is blue.")
response = agent.invoke(
    {"messages": [question]},
    config
)

```


```python
from pprint import pprint
pprint(response)
```

    {'messages': [HumanMessage(content='Hello, my name is Ojitha and my favorite colour is blue.', additional_kwargs={}, response_metadata={}, id='fef73f14-b7f8-4e81-976d-dd2d78e0abee'),
                  AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'We need to respond in a friendly tone. Possibly ask more about their interests. We can note their name and favourite colour. No extra context needed.', 'signature': ''}}, {'type': 'text', 'text': 'Hi Ojitha! 🌟 It’s great to meet you. Blue is a fantastic choice—so calming and versatile! Do you have a favorite shade of blue (like navy, sky, or teal) or something you enjoy doing that involves that color?'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '71d53e95-757c-4ff2-8ee2-7c6acc3823c4', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 02:41:39 GMT', 'content-type': 'application/json', 'content-length': '617', 'connection': 'keep-alive', 'x-amzn-requestid': '71d53e95-757c-4ff2-8ee2-7c6acc3823c4'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [510]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b3e2-0cd1-777e-a086-8626fa277ff2-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 81, 'output_tokens': 91, 'total_tokens': 172, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}})]}



```python
question = HumanMessage("what is my name")
response = agent.invoke(
    {"messages": [question]},
    config
)
```


```python
pprint(response)
```

    {'messages': [HumanMessage(content='Hello, my name is Ojitha and my favorite colour is blue.', additional_kwargs={}, response_metadata={}, id='fef73f14-b7f8-4e81-976d-dd2d78e0abee'),
                  AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'We need to respond in a friendly tone. Possibly ask more about their interests. We can note their name and favourite colour. No extra context needed.', 'signature': ''}}, {'type': 'text', 'text': 'Hi Ojitha! 🌟 It’s great to meet you. Blue is a fantastic choice—so calming and versatile! Do you have a favorite shade of blue (like navy, sky, or teal) or something you enjoy doing that involves that color?'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '71d53e95-757c-4ff2-8ee2-7c6acc3823c4', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 02:41:39 GMT', 'content-type': 'application/json', 'content-length': '617', 'connection': 'keep-alive', 'x-amzn-requestid': '71d53e95-757c-4ff2-8ee2-7c6acc3823c4'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [510]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b3e2-0cd1-777e-a086-8626fa277ff2-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 81, 'output_tokens': 91, 'total_tokens': 172, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}),
                  HumanMessage(content='what is my name', additional_kwargs={}, response_metadata={}, id='1cb699e3-66ad-4b20-8df2-9cf037b3a2f8'),
                  AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'User: "what is my name". We earlier received "My name is Ojitha". So answer "Your name is Ojitha".', 'signature': ''}}, {'type': 'text', 'text': 'Your name is Ojitha.'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '06e08817-c7ef-4b05-9f69-b2756a7d42d5', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 02:43:44 GMT', 'content-type': 'application/json', 'content-length': '379', 'connection': 'keep-alive', 'x-amzn-requestid': '06e08817-c7ef-4b05-9f69-b2756a7d42d5'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [191]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b3e3-f86e-743d-acb1-846107f37e30-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 183, 'output_tokens': 43, 'total_tokens': 226, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}})]}


## MCP

Anthropic's engineering post *Code execution with MCP: Building more efficient agents*[^anthropic-post] covers a scaling problem. As an agent connects to more MCP servers, a growing share of its context window goes to tool definitions and intermediate results instead of the user's task. The fix is to stop presenting MCP tools as direct function calls. Instead, present them as a **code API** that lives on a filesystem. The agent writes a short program, runs it in a sandbox, and sees only the output that program chooses to show.

The Model Context Protocol (MCP) is an open standard for connecting AI agents to external systems. Without it, every agent–tool pairing needs a custom integration. With it, a developer implements MCP once and the agent can use the whole ecosystem of MCP servers. Since MCP launched in November 2024, the community has built thousands of servers, SDKs exist for all major languages, and MCP has become the de facto standard. That success causes the problem: agents now commonly have **hundreds or thousands of tools across dozens of servers**.

## The Problem: Two Sources of Token Waste

Two patterns make heavily connected agents slow and expensive.

| # | Pattern | What happens | Consequence |
|:-:|---------|--------------|-------------|
| 1 | Tool definitions overload the context window | Most MCP clients load **every** tool's name, description, parameters and return type into the prompt up front | With thousands of tools, the model processes hundreds of thousands of tokens before it reads the request |
| 2 | Intermediate results flow through the model | Each tool's output is placed in the context, and the model must re-emit that data as input to the next tool | Large payloads pass through the model repeatedly, and very large ones can exceed the context limit and break the workflow |

**Tool definitions overload the context**: In the traditional setup, the MCP client describes each tool to the model in detail: what it does, which parameters are required or optional, their types, and what comes back. One Google Drive "get document" tool or one Salesforce "update record" tool is small. Multiply that by every tool on every connected server, though, and the definitions alone can dominate the context. That raises cost (more input tokens per request) and latency (more to process before the first useful token).

**Intermediate results consume additional tokens**: For example, in a task: *"Download my meeting transcript from Google Drive and attach it to the Salesforce lead."* With direct tool calling:

1. The model calls the Drive tool, and the **full transcript** comes back into the context.
2. The model then calls the Salesforce tool and has to **write the entire transcript out again** as an argument.

So the transcript passes through the model twice. For a two-hour sales meeting, that can mean roughly **50,000 extra tokens**. Accuracy suffers too: the more data a model copies verbatim between calls, the more likely it is to make a mistake.

## The Solution: Present MCP Servers as Code

Code execution environments are now common for agents. So instead of *injecting tool schemas into the prompt*{:rtxt}, the MCP client can **generate a small library of code wrappers**{:gtxt}, one per tool, and place them on the filesystem the agent can browse. Each wrapper is a thin, typed function that forwards its arguments to the matching MCP tool through a shared client helper.

```mermaid
graph TD
    R[servers/] --> GD[google_drive/]
    R --> SF[salesforce/]
    R --> O[... other servers]
    GD --> GD1[get_document]
    GD --> GD2[get_sheet]
    GD --> GDI[index / package entry]
    SF --> SF1[update_record]
    SF --> SF2[query]
    SF --> SFI[index / package entry]
```

The agent then works the way a developer exploring an unfamiliar codebase would:

1. **List** the servers directory to see which integrations exist, for example Google Drive and Salesforce.
2. **Open** only the tool files the task needs, such as "get document" and "update record", to learn their inputs and outputs.
3. **Write** a short program that calls Drive, stores the transcript in a variable, and passes that variable to Salesforce.
4. **Run** the program in the sandbox and receive only a brief confirmation.

The transcript moves from Drive to Salesforce inside the execution environment and never enters the model's context.

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant M as Model (context window)
    participant X as Sandbox (code execution)
    participant C as MCP client
    participant G as Google Drive
    participant S as Salesforce

    U->>M: "Attach the transcript to the lead"
    M->>X: List servers, read 2 tool files
    X-->>M: 2 small interface definitions
    M->>X: Run a short script
    X->>C: get document
    C->>G: Forward call
    G-->>X: Transcript (stays in sandbox)
    X->>C: update record (transcript variable)
    C->>S: Forward call
    S-->>X: OK
    X-->>M: "Done" (a few tokens)
    M-->>U: Done
```

Anthropic reports that this approach cut token usage in their example from **about 150,000 tokens to about 2,000**[^anthropic-1], a **98.7%** reduction in both time and cost.

| Dimension | Direct tool calls | Code execution with MCP |
|-----------|-------------------|-------------------------|
| Tool definitions in context | All of them, loaded up front | Only the files the agent opens |
| Intermediate data | Passes through the model on every step | Stays in the sandbox unless explicitly printed |
| Multi-step workflows | One model round-trip per tool call | One script covers many calls |
| Risk of copy errors | Grows with payload size | Data is passed by variable, not re-typed |
| Example token usage | ~150,000 | ~2,000 |
| Infrastructure needed | MCP client | MCP client **plus** a secure sandbox |

> **Same idea elsewhere:** Cloudflare published similar findings under the name **"Code Mode"**[^cloudflare]. The shared insight is that LLMs are good at writing code, so letting them drive MCP servers through code plays to that strength.

## The Benefits in Detail

```mermaid
mindmap
  root((Code execution with MCP))
    Progressive disclosure
      Browse tool files on demand
      search_tools with detail level
    Context-efficient results
      Filter
      Aggregate
      Join across sources
    Control flow
      Loops
      Conditionals
      Error handling
    Privacy
      Data stays in sandbox
      PII tokenisation
    State and skills
      Files as checkpoints
      Reusable functions
      SKILL.md
```

### Progressive disclosure

Models are good at navigating filesystems. When tools are files, the model can read a definition **at the moment it needs it** instead of holding every definition all the time. This is progressive disclosure: start with a high-level view, then drill down only where the task requires it.

For servers with very many tools, suggestion is adding a `search_tools` capability. Given a keyword such as "salesforce", it returns only the relevant tools. A **detail level** parameter lets the agent choose how much to load:

| Detail level | What it returns | Typical use |
|--------------|-----------------|-------------|
| Name only | Tool names | Quick check of what exists |
| Name + description | Names with a one-line summary | Picking the right tool |
| Full definition | Complete input and output schemas | Just before calling the tool |

### Context-efficient tool results

Large datasets can be **filtered and transformed in the sandbox** before anything reaches the model. For example, a 10,000-row spreadsheet, with direct tool calling, all 10,000 rows land in the context and the model filters them by reading. With code execution, a script keeps only the rows whose status is "pending", prints the count, and shows the first five as a sample. The model sees **five rows instead of ten thousand**.

The same pattern covers aggregations (totals, averages, group-bys), joins across data sources, and pulling out a few fields from large records, all without bloating the context window.

### More powerful and context-efficient control flow

Loops, conditionals and error handling are normal programming constructs. Without code, they have to be faked by chaining individual tool calls through the agent loop. Take the task of waiting for a "deployment complete" message in Slack:

| Approach | How it works | Cost |
|----------|--------------|------|
| Direct tool calls | Model calls "get channel history", reads the result, calls a sleep tool, then repeats | Every iteration is a full model round-trip |
| Code execution | One script polls the channel every few seconds in a loop and prints a single message when found | The model is involved once, at the start and the end |

Running branches in the sandbox also improves **time-to-first-token latency**. The execution environment evaluates the conditions directly, so the agent doesn't have to wait for the model to reason through each if/else.

### Privacy-preserving operations

With code execution, intermediate results **stay in the execution environment by default**. The model sees only what the program explicitly logs or returns, so data you don't want to share with the model can move through the workflow without ever entering its context.

For more sensitive workloads, the agent harness can **tokenise personal data automatically**. Suppose customer contact details are imported from a spreadsheet into Salesforce:

1. The script reads each row (name, email, phone) and sends it to Salesforce.
2. The MCP client intercepts the data and replaces each sensitive value with a placeholder such as `[EMAIL_1]` or `[PHONE_1]` before anything could reach the model.
3. If the agent logs the rows, it sees only the placeholders.
4. When a placeholder appears in a later tool call, the MCP client **swaps the real value back in** from its private lookup table.

```mermaid
flowchart LR
    GS[(Google Sheet\nreal PII)] -->|real values| X[Sandbox]
    X -->|"placeholders only\n[EMAIL_1], [PHONE_1]"| M((Model))
    X -->|tool call with placeholders| C[MCP client\nlookup table]
    C -->|real values restored| SF[(Salesforce)]

    style M fill:#fde68a
    style C fill:#bbf7d0
```

The real names, emails and phone numbers go from Google Sheets to Salesforce **without ever passing through the model**, which also stops the agent from accidentally logging or reasoning over them. The same mechanism can enforce **deterministic security rules** about where data may flow to and from.

### State persistence and skills

When the sandbox has filesystem access, the agent can **keep state across operations**. It can write intermediate results to files, such as a CSV export of a thousand Salesforce leads, and a later run can pick up where the earlier one stopped. Long jobs become resumable and progress becomes trackable.

The agent can also save **its own working code** as reusable functions. Once it has solved something like "export a Google Sheet to CSV", it can store that implementation in a skills folder and import it in future runs instead of rewriting it.

This links to Anthropic's **Agent Skills**[^skills]: folders of reusable instructions, scripts and resources that help a model with specialised tasks. Adding a `SKILL.md` file next to a saved function turns it into a structured skill the model can discover and use.

```mermaid
graph LR
    A[Agent solves a task once] --> B[Saves the working function\nto the skills folder]
    B --> C[Adds SKILL.md\ndescribing when to use it]
    C --> D[Reusable skill]
    D -->|reused in later runs| A
```

Over time, the agent builds a **toolbox of higher-level capabilities** and grows the scaffolding it needs to work effectively.

## Trade-offs

> **Caution:** Code execution adds complexity of its own. Running model-generated code safely needs a **secure execution environment** with proper sandboxing, resource limits and monitoring. That brings operational overhead and security considerations that direct tool calls avoid.

The benefits (lower token cost, lower latency, better tool composition) should be weighed against those implementation costs:

| Scenario | Direct tool calls | Code execution |
|----------|:-----------------:|:--------------:|
| A handful of tools, small payloads | ✅ | ➖ |
| Hundreds or thousands of tools | ❌ | ✅ |
| Large documents or datasets | ❌ | ✅ |
| Loops, polling, branching logic | ❌ | ✅ |
| Sensitive data (PII) | ❌ | ✅ |
| No sandbox infrastructure available | ✅ | ❌ |

## MCP Remote Server (Example)
I just want to discuss the example use of MCP here for completeion. More better examples created in the second part of this series[^LangChain-DeepAgent].


```python
#!uv add langchain_mcp_adapters
```

    Resolved 234 packages in 1.00s                                       
    Prepared 1 package in 18ms                                                   langchain-mcp-adapters ------------------------------ 28.20 KiB/28.20 KiB       [1A
    Uninstalled 2 packages in 7ms
    Installed 11 packages in 7ms                                
     - fastmcp-slim==4.1.6
     + fastmcp-slim==3.4.11
     + httpx-sse==0.4.3
     + jaraco-classes==3.4.0
     + jaraco-context==6.1.2
     + jaraco-functools==4.6.0
     + jeepney==0.9.0
     + keyring==25.7.0
     + langchain-mcp-adapters==0.3.2
     - mcp==2.3.0
     + mcp==1.30.0
     + more-itertools==11.2.1
     + secretstorage==3.5.0



```python
from langchain_mcp_adapters.client import MultiServerMCPClient

client = MultiServerMCPClient({
    "kiwi": {
        "transport": "streamable_http",
        "url": "https://mcp.kiwi.com",
    }
})

tools = await client.get_tools()
search_flight = next(t for t in tools if t.name == "search-flight")

for t in tools:
    print(t.name, "\n", t.args, "\n")
```

    search-flight 
     {'flyFrom': {'description': 'Origin: IATA code, city or airport name (e.g. "PRG", "Prague", "London Heathrow")', 'maxLength': 100, 'minLength': 1, 'title': 'Flyfrom', 'type': 'string'}, 'flyTo': {'description': 'Destination: IATA code, city or airport name', 'maxLength': 100, 'minLength': 1, 'title': 'Flyto', 'type': 'string'}, 'departureDate': {'description': 'Departure date in dd/mm/yyyy — the day to fly, or the earliest date of a range (see departureDateTo)', 'maxLength': 10, 'title': 'Departuredate', 'type': 'string'}, 'departureDateFlexDays': {'default': 0, 'description': 'Search +/- this many days around departureDate (symmetric). Leave 0 when using departureDateTo', 'maximum': 10, 'minimum': 0, 'title': 'Departuredateflexdays', 'type': 'integer'}, 'departureDateTo': {'anyOf': [{'maxLength': 10, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': 'Latest departure date in dd/mm/yyyy for an explicit range [departureDate .. departureDateTo]. Use instead of departureDateFlexDays for a one-directional or asymmetric range; must be >= departureDate', 'title': 'Departuredateto'}, 'returnDate': {'anyOf': [{'maxLength': 10, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': 'Return date in dd/mm/yyyy — the day to fly back, or the earliest return date of a range (omit for one-way)', 'title': 'Returndate'}, 'returnDateFlexDays': {'default': 0, 'description': 'Search +/- this many days around returnDate (symmetric). Leave 0 when using returnDateTo', 'maximum': 10, 'minimum': 0, 'title': 'Returndateflexdays', 'type': 'integer'}, 'returnDateTo': {'anyOf': [{'maxLength': 10, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': 'Latest return date in dd/mm/yyyy for an explicit range [returnDate .. returnDateTo]. Requires returnDate; use instead of returnDateFlexDays; must be >= returnDate', 'title': 'Returndateto'}, 'adults': {'default': 1, 'description': 'Number of adults (12+)', 'ge': 1, 'le': 9, 'title': 'Adults', 'type': 'integer'}, 'children': {'default': 0, 'description': 'Number of children (2-11)', 'maximum': 8, 'minimum': 0, 'title': 'Children', 'type': 'integer'}, 'infants': {'default': 0, 'description': 'Number of infants (<2)', 'maximum': 4, 'minimum': 0, 'title': 'Infants', 'type': 'integer'}, 'cabinClass': {'anyOf': [{'enum': ['M', 'W', 'C', 'F'], 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': 'M=economy, W=premium economy, C=business, F=first', 'title': 'Cabinclass'}, 'currency': {'default': 'EUR', 'description': 'Currency code (e.g. EUR, USD)', 'maxLength': 3, 'minLength': 1, 'title': 'Currency', 'type': 'string'}, 'locale': {'default': 'en', 'description': 'Locale (e.g. en, de, fr)', 'maxLength': 10, 'minLength': 1, 'title': 'Locale', 'type': 'string'}, 'nights_in_dst_from': {'anyOf': [{'minimum': 0, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Minimum nights at destination before return flight. Turns the search into a return search', 'title': 'Nights In Dst From'}, 'nights_in_dst_to': {'anyOf': [{'minimum': 0, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Maximum nights at destination before return flight', 'title': 'Nights In Dst To'}, 'one_for_city': {'default': False, 'description': "If true, return only the single best result per destination city — useful for 'explore' searches with broad destinations", 'title': 'One For City', 'type': 'boolean'}, 'max_sector_stopovers': {'anyOf': [{'minimum': 0, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Maximum number of stopovers (connections) allowed per flight sector', 'title': 'Max Sector Stopovers'}, 'price_from': {'anyOf': [{'minimum': 0, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Minimum total price filter in the specified currency', 'title': 'Price From'}, 'price_to': {'anyOf': [{'minimum': 0, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Maximum total price filter in the specified currency', 'title': 'Price To'}, 'max_fly_duration': {'anyOf': [{'ge': 0, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Maximum total flight duration in hours', 'title': 'Max Fly Duration'}, 'select_airlines': {'anyOf': [{'maxLength': 200, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': "Only include flights operated by these airlines — comma-separated IATA codes, e.g. 'FR,U2,BA'. Mutually exclusive with exclude_airlines", 'title': 'Select Airlines'}, 'exclude_airlines': {'anyOf': [{'maxLength': 200, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': "Exclude flights operated by these airlines — comma-separated IATA codes, e.g. 'FR,W6'. Mutually exclusive with select_airlines", 'title': 'Exclude Airlines'}, 'dtime_from': {'anyOf': [{'ge': 0, 'le': 23, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Earliest outbound departure hour (0-23, local)', 'title': 'Dtime From'}, 'dtime_to': {'anyOf': [{'ge': 0, 'le': 23, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Latest outbound departure hour (0-23, local)', 'title': 'Dtime To'}, 'atime_from': {'anyOf': [{'ge': 0, 'le': 23, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Earliest outbound arrival hour (0-23, local)', 'title': 'Atime From'}, 'atime_to': {'anyOf': [{'ge': 0, 'le': 23, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Latest outbound arrival hour (0-23, local)', 'title': 'Atime To'}, 'ret_dtime_from': {'anyOf': [{'ge': 0, 'le': 23, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Earliest return departure hour (0-23, local)', 'title': 'Ret Dtime From'}, 'ret_dtime_to': {'anyOf': [{'ge': 0, 'le': 23, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Latest return departure hour (0-23, local)', 'title': 'Ret Dtime To'}, 'ret_atime_from': {'anyOf': [{'ge': 0, 'le': 23, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Earliest return arrival hour (0-23, local)', 'title': 'Ret Atime From'}, 'ret_atime_to': {'anyOf': [{'ge': 0, 'le': 23, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Latest return arrival hour (0-23, local)', 'title': 'Ret Atime To'}, 'stopover_from': {'anyOf': [{'ge': 0, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Minimum layover duration in hours', 'title': 'Stopover From'}, 'stopover_to': {'anyOf': [{'ge': 0, 'type': 'integer'}, {'type': 'null'}], 'default': None, 'description': 'Maximum layover duration in hours', 'title': 'Stopover To'}, 'adults_hold_bags': {'anyOf': [{'items': {'maximum': 2, 'minimum': 0, 'type': 'integer'}, 'maxItems': 9, 'type': 'array'}, {'type': 'null'}], 'default': None, 'description': 'Checked (hold) bags per adult, one entry per adult (each 0-2), e.g. [1, 0]', 'title': 'Adults Hold Bags'}, 'adults_hand_bags': {'anyOf': [{'items': {'maximum': 1, 'minimum': 0, 'type': 'integer'}, 'maxItems': 9, 'type': 'array'}, {'type': 'null'}], 'default': None, 'description': 'Cabin (hand) bags per adult, one entry per adult (each 0-1), e.g. [1, 1]', 'title': 'Adults Hand Bags'}, 'children_hold_bags': {'anyOf': [{'items': {'maximum': 2, 'minimum': 0, 'type': 'integer'}, 'maxItems': 8, 'type': 'array'}, {'type': 'null'}], 'default': None, 'description': 'Checked (hold) bags per child, one entry per child (each 0-2), e.g. [2]', 'title': 'Children Hold Bags'}, 'children_hand_bags': {'anyOf': [{'items': {'maximum': 1, 'minimum': 0, 'type': 'integer'}, 'maxItems': 8, 'type': 'array'}, {'type': 'null'}], 'default': None, 'description': 'Cabin (hand) bags per child, one entry per child (each 0-1), e.g. [1]', 'title': 'Children Hand Bags'}, 'allow_self_transfer': {'default': True, 'description': 'Allow self-transfer (virtual interlining) connections between separate tickets', 'title': 'Allow Self Transfer', 'type': 'boolean'}, 'allow_overnight_stopovers': {'default': True, 'description': 'Allow overnight (red-eye) layovers', 'title': 'Allow Overnight Stopovers', 'type': 'boolean'}, 'allow_diff_airport_connection': {'default': True, 'description': 'Allow connections that change airports within the same city', 'title': 'Allow Diff Airport Connection', 'type': 'boolean'}, 'stopover_airports': {'anyOf': [{'maxLength': 200, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': 'Only connect via these airports — comma-separated IATA codes. Constrains connecting flights only; direct (non-stop) flights are still returned.', 'title': 'Stopover Airports'}, 'exclude_stopover_airports': {'anyOf': [{'maxLength': 200, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': 'Never connect via these airports — comma-separated IATA codes', 'title': 'Exclude Stopover Airports'}, 'stopover_countries': {'anyOf': [{'maxLength': 200, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': "Only connect via these countries — comma-separated ISO 3166-1 alpha-2 codes, e.g. 'DE,AT'. Constrains connecting flights only; direct (non-stop) flights are still returned.", 'title': 'Stopover Countries'}, 'exclude_stopover_countries': {'anyOf': [{'maxLength': 200, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': 'Never connect via these countries — comma-separated ISO 3166-1 alpha-2 codes', 'title': 'Exclude Stopover Countries'}, 'fly_days': {'anyOf': [{'maxLength': 32, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': "Allowed outbound departure weekdays — comma-separated 0=Sun..6=Sat, e.g. '1,2,3,4,5' for weekdays", 'title': 'Fly Days'}, 'ret_fly_days': {'anyOf': [{'maxLength': 32, 'type': 'string'}, {'type': 'null'}], 'default': None, 'description': 'Allowed return departure weekdays — comma-separated 0=Sun..6=Sat', 'title': 'Ret Fly Days'}, 'sort': {'default': 'price', 'description': 'Result ordering', 'enum': ['price', 'duration', 'quality', 'date', 'popularity'], 'title': 'Sort', 'type': 'string'}} 
    
    feedback-to-devs 
     {'text': {'description': 'The content of the feedback. This is ONLY for the Kiwi.com flight search MCP tools on this server (search results, pricing, itineraries, filters, search errors) — not other MCP servers, Claude/app behaviour, or general Kiwi.com products. Include error messages, logs, or context that would help the developers reproduce the issue.', 'maxLength': 3000, 'minLength': 1, 'title': 'Text', 'type': 'string'}} 
    



```python
from langchain.agents import create_agent
from langgraph.checkpoint.memory import InMemorySaver
from langchain.chat_models import init_chat_model

model = init_chat_model("openai.gpt-oss-20b-1:0",
    model_provider="bedrock_converse",
    region_name="ap-southeast-2"
)

agent = create_agent(
    model=model,
    tools=tools,
    checkpointer=InMemorySaver(),
    system_prompt="You are a travel agent."
)
```


```python
from langchain.messages import HumanMessage

config = {"configurable": {"thread_id": "1"}}
response = await agent.ainvoke(
    {'messages': [HumanMessage(content="Get me a direct flight from Sydney to Auckland on 20 November 2026")]},
    config
)
```


```python
from pprint import pprint
pprint(response)
```

    {'messages': [HumanMessage(content='Get me a direct flight from Australia to New Zeeland on November', additional_kwargs={}, response_metadata={}, id='be5c0c1b-860d-4ef3-99c6-d94e3994feee'),
                  AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'User wants "direct flight from Australia to New Zealand on November". They didn\'t specify departure city or date range. They said "on November". Likely they want any flight in November from Australia to New Zealand. We need to ask clarifying: departure city, return? But they just said "direct flight". We can try to search with minimal info, but Kiwi\'s API expects origin, destination, dates. Might search using Australia generic, New Zealand can be "Kapiti Coast" or "Auckland". Better ask clarifying: departure city, date? We can provide search with flexible date range in November. They might be traveling from Australia to New Zealand, maybe by flight, direct, in November. We\'ll ask for departure city (like Sydney, Melbourne, Brisbane?) and earliest date? But they didn\'t specify return. So may be one-way search.\n\nLet\'s ask for from city and date? Assume they want at least one flight. We can search for best direct flights in November. We could ask for November month, maybe first or last? We need user input. Let\'s politely ask for departure city and date.\n\nWe\'ll answer: need departure city and departure date to find direct flights. Ask for those.', 'signature': ''}}, {'type': 'text', 'text': 'Sure thing! 👀✈️  \nCould you let me know:\n\n1. **Which Australian city (or airport) would you fly out of?**  \n2. **What date (or range of dates) in November would you like to depart?**  \n\nOnce I have those details I’ll pull up the direct flights for you and show you the best options. Thanks!'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': 'a8cb6662-8435-4136-8e50-23ab6101f589', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 12:14:49 GMT', 'content-type': 'application/json', 'content-length': '1737', 'connection': 'keep-alive', 'x-amzn-requestid': 'a8cb6662-8435-4136-8e50-23ab6101f589'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [1623]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b5ee-c872-7570-b595-28893b7a2111-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 2271, 'output_tokens': 329, 'total_tokens': 2600, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}),
                  HumanMessage(content='Get me a direct flight from Australia to New Zeeland on November', additional_kwargs={}, response_metadata={}, id='fbc0f2d3-78a1-4ec8-af13-c2115f8829b8'),
                  AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'User says "Get me a direct flight from Australia to New Zeeland on November". They only specify month. We need to assume departure city? Might ask clarifying again. They might want a flight that departs from anywhere in Australia to any destination in New Zealand, direct, in November. We can let API handle origin unspecified? Kiwi likely requires origin. Some APIs allow use "Australia" as origin; maybe okay to search for all Australian airports? We can do a multi-origin search: origin="AU" or "Australia"? Not sure. We can ask them to choose departure city.\n\nAlternatively, we can interpret as passenger from anywhere in Australia to any location in New Zealand that wants direct flight. We need to pick an origin city like Sydney. The safest is ask again. We need to throw direct flight request to Kiwi, but we have to supply origin. Might use "AU" or we can add explicit "ONEROO"? But we can ask clarifying.\n\nWe\'ll ask: Please specify departure city and date within November.', 'signature': ''}}, {'type': 'text', 'text': 'Got it—looking for a direct **Aus\u202f→\u202fNZ** flight in November.  \nTo give you the best options, could you tell me:\n\n1. **Which Australian city (or airport) you’ll be flying out of** (e.g., Sydney, Melbourne, Brisbane)?  \n2. **A preferred departure date (or a range within November)** – or just “any date” if you’re flexible.\n\nOnce I have those details, I’ll pull up the top direct flights for you. 🛫🇦🇺🇳🇿'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '64ca7234-2a8d-40c7-8814-e2ed6287a822', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 12:15:30 GMT', 'content-type': 'application/json', 'content-length': '1698', 'connection': 'keep-alive', 'x-amzn-requestid': '64ca7234-2a8d-40c7-8814-e2ed6287a822'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [1601]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b5ef-6901-7544-a81c-5ab67400a540-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 2618, 'output_tokens': 330, 'total_tokens': 2948, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}),
                  HumanMessage(content='Get me a direct flight from Sydney to Auckland on November', additional_kwargs={}, response_metadata={}, id='f3840879-2249-475b-866f-0f1abddbea54'),
                  AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'We have departure from Sydney, destination Auckland, November. They didn\'t specify date, probably any date in November. So we can search for direct flights between 1-30 November. We could search for the cheapest and shortest flights. We\'ll assume one-way? They didn\'t say return. So one-way.\n\nNeed to use search-flight with params: flyFrom="Sydney" or "SYD", flyTo="Auckland" or "AKL", departureDate maybe "01/11/2024" to "30/11/2024"? But the API expects a single departureDate. But can use departureDateFlexDays or departureDateTo. If they want any date in November, we can set departureDate to "01/11/2024" and departureDateFlexDays with 29? Or use departureDateTo "30/11/2024".\n\nSo call search-flight with:\n\nflyFrom: "SYD"\nflyTo: "AKL"\ndepartureDate: "01/11/2024"\ndepartureDateTo: "30/11/2024"\nmax_sector_stopovers: 0 (to ensure direct flights)\ncabinClass: "M" maybe default M economy\ncurrency: "USD" or "EUR"? Maybe default EUR.\n\nReturn date? none (one-way). Also allow "one_for_city"? Not needed.\n\nAlso need to specify sort maybe "price".\n\nWe\'ll parse the results. If more than 10? We can display.\n\nWe\'ll call function.', 'signature': ''}}, {'type': 'tool_use', 'name': 'search-flight', 'input': {'flyFrom': 'SYD', 'flyTo': 'AKL', 'departureDate': '01/11/2024', 'departureDateTo': '30/11/2024', 'max_sector_stopovers': 0, 'sort': 'price', 'currency': 'EUR'}, 'id': 'tooluse_HEaeRasZ7YGEGoX2yJDpB0'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '88a623ea-7362-4beb-bd8f-defd5e7d7199', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 12:17:18 GMT', 'content-type': 'application/json', 'content-length': '1665', 'connection': 'keep-alive', 'x-amzn-requestid': '88a623ea-7362-4beb-bd8f-defd5e7d7199'}, 'RetryAttempts': 0}, 'stopReason': 'tool_use', 'metrics': {'latencyMs': [1614]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b5f1-0f40-717b-a04e-0de466ac157f-0', tool_calls=[{'name': 'search-flight', 'args': {'flyFrom': 'SYD', 'flyTo': 'AKL', 'departureDate': '01/11/2024', 'departureDateTo': '30/11/2024', 'max_sector_stopovers': 0, 'sort': 'price', 'currency': 'EUR'}, 'id': 'tooluse_HEaeRasZ7YGEGoX2yJDpB0', 'type': 'tool_call'}], invalid_tool_calls=[], usage_metadata={'input_tokens': 2965, 'output_tokens': 391, 'total_tokens': 3356, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}),
                  ToolMessage(content=[{'type': 'text', 'text': '{\n  "query": "SYD → AKL on 01/11/2024–30/11/2024, 1 adult [≤0 stops/sector]",\n  "currency": null,\n  "passengers": null,\n  "resultsCount": 0,\n  "itineraries": [],\n  "searchTimeMs": 0,\n  "error": "These dates are in the past: departureDate (01/11/2024), departureDateTo (30/11/2024). Today is 07/11/2026 — please use dates today or later."\n}', 'id': 'lc_92c24223-eebf-405c-a31b-92014402afba'}], name='search-flight', id='579f6a7a-473b-4ff3-805f-eb0dd68ad591', tool_call_id='tooluse_HEaeRasZ7YGEGoX2yJDpB0', artifact={'structured_content': {'query': 'SYD → AKL on 01/11/2024–30/11/2024, 1 adult [≤0 stops/sector]', 'currency': None, 'passengers': None, 'resultsCount': 0, 'itineraries': [], 'searchTimeMs': 0, 'error': 'These dates are in the past: departureDate (01/11/2024), departureDateTo (30/11/2024). Today is 07/11/2026 — please use dates today or later.'}}),
                  AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'The API returned error because the date is in the past. Today (in the system) is 07/11/2026? Actually the system date is 07/11/2026. So user asked for November 2024. The date is in past relative to 2026. We need to ask for future November (maybe 2026). They said "November" but likely current year. So we need to ask which year. We\'ll ask for year. Also make sure to use correct format dd/mm/yyyy.\n\nWe\'ll ask for current year November. Also clarify if they want any flight or specific date. Also if they want a return or not.\n\nLet\'s ask clarifying.', 'signature': ''}}, {'type': 'text', 'text': 'It looks like you asked for flights in November\u202f2024, which is already in the past.\u202fCould you let me know for *which year* you’d like to travel?\u202fIf you mean\u202fNovember\u202f2026 (this year), I can pull up the direct Sydney‑to‑Auckland options for you—just confirm the year and, if you have a preferred date or range within November, let me know! ✈️📅'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': 'f51e93b2-af12-42ee-987b-893e032e786e', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 12:17:22 GMT', 'content-type': 'application/json', 'content-length': '1180', 'connection': 'keep-alive', 'x-amzn-requestid': 'f51e93b2-af12-42ee-987b-893e032e786e'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [1115]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b5f1-211e-72ee-92e0-6a3fc4f1c85a-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 3479, 'output_tokens': 241, 'total_tokens': 3720, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}),
                  HumanMessage(content='Get me a direct flight from Sydney to Auckland on 20 November 2026', additional_kwargs={}, response_metadata={}, id='b935f18c-8fa6-490e-bf59-dbc8ceb4b5f9'),
                  AIMessage(content=[{'type': 'text', 'text': 'We have departureDate "20/11/2026". Let\'s call search-flight with max_sector_stopovers 0.\n\nPotentially need to set departureDateTo as same day? But not needed.\n\nWe\'ll call search-flight.\n\n'}, {'type': 'tool_use', 'name': 'search-flight', 'input': {'max_sector_stopovers': 0, 'currency': 'USD', 'departureDate': '20/11/2026', 'sort': 'price', 'flyFrom': 'SYD', 'flyTo': 'AKL'}, 'id': 'tooluse_mgsWtuCLSI9oZkG5LLqohN'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '2aea9275-fa8f-4400-888e-f82869880c61', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 12:18:07 GMT', 'content-type': 'application/json', 'content-length': '611', 'connection': 'keep-alive', 'x-amzn-requestid': '2aea9275-fa8f-4400-888e-f82869880c61'}, 'RetryAttempts': 0}, 'stopReason': 'tool_use', 'metrics': {'latencyMs': [533]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b5f1-d413-7223-9d0b-38f54635a3e4-0', tool_calls=[{'name': 'search-flight', 'args': {'max_sector_stopovers': 0, 'currency': 'USD', 'departureDate': '20/11/2026', 'sort': 'price', 'flyFrom': 'SYD', 'flyTo': 'AKL'}, 'id': 'tooluse_mgsWtuCLSI9oZkG5LLqohN', 'type': 'tool_call'}], invalid_tool_calls=[], usage_metadata={'input_tokens': 3742, 'output_tokens': 101, 'total_tokens': 3843, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}),
                  ToolMessage(content=[{'type': 'text', 'text': '{\n  "query": "SYD → AKL on 20/11/2026, 1 adult [≤0 stops/sector]",\n  "currency": "USD",\n  "passengers": {\n    "adults": 1,\n    "children": 0,\n    "infants": 0\n  },\n  "resultsCount": 15,\n  "itineraries": [\n    {\n      "id": "03720ca65129000026107ce5_0",\n      "tripType": "oneway",\n      "price": 370.0,\n      "priceFormatted": "370 USD",\n      "totalDurationSeconds": 11400,\n      "bookingUrl": "https://kiwi.com/u/mv47c4",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 0,\n        "cabinBag": 1,\n        "checkedBag": 0\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T14:05:00",\n        "arrivalTime": "2026-11-20T19:15:00",\n        "durationSeconds": 11400,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T14:05:00",\n            "arrivalTime": "2026-11-20T19:15:00",\n            "durationSeconds": 11400,\n            "carrier": "VA",\n            "carrierName": "Virgin Australia Airlines",\n            "flightNumber": "VA7006",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000217db8fc_0",\n      "tripType": "oneway",\n      "price": 370.0,\n      "priceFormatted": "370 USD",\n      "totalDurationSeconds": 11700,\n      "bookingUrl": "https://kiwi.com/u/2gzqw9",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 0\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T09:55:00",\n        "arrivalTime": "2026-11-20T15:10:00",\n        "durationSeconds": 11700,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T09:55:00",\n            "arrivalTime": "2026-11-20T15:10:00",\n            "durationSeconds": 11700,\n            "carrier": "VA",\n            "carrierName": "Virgin Australia Airlines",\n            "flightNumber": "VA7002",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000386689bd_0",\n      "tripType": "oneway",\n      "price": 370.0,\n      "priceFormatted": "370 USD",\n      "totalDurationSeconds": 11700,\n      "bookingUrl": "https://kiwi.com/u/2s6699",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 0\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T19:25:00",\n        "arrivalTime": "2026-11-21T00:40:00",\n        "durationSeconds": 11700,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T19:25:00",\n            "arrivalTime": "2026-11-21T00:40:00",\n            "durationSeconds": 11700,\n            "carrier": "VA",\n            "carrierName": "Virgin Australia Airlines",\n            "flightNumber": "VA7012",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000c760161c_0",\n      "tripType": "oneway",\n      "price": 403.0,\n      "priceFormatted": "403 USD",\n      "totalDurationSeconds": 11700,\n      "bookingUrl": "https://kiwi.com/u/249z3gt",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T12:45:00",\n        "arrivalTime": "2026-11-20T18:00:00",\n        "durationSeconds": 11700,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T12:45:00",\n            "arrivalTime": "2026-11-20T18:00:00",\n            "durationSeconds": 11700,\n            "carrier": "MU",\n            "carrierName": "China Eastern Airlines",\n            "flightNumber": "MU4014",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000296e7730_0",\n      "tripType": "oneway",\n      "price": 405.0,\n      "priceFormatted": "405 USD",\n      "totalDurationSeconds": 11400,\n      "bookingUrl": "https://kiwi.com/u/59g9c8r",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T17:50:00",\n        "arrivalTime": "2026-11-20T23:00:00",\n        "durationSeconds": 11400,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T17:50:00",\n            "arrivalTime": "2026-11-20T23:00:00",\n            "durationSeconds": 11400,\n            "carrier": "MU",\n            "carrierName": "China Eastern Airlines",\n            "flightNumber": "MU4016",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000f7a69279_0",\n      "tripType": "oneway",\n      "price": 415.0,\n      "priceFormatted": "415 USD",\n      "totalDurationSeconds": 11100,\n      "bookingUrl": "https://kiwi.com/u/nrt5rbn",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T09:45:00",\n        "arrivalTime": "2026-11-20T14:50:00",\n        "durationSeconds": 11100,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T09:45:00",\n            "arrivalTime": "2026-11-20T14:50:00",\n            "durationSeconds": 11100,\n            "carrier": "QF",\n            "carrierName": "Qantas",\n            "flightNumber": "QF3",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca6512900004855f22d_0",\n      "tripType": "oneway",\n      "price": 415.0,\n      "priceFormatted": "415 USD",\n      "totalDurationSeconds": 11400,\n      "bookingUrl": "https://kiwi.com/u/puksvf",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T07:05:00",\n        "arrivalTime": "2026-11-20T12:15:00",\n        "durationSeconds": 11400,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T07:05:00",\n            "arrivalTime": "2026-11-20T12:15:00",\n            "durationSeconds": 11400,\n            "carrier": "QF",\n            "carrierName": "Qantas",\n            "flightNumber": "QF141",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000468e7a1f_0",\n      "tripType": "oneway",\n      "price": 415.0,\n      "priceFormatted": "415 USD",\n      "totalDurationSeconds": 11400,\n      "bookingUrl": "https://kiwi.com/u/jjbhq3",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T19:15:00",\n        "arrivalTime": "2026-11-21T00:25:00",\n        "durationSeconds": 11400,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T19:15:00",\n            "arrivalTime": "2026-11-21T00:25:00",\n            "durationSeconds": 11400,\n            "carrier": "QF",\n            "carrierName": "Qantas",\n            "flightNumber": "QF149",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000a1365718_0",\n      "tripType": "oneway",\n      "price": 415.0,\n      "priceFormatted": "415 USD",\n      "totalDurationSeconds": 11400,\n      "bookingUrl": "https://kiwi.com/u/c9vd9m",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T17:50:00",\n        "arrivalTime": "2026-11-20T23:00:00",\n        "durationSeconds": 11400,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T17:50:00",\n            "arrivalTime": "2026-11-20T23:00:00",\n            "durationSeconds": 11400,\n            "carrier": "QF",\n            "carrierName": "Qantas",\n            "flightNumber": "QF147",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000a65b9301_0",\n      "tripType": "oneway",\n      "price": 415.0,\n      "priceFormatted": "415 USD",\n      "totalDurationSeconds": 11400,\n      "bookingUrl": "https://kiwi.com/u/79mz9d",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T08:55:00",\n        "arrivalTime": "2026-11-20T14:05:00",\n        "durationSeconds": 11400,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T08:55:00",\n            "arrivalTime": "2026-11-20T14:05:00",\n            "durationSeconds": 11400,\n            "carrier": "QF",\n            "carrierName": "Qantas",\n            "flightNumber": "QF143",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca6512900004f383634_0",\n      "tripType": "oneway",\n      "price": 415.0,\n      "priceFormatted": "415 USD",\n      "totalDurationSeconds": 11700,\n      "bookingUrl": "https://kiwi.com/u/3gzhv3t",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T12:45:00",\n        "arrivalTime": "2026-11-20T18:00:00",\n        "durationSeconds": 11700,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T12:45:00",\n            "arrivalTime": "2026-11-20T18:00:00",\n            "durationSeconds": 11700,\n            "carrier": "QF",\n            "carrierName": "Qantas",\n            "flightNumber": "QF145",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000c0f0a0ad_0",\n      "tripType": "oneway",\n      "price": 430.0,\n      "priceFormatted": "430 USD",\n      "totalDurationSeconds": 11100,\n      "bookingUrl": "https://kiwi.com/u/wrjx5h",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T09:45:00",\n        "arrivalTime": "2026-11-20T14:50:00",\n        "durationSeconds": 11100,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T09:45:00",\n            "arrivalTime": "2026-11-20T14:50:00",\n            "durationSeconds": 11100,\n            "carrier": "EK",\n            "carrierName": "Emirates",\n            "flightNumber": "EK5039",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca65129000092014bca_0",\n      "tripType": "oneway",\n      "price": 430.0,\n      "priceFormatted": "430 USD",\n      "totalDurationSeconds": 11400,\n      "bookingUrl": "https://kiwi.com/u/3wm544",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T17:50:00",\n        "arrivalTime": "2026-11-20T23:00:00",\n        "durationSeconds": 11400,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T17:50:00",\n            "arrivalTime": "2026-11-20T23:00:00",\n            "durationSeconds": 11400,\n            "carrier": "EK",\n            "carrierName": "Emirates",\n            "flightNumber": "EK5000",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca6512900008fb1366a_0",\n      "tripType": "oneway",\n      "price": 430.0,\n      "priceFormatted": "430 USD",\n      "totalDurationSeconds": 11400,\n      "bookingUrl": "https://kiwi.com/u/k88k8q",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T19:15:00",\n        "arrivalTime": "2026-11-21T00:25:00",\n        "durationSeconds": 11400,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T19:15:00",\n            "arrivalTime": "2026-11-21T00:25:00",\n            "durationSeconds": 11400,\n            "carrier": "EK",\n            "carrierName": "Emirates",\n            "flightNumber": "EK5049",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    },\n    {\n      "id": "03720ca651290000816abe58_0",\n      "tripType": "oneway",\n      "price": 430.0,\n      "priceFormatted": "430 USD",\n      "totalDurationSeconds": 11400,\n      "bookingUrl": "https://kiwi.com/u/6m5jv4",\n      "imageId": "auckland_nz",\n      "baggage": {\n        "personalItem": 1,\n        "cabinBag": 1,\n        "checkedBag": 1\n      },\n      "outbound": {\n        "from": "SYD",\n        "to": "AKL",\n        "departureTime": "2026-11-20T07:05:00",\n        "arrivalTime": "2026-11-20T12:15:00",\n        "durationSeconds": 11400,\n        "stops": 0,\n        "route": [\n          "SYD",\n          "AKL"\n        ],\n        "cabinClass": "Economy",\n        "segments": [\n          {\n            "from": "SYD",\n            "to": "AKL",\n            "fromCity": "Sydney",\n            "toCity": "Auckland",\n            "fromName": "Sydney",\n            "toName": "Auckland",\n            "fromCountry": "Australia",\n            "toCountry": "New Zealand",\n            "departureTime": "2026-11-20T07:05:00",\n            "arrivalTime": "2026-11-20T12:15:00",\n            "durationSeconds": 11400,\n            "carrier": "EK",\n            "carrierName": "Emirates",\n            "flightNumber": "EK5041",\n            "cabinClass": "Economy"\n          }\n        ]\n      },\n      "inbound": null\n    }\n  ],\n  "searchTimeMs": 4607,\n  "error": null\n}', 'id': 'lc_c61d37d2-c5b4-48f0-963e-a4c248e387f8'}], name='search-flight', id='75d57c3f-083c-4436-b164-11a7f762fadd', tool_call_id='tooluse_mgsWtuCLSI9oZkG5LLqohN', artifact={'structured_content': {'query': 'SYD → AKL on 20/11/2026, 1 adult [≤0 stops/sector]', 'currency': 'USD', 'passengers': {'adults': 1, 'children': 0, 'infants': 0}, 'resultsCount': 15, 'itineraries': [{'id': '03720ca65129000026107ce5_0', 'tripType': 'oneway', 'price': 370.0, 'priceFormatted': '370 USD', 'totalDurationSeconds': 11400, 'bookingUrl': 'https://kiwi.com/u/mv47c4', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 0, 'cabinBag': 1, 'checkedBag': 0}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T14:05:00', 'arrivalTime': '2026-11-20T19:15:00', 'durationSeconds': 11400, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T14:05:00', 'arrivalTime': '2026-11-20T19:15:00', 'durationSeconds': 11400, 'carrier': 'VA', 'carrierName': 'Virgin Australia Airlines', 'flightNumber': 'VA7006', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000217db8fc_0', 'tripType': 'oneway', 'price': 370.0, 'priceFormatted': '370 USD', 'totalDurationSeconds': 11700, 'bookingUrl': 'https://kiwi.com/u/2gzqw9', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 0}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T09:55:00', 'arrivalTime': '2026-11-20T15:10:00', 'durationSeconds': 11700, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T09:55:00', 'arrivalTime': '2026-11-20T15:10:00', 'durationSeconds': 11700, 'carrier': 'VA', 'carrierName': 'Virgin Australia Airlines', 'flightNumber': 'VA7002', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000386689bd_0', 'tripType': 'oneway', 'price': 370.0, 'priceFormatted': '370 USD', 'totalDurationSeconds': 11700, 'bookingUrl': 'https://kiwi.com/u/2s6699', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 0}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T19:25:00', 'arrivalTime': '2026-11-21T00:40:00', 'durationSeconds': 11700, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T19:25:00', 'arrivalTime': '2026-11-21T00:40:00', 'durationSeconds': 11700, 'carrier': 'VA', 'carrierName': 'Virgin Australia Airlines', 'flightNumber': 'VA7012', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000c760161c_0', 'tripType': 'oneway', 'price': 403.0, 'priceFormatted': '403 USD', 'totalDurationSeconds': 11700, 'bookingUrl': 'https://kiwi.com/u/249z3gt', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T12:45:00', 'arrivalTime': '2026-11-20T18:00:00', 'durationSeconds': 11700, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T12:45:00', 'arrivalTime': '2026-11-20T18:00:00', 'durationSeconds': 11700, 'carrier': 'MU', 'carrierName': 'China Eastern Airlines', 'flightNumber': 'MU4014', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000296e7730_0', 'tripType': 'oneway', 'price': 405.0, 'priceFormatted': '405 USD', 'totalDurationSeconds': 11400, 'bookingUrl': 'https://kiwi.com/u/59g9c8r', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T17:50:00', 'arrivalTime': '2026-11-20T23:00:00', 'durationSeconds': 11400, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T17:50:00', 'arrivalTime': '2026-11-20T23:00:00', 'durationSeconds': 11400, 'carrier': 'MU', 'carrierName': 'China Eastern Airlines', 'flightNumber': 'MU4016', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000f7a69279_0', 'tripType': 'oneway', 'price': 415.0, 'priceFormatted': '415 USD', 'totalDurationSeconds': 11100, 'bookingUrl': 'https://kiwi.com/u/nrt5rbn', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T09:45:00', 'arrivalTime': '2026-11-20T14:50:00', 'durationSeconds': 11100, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T09:45:00', 'arrivalTime': '2026-11-20T14:50:00', 'durationSeconds': 11100, 'carrier': 'QF', 'carrierName': 'Qantas', 'flightNumber': 'QF3', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca6512900004855f22d_0', 'tripType': 'oneway', 'price': 415.0, 'priceFormatted': '415 USD', 'totalDurationSeconds': 11400, 'bookingUrl': 'https://kiwi.com/u/puksvf', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T07:05:00', 'arrivalTime': '2026-11-20T12:15:00', 'durationSeconds': 11400, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T07:05:00', 'arrivalTime': '2026-11-20T12:15:00', 'durationSeconds': 11400, 'carrier': 'QF', 'carrierName': 'Qantas', 'flightNumber': 'QF141', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000468e7a1f_0', 'tripType': 'oneway', 'price': 415.0, 'priceFormatted': '415 USD', 'totalDurationSeconds': 11400, 'bookingUrl': 'https://kiwi.com/u/jjbhq3', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T19:15:00', 'arrivalTime': '2026-11-21T00:25:00', 'durationSeconds': 11400, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T19:15:00', 'arrivalTime': '2026-11-21T00:25:00', 'durationSeconds': 11400, 'carrier': 'QF', 'carrierName': 'Qantas', 'flightNumber': 'QF149', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000a1365718_0', 'tripType': 'oneway', 'price': 415.0, 'priceFormatted': '415 USD', 'totalDurationSeconds': 11400, 'bookingUrl': 'https://kiwi.com/u/c9vd9m', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T17:50:00', 'arrivalTime': '2026-11-20T23:00:00', 'durationSeconds': 11400, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T17:50:00', 'arrivalTime': '2026-11-20T23:00:00', 'durationSeconds': 11400, 'carrier': 'QF', 'carrierName': 'Qantas', 'flightNumber': 'QF147', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000a65b9301_0', 'tripType': 'oneway', 'price': 415.0, 'priceFormatted': '415 USD', 'totalDurationSeconds': 11400, 'bookingUrl': 'https://kiwi.com/u/79mz9d', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T08:55:00', 'arrivalTime': '2026-11-20T14:05:00', 'durationSeconds': 11400, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T08:55:00', 'arrivalTime': '2026-11-20T14:05:00', 'durationSeconds': 11400, 'carrier': 'QF', 'carrierName': 'Qantas', 'flightNumber': 'QF143', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca6512900004f383634_0', 'tripType': 'oneway', 'price': 415.0, 'priceFormatted': '415 USD', 'totalDurationSeconds': 11700, 'bookingUrl': 'https://kiwi.com/u/3gzhv3t', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T12:45:00', 'arrivalTime': '2026-11-20T18:00:00', 'durationSeconds': 11700, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T12:45:00', 'arrivalTime': '2026-11-20T18:00:00', 'durationSeconds': 11700, 'carrier': 'QF', 'carrierName': 'Qantas', 'flightNumber': 'QF145', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000c0f0a0ad_0', 'tripType': 'oneway', 'price': 430.0, 'priceFormatted': '430 USD', 'totalDurationSeconds': 11100, 'bookingUrl': 'https://kiwi.com/u/wrjx5h', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T09:45:00', 'arrivalTime': '2026-11-20T14:50:00', 'durationSeconds': 11100, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T09:45:00', 'arrivalTime': '2026-11-20T14:50:00', 'durationSeconds': 11100, 'carrier': 'EK', 'carrierName': 'Emirates', 'flightNumber': 'EK5039', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca65129000092014bca_0', 'tripType': 'oneway', 'price': 430.0, 'priceFormatted': '430 USD', 'totalDurationSeconds': 11400, 'bookingUrl': 'https://kiwi.com/u/3wm544', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T17:50:00', 'arrivalTime': '2026-11-20T23:00:00', 'durationSeconds': 11400, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T17:50:00', 'arrivalTime': '2026-11-20T23:00:00', 'durationSeconds': 11400, 'carrier': 'EK', 'carrierName': 'Emirates', 'flightNumber': 'EK5000', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca6512900008fb1366a_0', 'tripType': 'oneway', 'price': 430.0, 'priceFormatted': '430 USD', 'totalDurationSeconds': 11400, 'bookingUrl': 'https://kiwi.com/u/k88k8q', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T19:15:00', 'arrivalTime': '2026-11-21T00:25:00', 'durationSeconds': 11400, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T19:15:00', 'arrivalTime': '2026-11-21T00:25:00', 'durationSeconds': 11400, 'carrier': 'EK', 'carrierName': 'Emirates', 'flightNumber': 'EK5049', 'cabinClass': 'Economy'}]}, 'inbound': None}, {'id': '03720ca651290000816abe58_0', 'tripType': 'oneway', 'price': 430.0, 'priceFormatted': '430 USD', 'totalDurationSeconds': 11400, 'bookingUrl': 'https://kiwi.com/u/6m5jv4', 'imageId': 'auckland_nz', 'baggage': {'personalItem': 1, 'cabinBag': 1, 'checkedBag': 1}, 'outbound': {'from': 'SYD', 'to': 'AKL', 'departureTime': '2026-11-20T07:05:00', 'arrivalTime': '2026-11-20T12:15:00', 'durationSeconds': 11400, 'stops': 0, 'route': ['SYD', 'AKL'], 'cabinClass': 'Economy', 'segments': [{'from': 'SYD', 'to': 'AKL', 'fromCity': 'Sydney', 'toCity': 'Auckland', 'fromName': 'Sydney', 'toName': 'Auckland', 'fromCountry': 'Australia', 'toCountry': 'New Zealand', 'departureTime': '2026-11-20T07:05:00', 'arrivalTime': '2026-11-20T12:15:00', 'durationSeconds': 11400, 'carrier': 'EK', 'carrierName': 'Emirates', 'flightNumber': 'EK5041', 'cabinClass': 'Economy'}]}, 'inbound': None}], 'searchTimeMs': 4607, 'error': None}}),
                  AIMessage(content='Below are the **cheapest** direct flies from **Sydney (SYD)** to **Auckland (AKL)** on **20\u202fNov\u202f2026**.  \nPrices are in **USD**; you can change the currency if you prefer.\n\n| # | Airline | Flight | Dep – Arr | Duration | Baggage | Price | Book |\n|---|---------|--------|-----------|----------|---------|-------|------|\n| **1** | Virgin\u202fAustralia | **VA\u202f7006** | 14:05\u202f→\u202f19:15 | **1\u202fh\u202f20\u202fm** | 1\u202fcabin bag | **$370\u202fUSD** | [Book](https://kiwi.com/u/mv47c4) |\n| 2 | Virgin\u202fAustralia | **VA\u202f7002** | 09:55\u202f→\u202f15:10 | 1\u202fh\u202f15\u202fm | 1\u202fcabin bag | $370\u202fUSD | [Book](https://kiwi.com/u/2gzqw9) |\n| 3 | Virgin\u202fAustralia | **VA\u202f7012** | 19:25\u202f→\u202f00:40 (next day) | 1\u202fh\u202f15\u202fm | 1\u202fcabin bag | $370\u202fUSD | [Book](https://kiwi.com/u/2s6699) |\n| 4 | Qantas | **QF\u202f3** | 09:45\u202f→\u202f14:50 | 1\u202fh\u202f05\u202fm | 1\u202fcabin bag | **$415\u202fUSD** | [Book](https://kiwi.com/u/nrt5rbn) |\n| 5 | Qantas | **QF\u202f141** | 07:05\u202f→\u202f12:15 | 1\u202fh\u202f10\u202fm | 1\u202fcabin bag | $415\u202fUSD | [Book](https://kiwi.com/u/puksvf) |\n\n### Quick Summary\n\n* **Cheapest ticket**:\u202f$370\u202fUSD (Virgin\u202fAustralia, 14:05 flight).\n* **Shortest flight**:\u202f1\u202fh\u202f05\u202fm (Qantas, 09:45 flight).\n* **Most frequent**:\u202fVirgin\u202fAustralia offers several 14:00‑series flights throughout the day.\n\nIf you’d like a quicker flight or a different departure time, let me know and I’ll fetch more options. Otherwise, if any of the links above looks good, you can book directly through Kiwi for a quick, straightforward booking.\n\n✈️ **Fun fact** – Because of the close proximity between Sydney and Auckland, the flight uses a *fly‑by‑water* route that lets you see the famed *Auckland Harbour* — a perfect day‑trip if you have a layover in the city!  \n\nEnjoy your trip, and feel free to ask if you need anything else (e.g., hotel, car rental, or travel insurance). Happy flying!', additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': 'f847c8d9-f131-469c-8554-fd9b7b672d40', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Sat, 07 Nov 2026 12:18:16 GMT', 'content-type': 'application/json', 'content-length': '2139', 'connection': 'keep-alive', 'x-amzn-requestid': 'f847c8d9-f131-469c-8554-fd9b7b672d40'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [2218]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1b5f1-eefe-7275-b623-0d10ac6819f6-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 9940, 'output_tokens': 624, 'total_tokens': 10564, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}})]}


Context schema create and pass to the agent at runtime. However, this context is immutable.


```python
from dataclasses import dataclass, field
from langchain.tools import tool, ToolRuntime

@dataclass
class TravelContext:
    country: str = "Australia"
    speaking_language: list[str] = field(default_factory=lambda: ["English", "Sinhala"])
    favourite_countries: list[str] = field(
        default_factory=lambda: ["UK", "France", "Germany", "Sri Lanka"]
    )

@tool
def get_living_country(runtime: ToolRuntime) -> str:
    """Get the living country of the tourist"""
    return runtime.context.country

@tool
def get_speaking_languages(runtime: ToolRuntime) -> list[str]:
    """Get the languages tourist can speak"""
    return runtime.context.speaking_language

@tool
def get_favourite_countries(runtime: ToolRuntime) -> list[str]:
    """List of countries the tourist likes to visit."""
    return runtime.context.favourite_countries
```


```python
model = init_chat_model("openai.gpt-oss-20b-1:0",
    model_provider="bedrock_converse",
    region_name="ap-southeast-2"
)

```


```python
agent = create_agent(
    model=model,
    tools=[get_living_country, get_speaking_languages, get_favourite_countries],
    context_schema=TravelContext
)

response = agent.invoke(
    {"messages": [HumanMessage(content="Tourist want to visit non-English speaking country but I can communicate. What is the best?")]},
    context=TravelContext() # TravelContext(country="Canada")
)
```

    /home/ojitha/Github/learn-langgraph/.venv/lib/python3.14/site-packages/pydantic/functional_validators.py:851: UserWarning: Pydantic serializer warnings:
      PydanticSerializationUnexpectedValue(Expected `none` - serialized value may not be as expected [field_name='context', input_value=TravelContext(country='Au...'Germany', 'Sri Lanka']), input_type=TravelContext])
      function=lambda v, h: h(v), schema=original_schema
    /home/ojitha/Github/learn-langgraph/.venv/lib/python3.14/site-packages/pydantic/main.py:520: UserWarning: Pydantic serializer warnings:
      PydanticSerializationUnexpectedValue(Expected `none` - serialized value may not be as expected [field_name='context', input_value=TravelContext(country='Au...'Germany', 'Sri Lanka']), input_type=TravelContext])
      return self.__pydantic_serializer__.to_python(
    /home/ojitha/Github/learn-langgraph/.venv/lib/python3.14/site-packages/pydantic/functional_validators.py:851: UserWarning: Pydantic serializer warnings:
      PydanticSerializationUnexpectedValue(Expected `none` - serialized value may not be as expected [field_name='context', input_value=TravelContext(country='Au...'Germany', 'Sri Lanka']), input_type=TravelContext])
      function=lambda v, h: h(v), schema=original_schema
    /home/ojitha/Github/learn-langgraph/.venv/lib/python3.14/site-packages/pydantic/main.py:520: UserWarning: Pydantic serializer warnings:
      PydanticSerializationUnexpectedValue(Expected `none` - serialized value may not be as expected [field_name='context', input_value=TravelContext(country='Au...'Germany', 'Sri Lanka']), input_type=TravelContext])
      return self.__pydantic_serializer__.to_python(



```python
pprint(response['messages'])
```

    [HumanMessage(content='Tourist want to visit non-English speaking country but I can communicate. What is the best?', additional_kwargs={}, response_metadata={}, id='94b4a6e3-1494-45b4-be5c-0e912441b00d'),
     AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'We need to find countries tourist likes, find the best non-English speaking country where we can communicate. We need living country, languages tourist can speak, favourite countries. Use functions. Let\'s call get_favourite_countries to get list. Then choose non-English speaking country from that list. Probably use english? Tourist can communicate? We need the best. But we lack tourist\'s languages. Let\'s check get_speaking_languages. Then living country. The question: "Tourist want to visit non-English speaking country but I can communicate. What is the best?" The "I" refers to user? They want a recommendation. We need likely recommend the best country from favorite list that is non-English, possibly with good connectivity in tourist\'s languages. We need specifics: We call the functions to get needed data.\n\nProceed to call get_favourite_countries.', 'signature': ''}}, {'type': 'tool_use', 'name': 'get_favourite_countries', 'input': {}, 'id': 'tooluse_0cHAvbkIcuDZh2DC5g6rsj'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '281a93e9-4780-43b4-aa5d-25b6810bb9db', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Mon, 09 Nov 2026 06:39:21 GMT', 'content-type': 'application/json', 'content-length': '1213', 'connection': 'keep-alive', 'x-amzn-requestid': '281a93e9-4780-43b4-aa5d-25b6810bb9db'}, 'RetryAttempts': 0}, 'stopReason': 'tool_use', 'metrics': {'latencyMs': [1144]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1bf08-62a8-76f4-acce-dd783f60820a-0', tool_calls=[{'name': 'get_favourite_countries', 'args': {}, 'id': 'tooluse_0cHAvbkIcuDZh2DC5g6rsj', 'type': 'tool_call'}], invalid_tool_calls=[], usage_metadata={'input_tokens': 182, 'output_tokens': 194, 'total_tokens': 376, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}),
     ToolMessage(content='["UK", "France", "Germany", "Sri Lanka"]', name='get_favourite_countries', id='8b3597e1-e193-42df-9891-6a540d5d6613', tool_call_id='tooluse_0cHAvbkIcuDZh2DC5g6rsj'),
     AIMessage(content=[{'type': 'text', 'text': 'They like UK, France, Germany, Sri Lanka. UK is English speaking, so excluded. We need non-English. Get languages tourist can speak.'}, {'type': 'tool_use', 'name': 'get_speaking_languages', 'input': {}, 'id': 'tooluse_szuT9yYcFRRpI5TjDdcoip'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': 'df1c0669-1ada-4e9f-a1cd-e6a0e60d8c28', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Mon, 09 Nov 2026 06:39:21 GMT', 'content-type': 'application/json', 'content-length': '438', 'connection': 'keep-alive', 'x-amzn-requestid': 'df1c0669-1ada-4e9f-a1cd-e6a0e60d8c28'}, 'RetryAttempts': 0}, 'stopReason': 'tool_use', 'metrics': {'latencyMs': [346]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1bf08-67a4-77f7-b8c9-2c75173e338e-0', tool_calls=[{'name': 'get_speaking_languages', 'args': {}, 'id': 'tooluse_szuT9yYcFRRpI5TjDdcoip', 'type': 'tool_call'}], invalid_tool_calls=[], usage_metadata={'input_tokens': 412, 'output_tokens': 53, 'total_tokens': 465, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}),
     ToolMessage(content='["English", "Sinhala"]', name='get_speaking_languages', id='c4ad5fe2-891b-4cb8-a2c1-0c83382251a8', tool_call_id='tooluse_szuT9yYcFRRpI5TjDdcoip'),
     AIMessage(content=[{'type': 'reasoning_content', 'reasoning_content': {'text': 'Tourist speaks English and Sinhala. So they want a non-English speaking country where we can communicate (maybe with English or Sinhala?) The scenario: Tourist can speak Sinhala but can also speak English. They want a non-English speaking country but can communicate. So maybe pick Sri Lanka? Wait Sri Lanka is non-English speaking? Actually, Sri Lanka has Sinhala and Tamil as official languages; English is widely used, but primary is Sinhala. The tourist already speaks Sinhala, so they can communicate. That may be best. But the question: "Tourist want to visit non-English speaking country but I can communicate. What is the best?" The answer: Sri Lanka. They speak Sinhala, so can communicate. Alternatively, France or Germany but English only? They speak English, but those are non-English speaking but tourist can communicate in English? The user says "but I can communicate." Means the user has some ability to communicate. The user might be capable of speaking English, or they might have some other language? The function get_speaking_languages is for tourist, which is the assistant? Actually it\'s "get the languages tourist can speak" - we want tourist\'s languages. So tourist can speak English, Sinhala. So which country is best from their favourite list? Since they can speak Sinhala, Sri Lanka works. In France or Germany tourists can speak English but are non-English speaking but can communicate in English anyway. But the user wants a non-English country to visit, but they can communicate (i.e., tourist can communicate in that country\'s primary language?). Probably the best is Sri Lanka. Then we can explain why. Let\'s output that.\n\n', 'signature': ''}}, {'type': 'text', 'text': '**Best Choice – Sri\u202fLanka**\n\nYour list of favourite destinations includes UK (English‑speaking), France, Germany, and Sri\u202fLanka.  \nYou or your traveller already know **Sinhala**, the main language used in Sri\u202fLanka (along with Tamil).  \nThis means you’ll be able to navigate, talk to locals, and enjoy the culture without constantly relying on a third‑party interpreter or having to learn a new language on the spot.\n\n**Why choose Sri\u202fLanka?**\n\n| Factor | Sri\u202fLanka | France | Germany |\n|--------|-----------|--------|--------|\n| Primary language | Sinhala (plus Tamil) – matches your language skills | French – you need a translator or rely on English |\n| Ease of communication | High – you speak the local language | Moderate – many tourists speak English, but native interactions are richer in local language |\n| Cultural experience | Relaxing island vibe, world‑class wildlife, historic temples, unique biodiversity | Rich European culture, art, architecture (needs language bridge) |\n| Travel flexibility | Good infrastructure for English‑speaking tourists but less reliance on English | Good infrastructure for English‑speaking tourists but primary language is different |\n| Return\u202fto “non‑English” feel | Truly non‑English oriented, but still accessible to you | Mostly non‑English but you’d be speaking English curiously |\n\nSo, visiting Sri\u202fLanka will give you a genuinely non‑English speaking environment while still allowing you to communicate comfortably. Enjoy the beaches, the tea fields, the national parks, and of course the delicious cuisine that can be talked about without a language barrier!'}], additional_kwargs={}, response_metadata={'ResponseMetadata': {'RequestId': '530775d3-b04b-4120-b2b9-e04471653c8a', 'HTTPStatusCode': 200, 'HTTPHeaders': {'date': 'Mon, 09 Nov 2026 06:39:25 GMT', 'content-type': 'application/json', 'content-length': '3597', 'connection': 'keep-alive', 'x-amzn-requestid': '530775d3-b04b-4120-b2b9-e04471653c8a'}, 'RetryAttempts': 0}, 'stopReason': 'end_turn', 'metrics': {'latencyMs': [3107]}, 'model_provider': 'bedrock_converse', 'model_name': 'openai.gpt-oss-20b-1:0'}, id='lc_run--01a1bf08-695d-708d-97e2-5d87d4a88848-0', tool_calls=[], invalid_tool_calls=[], usage_metadata={'input_tokens': 488, 'output_tokens': 671, 'total_tokens': 1159, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}})]



---
**Output of:** `response['messages'][-1].content[0]['reasoning_content']['text']`

Tourist speaks English and Sinhala. So they want a non-English speaking country where we can communicate (maybe with English or Sinhala?) The scenario: Tourist can speak Sinhala but can also speak English. They want a non-English speaking country but can communicate. So maybe pick Sri Lanka? Wait Sri Lanka is non-English speaking? Actually, Sri Lanka has Sinhala and Tamil as official languages; English is widely used, but primary is Sinhala. The tourist already speaks Sinhala, so they can communicate. That may be best. But the question: "Tourist want to visit non-English speaking country but I can communicate. What is the best?" The answer: Sri Lanka. They speak Sinhala, so can communicate. Alternatively, France or Germany but English only? They speak English, but those are non-English speaking but tourist can communicate in English? The user says "but I can communicate." Means the user has some ability to communicate. The user might be capable of speaking English, or they might have some other language? The function get_speaking_languages is for tourist, which is the assistant? Actually it's "get the languages tourist can speak" - we want tourist's languages. So tourist can speak English, Sinhala. So which country is best from their favourite list? Since they can speak Sinhala, Sri Lanka works. In France or Germany tourists can speak English but are non-English speaking but can communicate in English anyway. But the user wants a non-English country to visit, but they can communicate (i.e., tourist can communicate in that country's primary language?). Probably the best is Sri Lanka. Then we can explain why. Let's output that.



---



---
**Output of:** `response['messages'][-1].content[1]['text']`

**Best Choice – Sri Lanka**

Your list of favourite destinations includes UK (English‑speaking), France, Germany, and Sri Lanka.  
You or your traveller already know **Sinhala**, the main language used in Sri Lanka (along with Tamil).  
This means you’ll be able to navigate, talk to locals, and enjoy the culture without constantly relying on a third‑party interpreter or having to learn a new language on the spot.

**Why choose Sri Lanka?**

| Factor | Sri Lanka | France | Germany |
|--------|-----------|--------|--------|
| Primary language | Sinhala (plus Tamil) – matches your language skills | French – you need a translator or rely on English |
| Ease of communication | High – you speak the local language | Moderate – many tourists speak English, but native interactions are richer in local language |
| Cultural experience | Relaxing island vibe, world‑class wildlife, historic temples, unique biodiversity | Rich European culture, art, architecture (needs language bridge) |
| Travel flexibility | Good infrastructure for English‑speaking tourists but less reliance on English | Good infrastructure for English‑speaking tourists but primary language is different |
| Return to “non‑English” feel | Truly non‑English oriented, but still accessible to you | Mostly non‑English but you’d be speaking English curiously |

So, visiting Sri Lanka will give you a genuinely non‑English speaking environment while still allowing you to communicate comfortably. Enjoy the beaches, the tea fields, the national parks, and of course the delicious cuisine that can be talked about without a language barrier!

---


## Summary

MCP gives agents one protocol for connecting to many tools and systems. Once too many servers are connected, though, tool definitions and intermediate results consume too many tokens and agents become less efficient.

These problems look new (context management, tool composition, state persistence), but software engineering already has answers for them. Code execution applies those established patterns to agents:

- **Import only what you need**: progressive disclosure of tool definitions.
- **Process data where it lives**: filter, aggregate and join in the sandbox.
- **Use real control flow**: loops and conditionals instead of chained tool calls.
- **Keep sensitive data out of the model**: default isolation plus PII tokenisation.
- **Save and reuse what works**: files for state, functions and skills for capability.

Anthropic encourages developers who implement this approach to share their findings with the MCP community.

------

[^anthropic-post]: [Code execution with MCP: Building more efficient agents — Anthropic, Nov 4, 2025](https://www.anthropic.com/research/code-execution-with-mcp){:target="_blank" rel="noopener noreferrer"}

[^cloudflare]: [Code Mode: the better way to use MCP — Cloudflare Blog](https://blog.cloudflare.com/code-mode/){:target="_blank" rel="noopener noreferrer"}

[^skills]: [Agent Skills — Anthropic](https://www.anthropic.com/news/skills){:target="_blank" rel="noopener noreferrer"}

[^anthropic-post]: [Code execution with MCP: Building more efficient agents — Anthropic Engineering, Nov 4, 2025](https://www.anthropic.com/research/code-execution-with-mcp){:target="_blank" rel="noopener noreferrer"}

[^LangChain-DeepAgent]:[LangChain Deep Agent on Amazon Bedrock]({% link _posts/2026-11-09-LangcainDeepAgent.md %}){:target="_blank" rel="noopener noreferrer"}

[^anthropic-1]: [Code execution with MCP for efficient agents \ Anthropic](https://www.anthropic.com/research/code-execution-with-mcp){:target="_blank" rel="noopener noreferrer"}


{:gtxt: .message color="green"}
{:ytxt: .message color="yellow"}
{:rtxt: .message color="red"}
