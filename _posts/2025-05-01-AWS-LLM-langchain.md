---
layout: post
title:  LangChain for AWS Bedrock
date:   2025-05-01
categories: [AI, AWS, LangChain]
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
        <img src="/assets/images/2025-05-01-AWS-LLM-langchain/AWS_LC_cartoon.png" alt="ADFS SSO for Kibana Diagram">
    </div>
    <div class="text-column">
This second part describes how to integrate LangChain with AWS Bedrock to build AI applications. It covers the implementation of AWS Bedrock with Amazon Titan and Claude models, as well as key LangChain components, including prompt templates, embeddings, memory, and chains. Code examples demonstrate everything from basic model invocation to creating conversational agents with memory, perfect for developers building production AI solutions.
    </div>
</div>

📚 The [first part]({% post_url 2025-04-27-AWS-LLM-Basics %}) explained the LLM basics of AWS Bedrock.

<!--more-->

------

* TOC
{:toc}
------

## LangChain



![AWS_LC_cartoon](/assets/images/2025-05-01-AWS-LLM-langchain/AWS_LC_cartoon.png)LangChain can integrate large language models (LLMS) with other sources of data. LangChain Expression Language, or LCEL[^4], is a declarative way to compose chains together easily. LangChain integrations are:

- models
- Prompt templates
- indexes (AWS Kendra)
- Memory: The **memory** component provides the mechanism to store and summarise prior conversational elements that are included in the context on subsequent invocations.
- Chain
- Agents: LangChain **agents** can interact with external sources, such as search engines, calculators, APIs or databases. **Agents** can also run code to perform actions to assist the LLMs in generating accurate responses.

The **retriever** is the component responsible for fetching relevant documents to be combined with language models.
The **document loaders** component is responsible for loading documents from various sources. The **VectorStore** class is used to query supported vector stores for relevant data. 

### Setup

You have to install the following packages[^1] before using LangChain with AWS Bedrock:

```bash
pip install langchain-aws
pip install langchain-community boto3
pip install langgraph
```

## Models

The simplest example is the following, which demonstrates how to create an instance of the Amazon Bedrock class and invoke an Amazon Titan LLM from the LangChain LLM module.

```python
import boto3
from langchain_aws import BedrockLLM

bedrock_client = boto3.client(service_name="bedrock-runtime", region_name="ap-southeast-2")
inference_modifiers = {"temperature": 0.3, "maxTokenCount": 512}
llm = BedrockLLM(
    client=bedrock_client,
    model_id='amazon.titan-text-express-v1',
    # model_id= "amazon.nova-micro-v1:0", # not working

    model_kwargs =inference_modifiers,
    streaming=True
)
response = llm.invoke("What is the largest city in Australia?")
print(response)
```

I have used the Bedrock user guide[^2] to select the `service_name` above.

LangChain offers a chat model component for building conversational applications.

```python
from langchain_aws import ChatBedrock as Bedrock
from langchain.schema import HumanMessage

chat = Bedrock(
    model_id="anthropic.claude-3-5-sonnet-20241022-v2:0",
    model_kwargs={"temperature": 0.3, "max_tokens": 512},
    streaming=True,
)
messages = [
    HumanMessage(content="What is the largest city in Sri Lanka?"),
    HumanMessage(content="What is the capital of Sri Lanka?")
    ]

response = chat(messages)   
print(response)
```

output is

```
content='Colombo is the largest city in Sri Lanka.\n\nSri Jayawardenepura Kotte (commonly known as Kotte) is the official administrative capital of Sri Lanka.\n\nHowever, Colombo is still considered the commercial capital and the seat of most government institutions, making it the de facto capital of the country. Many people often refer to Colombo as the capital due to its prominence and importance in Sri Lankan affairs.' additional_kwargs={} response_metadata={'stop_reason': 'end_turn', 'stop_sequence': None, 'model_name': 'anthropic.claude-3-5-sonnet-20241022-v2:0'} id='run-515565ac-8aad-4eb0-849d-4f09f8bd1348-0' usage_metadata={'input_tokens': 24, 'output_tokens': 95, 'total_tokens': 119, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}
```

When you change the questions to find out about 'Australia' instead of 'Sri Lanka':

```python
messages = [
    HumanMessage(content="What is the largest city in Australia?"),
    HumanMessage(content="What is the capital of Australia?")
    ]
```

The output is:

```
content="Sydney is the largest city in Australia by population, with approximately 5.3 million people in its metropolitan area.\n\nCanberra is the capital city of Australia. It was purposely built to serve as the nation's capital as a compromise between rivals Sydney and Melbourne. Canberra became the capital in 1927.\n\nWhile Sydney is the largest city and many people mistakenly think it's the capital, Canberra was specifically chosen and designed to be Australia's capital city." additional_kwargs={} response_metadata={'stop_reason': 'end_turn', 'stop_sequence': None, 'model_name': 'anthropic.claude-3-5-sonnet-20241022-v2:0'} id='run-b9f56f8b-f66b-440a-8c46-91b65b5eef46-0' usage_metadata={'input_tokens': 24, 'output_tokens': 107, 'total_tokens': 131, 'input_token_details': {'cache_creation': 0, 'cache_read': 0}}
```

### LangChain 3

To install the latest LangChain version 3:

Create a new environment and activate:

```bash
pyenv virtualenv 3.11.10 langchain
pyenv activate langchain
python -m pip install --upgrade pip
```

Install LangChain 3.0

```bash
pip install langchain[aws]
```

For example:

```python
# Ensure your AWS credentials are configured

from langchain.chat_models import init_chat_model
from langchain_core.messages import HumanMessage, SystemMessage

model = init_chat_model("anthropic.claude-3-sonnet-20240229-v1:0", model_provider="bedrock_converse")

messages = [
    SystemMessage("Create a list with the most popular sightseeing places"),
    HumanMessage("Sir Lanka"),

]

response = model.invoke(messages)
print(response.content)
```

Output:

```
Here are some of the most popular sightseeing places in Sri Lanka:

1. Sigiriya Rock Fortress - An ancient rock fortress with impressive ruins and frescoes on top of a massive rock plateau.

2. Dambulla Cave Temple - This vast cave monastery has ornate carved images of Buddha and frescoes dating back to the 1st century BC.

3. Temple of the Tooth Relic (Sri Dalada Maligawa) - A famous Buddhist temple in Kandy which houses the sacred tooth relic of Buddha.

4. Galle Dutch Fort - A UNESCO World Heritage site, this 17th-century fortified city is known for its Dutch colonial architecture.

5. Yala National Park - One of the best places to spot leopards, elephants, sloth bears, and diverse birdlife.

6. Horton Plains National Park - A scenic plateau with misty landscapes, forests, and the famous World's End precipice.

7. Anuradhapura - The capital of ancient Sri Lanka has incredible archaeological sites with Buddhist monuments and stupas.

8. Polonnaruwa - Another ancient capital city with well-preserved ruins of temples, royal palaces, and the Gal Vihara Buddha statues.

9. Mirissa Beach - A beautiful crescent-shaped beach known for whale and dolphin watching tours.

10. Nuwara Eliya - A hill station town with colonial architecture, tea plantations, and cooler temperatures.
```



## Prompt Templates

Prompt templates help to translate user input and parameters into instructions for a language model[^5].

## Indexes

Text embedding models take text as input and then output numerical representations of the text as a vector of floating-point numbers. The embedding vector represents the phrase's semantics, not its string representation. 

```python
from langchain_community.embeddings import BedrockEmbeddings
embeddings = BedrockEmbeddings(
    region_name="ap-southeast-2",
    model_id="amazon.titan-embed-image-v1"
)

embeddings.embed_query("cats are pets.")
```

Output:

```
[-0.00579834,
 -0.016479492,
 -0.029541016,
 -0.0028381348,
 0.016235352,
 ...
 ...
 ...]
```

Instead of text, you can load documents[^3] to retrieve large data sets from documents such as PDF, HTML, etc. The cognitive search tool Amazon Kendra will index and query various data sources for the RAG applications. It is a fully managed service that provides semantic search capabilities.

## Memory

LLM can respond in a human-like manner if it can remember previous interactions with the user. However, LLMS are stateless in the conversation by default; therefore, prompts must maintain the conversation history, which LangChain can do. For example:

```python
import boto3
from langchain_aws import BedrockLLM
from langchain.chains import ConversationChain
from langchain.memory import ConversationBufferMemory
from langchain_core.prompts import ChatPromptTemplate


template = """
You are a tourist. Answer the following questions as best you can.
Chat history: {history}
Question: {input}
"""

prompt = ChatPromptTemplate.from_template(template)
bedrock_client = boto3.client('bedrock-runtime',region_name="ap-southeast-2")
titan_llm = BedrockLLM(model_id="amazon.titan-text-express-v1", client=bedrock_client)
memory = ConversationBufferMemory()

chain = ConversationChain(
    llm=titan_llm, verbose=True, memory=memory, prompt=prompt,
)

chain({"input": "Hi! I am in Sri Lanka. What are some of the tourist sightseeing places?"})
```

Output:

```
{'input': 'Hi! I am in Sri Lanka. What are some of the tourist sightseeing places?',
 'history': '',
 'response': 'Bot: Hi! I am a chatbot designed by Wix. I can provide you with a list of tourist sightseeing places in Sri Lanka.\n\nHere are some of the tourist sightseeing places in Sri Lanka:\n1. Sigiriya\n2. Kandy\n3. Nuwara Eliya\n4. Galle\n5. Yala National Park\n\nWould you like to know more about these places?'}
```

Then you can ask the second question based on the above:

```python
print(conversation.predict(input="...?"))
```

and so on.

## Chain

A chain is a set of components that run together. Chain calls a set of other chains, creating complex workflows.

```python
from langchain import PromptTemplate
from langchain.chains import LLMChain
from langchain_aws import ChatBedrock as Bedrock

chat = Bedrock(
     region_name = "ap-southeast-2",
     model_kwargs={"temperature":1,"top_k":250,"top_p":0.999,"anthropic_version":"bedrock-2023-05-31"},
     model_id="anthropic.claude-3-sonnet-20240229-v1:0"
)

multi_var_prompt = PromptTemplate(
     input_variables=["country"],
     template="Create a list with the most popular sightseeing places of the {country}?",
)
 
chain = LLMChain(llm=chat, prompt=multi_var_prompt)
answers = chain.invoke("Sri Lanka")
print(answers)

```

Output:

```
{'country': 'Sri Lanka', 'text': "Sri Lanka is renowned for its rich cultural heritage, stunning natural landscapes, and ancient architectural marvels. Here's a list of some of the most popular sightseeing places in Sri Lanka:\n\n1. Sigiriya Rock Fortress\n2. Dambulla Cave Temple\n3. Temple of the Tooth Relic (Sri Dalada Maligawa) in Kandy\n4. Galle Dutch Fort\n5. Yala National Park\n6. Mirissa Beach\n7. Ella Rock\n8. Nuwara Eliya (Tea Plantations and Hill Country)\n9. Polonnaruwa Ancient City\n10. Anuradhapura Ancient City\n11. Arugam Bay (for surfing)\n12. Horton Plains National Park\n13. Pinnawala Elephant Orphanage\n14. Sinharaja Forest Reserve\n15. Mihintale\n16. Minneriya National Park\n17. Bundala National Park\n18. Knuckles Mountain Range\n19. Kirigalpoththa Archaeological Reserve\n20. Ranweli Wewa (Ranweli Lake)\n\nThese places showcase Sri Lanka's rich cultural heritage, stunning natural beauty, ancient cities, wildlife reserves, beaches, and more. The list provides a diverse range of experiences, from exploring UNESCO World Heritage Sites to enjoying outdoor adventures and scenic landscapes."}
```

The following mechanisms are used in the basic chain:

1. RAG Application
2. RouterChain
3. LangChain agents



For more information, see the workshop[^6].

{:rtxt: .message color="red"} 


{:gtxt: .message color="green"} 

[^1]: [AWS 🦜️🔗 LangChain](https://python.langchain.com/docs/integrations/providers/aws/)

[^2]: [AWS Bedrock user guide](https://docs.aws.amazon.com/pdfs/bedrock/latest/userguide/bedrock-ug.pdf)

[^3]: [How-to guides 🦜️🔗 LangChain](https://python.langchain.com/docs/how_to/#document-loaders)

[^4]: [LangChain Expression Language (LCEL) 🦜️🔗 LangChain](https://python.langchain.com/v0.1/docs/expression_language/)

[^5]: [Prompt Templates 🦜️🔗 LangChain](https://python.langchain.com/docs/concepts/prompt_templates/)

[^6]: [Amazon Bedrock Workshop](https://catalog.us-east-1.prod.workshops.aws/amazon-bedrock/en-US)
