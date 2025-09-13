---
layout: post
title:  LlamaIndex RAG for Science Community
date:   2025-09-12
maths: true
categories: [AI, LlamaIndex, OpenAI, RAG]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

<style>
/* Styles for the two-column layout */
.image-text-container {
    display: flex; /* Enables flexbox */
    flex-wrap: wrap; /* Allows columns to stack on small screens */
    gap: 10px; /* Space between the image and text */
    align-items: left; /* Vertically centers content in columns */
    margin-bottom: 20px; /* Space below this section */
}

.image-column {
    flex: 1; /* Allows this column to grow */
    min-width: 150px; /* Minimum width for the image column before stacking */
    max-width: 20%; /* Maximum width for the image column to not take up too much space initially */
    box-sizing: border-box; /* Include padding/border in element's total width/height */
}

.text-column {
    flex: 2; /* Allows this column to grow more (e.g., twice as much as image-column) */
    min-width: 300px; /* Minimum width for the text column before stacking */
    box-sizing: border-box;
}

</style>

<div class="image-text-container">
    <div class="image-column">
        <img src="/assets/images/2025-09-12-LlamaIndexScienceCommunityChat/llamaindex_ink_drawing.svg" alt="LangGraph Testing Sketch" width="150" height="150">
    </div>
    <div class="text-column">
<p>
 LlamaIndex is a comprehensive data framework designed to connect large language models with private data sources through Retrieval-Augmented Generation (RAG) architecture. The framework operates through two main stages: indexing, where vector embeddings are created from documents, and querying, where relevant information is retrieved and synthesized. LlamaIndex supports multiple chat engines including condense question, context, and condense-plus-context modes for enhanced conversational AI applications. Quality evaluation is crucial for RAG performance, utilizing metrics like Mean Reciprocal Rank (MRR) and Hit Rate to assess retrieval accuracy. The framework includes faithfulness and relevance evaluators to measure response quality, making it essential for building reliable AI applications that require domain-specific knowledge integration with seamless LLM integration capabilities.
</p>
    </div>
</div>

<!--more-->

📝 source: [Jupyter Notebook](https://github.com/ojitha/rag_llamaindex/blob/main/Science_Community/2025-09-12-LlamaIndexScienceCommunityChat.ipynb){:target="_blank"}

------

* TOC
{:toc}
------

## Introduction
LlamaIndex is a data framework designed to help developers build applications that connect large language models (LLMs) with their own private or custom data sources. It serves as a bridge between LLMs and external data, enabling you to create AI applications that can reason over your specific information.

### What is LlamaIndex?
The main challenge LlamaIndex addresses is that while LLMs like GPT-4 or Claude are trained on vast amounts of general knowledge, they don't have access to your specific data - whether that's company documents, personal files, databases, or real-time information. LlamaIndex provides the infrastructure to make your data "queryable" by LLMs.
Introducint Llama-index components with OpenAI

Key Features
- Data Ingestion: LlamaIndex can connect to various data sources including:
    - Documents (PDFs, Word files, text files)
    - Databases (SQL, NoSQL)
    - APIs and web services
    - Vector databases
    - Knowledge graphs
- Indexing and Retrieval: It creates searchable indexes of your data using techniques like:
    - Vector embeddings for semantic search
    - Keyword-based retrieval
    - Hybrid search approaches
    - Hierarchical indexing for large datasets
- Query Processing: When you ask a question, LlamaIndex:
    - Retrieves the most relevant pieces of information from your indexed data
    - Provides that context to the LLM
    - Returns an answer based on your specific data

### Core Architecture Components
The LlamaIndex ecosystem is built around three fundamental stages and components. As outlined in _Generative AI for Cloud Solutions_[^1], LlamaIndex operates through two main stages:

1. **Indexing stage**: In this stage, LlamaIndex creates a vector index of your private data. This makes it possible to search through your own organization's domain-specific knowledge base. You can input text documents, database records, knowledge graphs, and other data types. 

2. **Querying stage**: In this stage, the RAG pipeline finds the most relevant information based on the user's query. This information is then passed to the LLM, along with the query, to generate a more accurate response."

The framework then implements these stages through three main components:

1. Data Loading: LlamaIndex provides data connectors, they allow you to pull data from wherever it is stored, such as APIs, PDFs, databases, or external apps.
2. Data Indexes: This includes creating vector embeddings and adding metadata to make information retrievable.
3. Stroing: Once the embeddings have been created, they are stored to be queried. Llama­Index has multiple storage solutions.
4. Engines: This engine takes a natural language query, retrieves relevant information from the index, and passes it to an LLM. You can feed a query via prompt and get the retrieved context with the LLM’s answer using different strategies: Condensce, Context and Condense+context. This includes query engines that combine retrieval and synthesis capabilities[^2].
5. Evaluating: RAG solution is an iterative process that can work only if you evaluate your LLM answers for query prompts. LlamaIndex provides tooling to measure how accurate and so on.

At the foundational level, LlamaIndex works with Documents and Nodes as its basic building blocks.Documents represent raw data sources, while Nodes are coherent, indexable chunks of information parsed from Documents[^4].

### Integration
LlamaIndex integrates with popular LLM providers (OpenAI, Anthropic, local models) and vector databases (Pinecone, Chroma, Weaviate), making it quite flexible for different technical stacks. The framework essentially democratizes the ability to create "ChatGPT for your data" applications without needing to build all the retrieval and indexing infrastructure from scratch.

> You have to setup the environmen (eg: ChatGPT API Key) and the other housekeeping functions:


```python
%load_ext dotenv
%dotenv ../../../.env

from IPython.display import Markdown, display
def in_md(md_txt):
    md_formated_txt = f"--- Response -------<br/>{md_txt}<br/>-------------------"
    display(Markdown(md_formated_txt))
```

In the "data" directory contains all the text file to vectorise:


```python
from llama_index.core import SimpleDirectoryReader
documents =SimpleDirectoryReader(
    input_dir="./data").load_data()
```

Setup LLM


```python
from llama_index.core import Settings
from llama_index.embeddings.openai import OpenAIEmbedding
from llama_index.llms.openai import OpenAI


llm = OpenAI(model="gpt-4o", temperature=0.3)
embed_model = OpenAIEmbedding()

Settings.llm = llm
Settings.embed_model = embed_model
```

Crete Nodes


```python
from llama_index.core.node_parser import TokenTextSplitter


splittter = TokenTextSplitter(
    chunk_size= 1024,
    chunk_overlap=20
)
nodes = splittter.get_nodes_from_documents(documents)
```


```python
import pprint

pprint.pprint(nodes[0], indent=2)
```

    TextNode(id_='cd821c26-64cf-4755-98f2-9e831ab0d306', embedding=None, metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/AlbertEinstein.txt', 'file_name': 'AlbertEinstein.txt', 'file_type': 'text/plain', 'file_size': 8235, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, excluded_embed_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], excluded_llm_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], relationships={<NodeRelationship.SOURCE: '1'>: RelatedNodeInfo(node_id='2a37d51d-ac93-4091-aad5-06b963941e44', node_type=<ObjectType.DOCUMENT: '4'>, metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/AlbertEinstein.txt', 'file_name': 'AlbertEinstein.txt', 'file_type': 'text/plain', 'file_size': 8235, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, hash='ebbeab8f1fb4d45db4be9071d503bd1d253736c0a2213119e2ac3946f6f207d0'), <NodeRelationship.NEXT: '3'>: RelatedNodeInfo(node_id='c69ff2bd-5b11-4201-ae2d-2c02163add35', node_type=<ObjectType.TEXT: '1'>, metadata={}, hash='7f6bac3350f6db083a409040284e8883997660c647b36ff4bb89c3fbe9b775f3')}, metadata_template='{key}: {value}', metadata_separator='\n', text='# Albert Einstein: A Biography\n\n## Early Life (1879-1896)\n\nAlbert Einstein was born on March 14, 1879, in Ulm, in the Kingdom of Württemberg in the German Empire. His parents were Hermann Einstein, a salesman and engineer, and Pauline Koch Einstein. When Albert was one year old, the family moved to Munich, where his father and uncle founded Elektrotechnische Fabrik J. Einstein & Cie, a company that manufactured electrical equipment.\n\nEinstein showed early signs of intellectual curiosity, though contrary to popular myth, he was not a poor student. He excelled in mathematics and physics from a young age. When he was five, his father gave him a compass, and Einstein was fascinated by the invisible forces that moved the needle—an experience he later described as pivotal in developing his scientific curiosity.\n\nIn 1894, Einstein\'s family moved to Italy for business reasons, but Albert remained in Munich to finish his education. However, he left school early and rejoined his family in Italy. He then applied to the Swiss Federal Polytechnic in Zurich but failed the entrance exam, though he scored exceptionally well in mathematics and physics. After completing his secondary education in Switzerland, he was accepted to the Polytechnic in 1896.\n\n## Education and Early Career (1896-1905)\n\nEinstein studied at the Swiss Federal Polytechnic from 1896 to 1900, where he met Mileva Marić, a fellow physics student who would later become his first wife. After graduating in 1900, Einstein struggled to find academic employment and worked various temporary jobs, including as a tutor and substitute teacher.\n\nIn 1902, he secured a position at the Swiss Patent Office in Bern, where he worked as a technical assistant examiner. This job provided him with financial stability and, perhaps more importantly, time to pursue his own scientific research. The work at the patent office also exposed him to practical applications of electromagnetic theory, which influenced his later work.\n\nEinstein earned his doctorate from the University of Zurich in 1905 with a dissertation titled "On a New Determination of Molecular Dimensions."\n\n## The Miracle Year (1905)\n\n1905 became known as Einstein\'s "Annus Mirabilis" (miracle year) because he published four groundbreaking papers that revolutionized physics:\n\n### 1. Photoelectric Effect\nEinstein\'s paper on the photoelectric effect explained how light could behave as particles (photons), providing crucial evidence for quantum theory. This work earned him the Nobel Prize in Physics in 1921.\n\n### 2. Brownian Motion\nHis explanation of Brownian motion provided empirical evidence for the existence of atoms and molecules, convincing skeptics of atomic theory.\n\n### 3. Special Theory of Relativity\nPerhaps his most famous contribution, special relativity introduced the concept that space and time are interwoven into spacetime, and that the speed of light is constant for all observers. This theory challenged Newton\'s absolute concepts of space and time.\n\n### 4. Mass-Energy Equivalence\nThe famous equation E=mc² emerged from his work on special relativity, showing that mass and energy are interchangeable.\n\n## Academic Career and General Relativity (1905-1915)\n\nFollowing his 1905 publications, Einstein gained recognition in the scientific community. He moved through various academic positions:\n\n- 1908: Lecturer at the University of Bern\n- 1909: Professor at the University of Zurich\n- 1911: Professor at Charles University in Prague\n- 1912: Professor at ETH Zurich\n- 1914: Director of the Kaiser Wilhelm Institute for Physics in Berlin\n\nDuring this period, Einstein worked on extending his special theory of relativity to include gravity. In 1915, he completed his General Theory of Relativity, which described gravity not as a force, but as a curvature of spacetime caused by mass and energy. This theory made several predictions that were later confirmed experimentally, including the bending of light around massive objects.\n\n## International Fame (1915-1933)\n\nEinstein\'s general relativity gained worldwide attention when Sir Arthur Eddington\'s 1919 solar eclipse expedition confirmed the theory\'s prediction that light would bend around the sun. Overnight, Einstein became an international celebrity and the face of modern science.\n\nDuring this period, Einstein made significant contributions to quantum mechanics, statistical mechanics, and cosmology, though he remained skeptical of quantum mechanics\' probabilistic interpretation, famously stating "God does not play dice with the universe."\n\n## Personal Life\n\nEinstein married Mileva Marić in 1903, and they had two sons: Hans Albert and Eduard. The couple also had a daughter, Lieserl, born before their marriage, whose fate remains unknown. Einstein and Mileva divorced in 1919.\n\nLater in 1919, Einstein married', mimetype='text/plain', start_char_idx=0, end_char_idx=4824, metadata_seperator='\n', text_template='{metadata_str}\n\n{content}')


Using embedding models, texts are **encoded** into fixed-length numerical vectors that are intended to capture semantic meaning. Queries are also encoded so that the similarity between them and the node vectors can be measured using geometric operations. In this case, nodes are embedded in vectors and stored in a specialized index such as **VectorStoreIndex** where Dense retrieval is possible.

> We call them **dense** because these vectors are typically densely populated with non-zero values, representing rich and nuanced semantic information in a compact form. During retrieval, incoming queries are dynamically embedded and used to retrieve the top-k nodes using similarity search algorithms.


```python
from llama_index.core import VectorStoreIndex


index = VectorStoreIndex(nodes)
```

    2025-09-12 20:21:23,238 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"


> The `similarity_top_k` is the  number of most similar chunks or nodes retrieved for a given query.
{:.info-box}


```python
q_engine = index.as_query_engine(similarity_top_k = 5) 
```


```python
response = q_engine.query("who are the scientists in these documents?")
```

    2025-09-12 20:21:23,746 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:21:26,220 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(response.response)
```


--- Response -------<br/>The documents mention several scientists, including Albert Einstein, Marie Curie, Paul Langevin, Max Planck, Henri Poincaré, Ernest Rutherford, Hendrik Lorentz, and Niels Bohr.<br/>-------------------



```python
len(response.source_nodes)
```




    5




```python
response.source_nodes[4]
```




    NodeWithScore(node=TextNode(id_='cd821c26-64cf-4755-98f2-9e831ab0d306', embedding=None, metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/AlbertEinstein.txt', 'file_name': 'AlbertEinstein.txt', 'file_type': 'text/plain', 'file_size': 8235, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, excluded_embed_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], excluded_llm_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], relationships={<NodeRelationship.SOURCE: '1'>: RelatedNodeInfo(node_id='2a37d51d-ac93-4091-aad5-06b963941e44', node_type='4', metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/AlbertEinstein.txt', 'file_name': 'AlbertEinstein.txt', 'file_type': 'text/plain', 'file_size': 8235, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, hash='ebbeab8f1fb4d45db4be9071d503bd1d253736c0a2213119e2ac3946f6f207d0'), <NodeRelationship.NEXT: '3'>: RelatedNodeInfo(node_id='c69ff2bd-5b11-4201-ae2d-2c02163add35', node_type='1', metadata={}, hash='7f6bac3350f6db083a409040284e8883997660c647b36ff4bb89c3fbe9b775f3')}, metadata_template='{key}: {value}', metadata_separator='\n', text='# Albert Einstein: A Biography\n\n## Early Life (1879-1896)\n\nAlbert Einstein was born on March 14, 1879, in Ulm, in the Kingdom of Württemberg in the German Empire. His parents were Hermann Einstein, a salesman and engineer, and Pauline Koch Einstein. When Albert was one year old, the family moved to Munich, where his father and uncle founded Elektrotechnische Fabrik J. Einstein & Cie, a company that manufactured electrical equipment.\n\nEinstein showed early signs of intellectual curiosity, though contrary to popular myth, he was not a poor student. He excelled in mathematics and physics from a young age. When he was five, his father gave him a compass, and Einstein was fascinated by the invisible forces that moved the needle—an experience he later described as pivotal in developing his scientific curiosity.\n\nIn 1894, Einstein\'s family moved to Italy for business reasons, but Albert remained in Munich to finish his education. However, he left school early and rejoined his family in Italy. He then applied to the Swiss Federal Polytechnic in Zurich but failed the entrance exam, though he scored exceptionally well in mathematics and physics. After completing his secondary education in Switzerland, he was accepted to the Polytechnic in 1896.\n\n## Education and Early Career (1896-1905)\n\nEinstein studied at the Swiss Federal Polytechnic from 1896 to 1900, where he met Mileva Marić, a fellow physics student who would later become his first wife. After graduating in 1900, Einstein struggled to find academic employment and worked various temporary jobs, including as a tutor and substitute teacher.\n\nIn 1902, he secured a position at the Swiss Patent Office in Bern, where he worked as a technical assistant examiner. This job provided him with financial stability and, perhaps more importantly, time to pursue his own scientific research. The work at the patent office also exposed him to practical applications of electromagnetic theory, which influenced his later work.\n\nEinstein earned his doctorate from the University of Zurich in 1905 with a dissertation titled "On a New Determination of Molecular Dimensions."\n\n## The Miracle Year (1905)\n\n1905 became known as Einstein\'s "Annus Mirabilis" (miracle year) because he published four groundbreaking papers that revolutionized physics:\n\n### 1. Photoelectric Effect\nEinstein\'s paper on the photoelectric effect explained how light could behave as particles (photons), providing crucial evidence for quantum theory. This work earned him the Nobel Prize in Physics in 1921.\n\n### 2. Brownian Motion\nHis explanation of Brownian motion provided empirical evidence for the existence of atoms and molecules, convincing skeptics of atomic theory.\n\n### 3. Special Theory of Relativity\nPerhaps his most famous contribution, special relativity introduced the concept that space and time are interwoven into spacetime, and that the speed of light is constant for all observers. This theory challenged Newton\'s absolute concepts of space and time.\n\n### 4. Mass-Energy Equivalence\nThe famous equation E=mc² emerged from his work on special relativity, showing that mass and energy are interchangeable.\n\n## Academic Career and General Relativity (1905-1915)\n\nFollowing his 1905 publications, Einstein gained recognition in the scientific community. He moved through various academic positions:\n\n- 1908: Lecturer at the University of Bern\n- 1909: Professor at the University of Zurich\n- 1911: Professor at Charles University in Prague\n- 1912: Professor at ETH Zurich\n- 1914: Director of the Kaiser Wilhelm Institute for Physics in Berlin\n\nDuring this period, Einstein worked on extending his special theory of relativity to include gravity. In 1915, he completed his General Theory of Relativity, which described gravity not as a force, but as a curvature of spacetime caused by mass and energy. This theory made several predictions that were later confirmed experimentally, including the bending of light around massive objects.\n\n## International Fame (1915-1933)\n\nEinstein\'s general relativity gained worldwide attention when Sir Arthur Eddington\'s 1919 solar eclipse expedition confirmed the theory\'s prediction that light would bend around the sun. Overnight, Einstein became an international celebrity and the face of modern science.\n\nDuring this period, Einstein made significant contributions to quantum mechanics, statistical mechanics, and cosmology, though he remained skeptical of quantum mechanics\' probabilistic interpretation, famously stating "God does not play dice with the universe."\n\n## Personal Life\n\nEinstein married Mileva Marić in 1903, and they had two sons: Hans Albert and Eduard. The couple also had a daughter, Lieserl, born before their marriage, whose fate remains unknown. Einstein and Mileva divorced in 1919.\n\nLater in 1919, Einstein married', mimetype='text/plain', start_char_idx=0, end_char_idx=4824, metadata_seperator='\n', text_template='{metadata_str}\n\n{content}'), score=0.7521222064033365)



### Summarization


```python
from llama_index.core import SummaryIndex


summary_index = SummaryIndex(nodes)
s_engine = summary_index.as_query_engine()
```


```python
summary = s_engine.query("Povide the summary")
```

    2025-09-12 20:21:29,052 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(summary.response)
```


--- Response -------<br/>Albert Einstein and Marie Curie, two of the most influential scientists of the early 20th century, first met at the 1911 Solvay Conference in Brussels. Despite the personal challenges they faced—Curie with a scandal in the French press and Einstein as a Jewish outsider—they formed a mutual respect and friendship. Their initial meeting was marked by deep conversations about their groundbreaking work in physics, with Einstein admiring Curie's dedication to isolating radium and Curie intrigued by Einstein's theory of relativity. This meeting laid the foundation for a lasting intellectual partnership, characterized by shared scientific interests and personal understanding.<br/>-------------------


## Chat Engines
Using LlamaIndex, you can
- Q&A
- Summarise
- Chat Engines
    1. Condense Question
    2. Context Question 
    3. Condense+Context Question

I am using the same question test to compare the differences of thes 3 chat engines:

- who are the scientists in these documents?
- Have these scientist met in their lifetime?
- what are the topics they discussed?
- what are the other topics they discussed?
- Which physicist who had a romantic relationship with Marie Curie?
- what happen after that?
- what happen after that?

The dataset is in the `data` folder.


### Condense Question Chat Engine

A component that generates a standalone question from the conversation context and last message, then queries the index to provide a response.


```python
cq_c_engine = index.as_chat_engine("condense_question", verbose=True)
```


```python
cq_c_response = cq_c_engine.chat("who are the scientists in these documents?")
```

    2025-09-12 20:21:29,089 - INFO - Querying with: who are the scientists in these documents?


    Querying with: who are the scientists in these documents?


    2025-09-12 20:21:29,925 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:21:32,280 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(cq_c_response.response)
```


--- Response -------<br/>The scientists mentioned in the documents include Albert Einstein, Marie Curie, Paul Langevin, Max Planck, Henri Poincaré, Ernest Rutherford, Hendrik Lorentz, and Niels Bohr. Additionally, the 1911 First Solvay Conference attendees listed are Walther Nernst, Marcel Brillouin, Ernest Solvay, Emil Warburg, Jean Baptiste Perrin, Wilhelm Wien, Robert Goldschmidt, Heinrich Rubens, Arnold Sommerfeld, Frederick Lindemann, Maurice de Broglie, Martin Knudsen, Friedrich Hasenöhrl, Georges Hostelet, Edouard Herzen, James Hopwood Jeans, and Heike Kamerlingh Onnes.<br/>-------------------



```python
cq_c_response = cq_c_engine.chat("Have these scientist met in their lifetime?")
```

    2025-09-12 20:21:33,682 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:21:33,684 - INFO - Querying with: Did the scientists mentioned, such as Albert Einstein, Marie Curie, and the attendees of the 1911 First Solvay Conference, meet each other during their lifetimes?


    Querying with: Did the scientists mentioned, such as Albert Einstein, Marie Curie, and the attendees of the 1911 First Solvay Conference, meet each other during their lifetimes?


    2025-09-12 20:21:33,989 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:21:35,729 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(cq_c_response.response)
```


--- Response -------<br/>Yes, the scientists mentioned, including Albert Einstein, Marie Curie, and the attendees of the 1911 First Solvay Conference, did meet each other during their lifetimes. They gathered at the Solvay Conferences, which were significant events for discussing advancements in physics and brought together many of the leading scientific minds of the time.<br/>-------------------


In the document `Components/data/AlbertEinstein.txt` has been mentioned this meeting.


```python
cq_c_response = cq_c_engine.chat("what are the topics they discussed?")
```

    2025-09-12 20:21:37,061 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:21:37,064 - INFO - Querying with: What topics were discussed by the scientists, including Albert Einstein, Marie Curie, and the attendees of the 1911 First Solvay Conference, when they met during their lifetimes?


    Querying with: What topics were discussed by the scientists, including Albert Einstein, Marie Curie, and the attendees of the 1911 First Solvay Conference, when they met during their lifetimes?


    2025-09-12 20:21:37,367 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:21:40,329 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(cq_c_response.response)
```


--- Response -------<br/>During the 1911 First Solvay Conference, the scientists, including Albert Einstein, Marie Curie, and other attendees, primarily discussed the revolutionary concept of quantum theory. This gathering of prominent physicists focused on the latest developments and challenges in understanding quantum mechanics, an area that was rapidly reshaping the scientific landscape at the time. Additionally, Einstein and Curie engaged in discussions about the implications of their respective work, such as the behavior of radioactive decay in curved spacetime, reflecting their deep interest in the intersection of their scientific pursuits.<br/>-------------------



```python
cq_c_response = cq_c_engine.chat("what are the other topics they discussed?")
```

    2025-09-12 20:21:42,288 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:21:42,297 - INFO - Querying with: What other topics, besides quantum theory and the implications of Einstein's and Curie's work, did the scientists discuss at the 1911 First Solvay Conference?


    Querying with: What other topics, besides quantum theory and the implications of Einstein's and Curie's work, did the scientists discuss at the 1911 First Solvay Conference?


    2025-09-12 20:21:42,618 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:21:44,043 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(cq_c_response.response)
```


--- Response -------<br/>At the 1911 First Solvay Conference, besides quantum theory and the implications of Einstein's and Curie's work, the scientists also discussed their shared concerns about the growing tensions in Europe. Additionally, they likely engaged in conversations about their experiences as outsiders in the scientific community, given the challenges both faced—Curie as a woman and Einstein as a Jew.<br/>-------------------



```python
cq_c_response = cq_c_engine.chat("What are the most significant things that have happened among them?")
```

    2025-09-12 20:21:45,725 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:21:45,727 - INFO - Querying with: What are the most significant events or developments that occurred among the scientists who attended the 1911 First Solvay Conference, including Albert Einstein and Marie Curie?


    Querying with: What are the most significant events or developments that occurred among the scientists who attended the 1911 First Solvay Conference, including Albert Einstein and Marie Curie?


    2025-09-12 20:21:46,093 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:21:53,045 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(cq_c_response.response) 
```


--- Response -------<br/>The 1911 First Solvay Conference was a pivotal event in the history of physics, bringing together many of the greatest scientific minds of the time to discuss quantum theory. Among the significant developments and interactions:

1. **Quantum Theory Discussions**: The conference was primarily focused on the revolutionary concept of quantum theory, which was still in its early stages of development. This gathering allowed for the exchange of ideas that would shape the future of physics.

2. **Marie Curie and Albert Einstein's Interaction**: A notable event was the meeting between Marie Curie and Albert Einstein. They engaged in deep discussions about their work, with Curie expressing interest in how radioactive decay might behave in Einstein's curved spacetime.

3. **Mutual Support and Respect**: Einstein expressed his admiration for Curie's work and offered support during a time when she was facing personal scandal. Their mutual respect and understanding of each other's challenges as outsiders in the scientific community were significant.

4. **Networking and Collaboration**: The conference provided an opportunity for scientists like Max Planck, Henri Poincaré, Ernest Rutherford, and Hendrik Lorentz to interact and collaborate, fostering relationships that would lead to further scientific advancements.

5. **Influence on Future Conferences**: The success and impact of the 1911 conference set the stage for future Solvay Conferences, which continued to be a major forum for discussing groundbreaking scientific ideas.

These interactions and discussions at the conference played a crucial role in advancing the understanding of quantum mechanics and relativity, influencing the direction of 20th-century physics.<br/>-------------------



```python
cq_c_response = cq_c_engine.chat("what happen after that?")
```

    2025-09-12 20:21:54,563 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:21:54,569 - INFO - Querying with: What significant events or developments occurred following the 1911 First Solvay Conference, particularly in relation to the scientists who attended and the discussions they had on quantum theory and other topics?


    Querying with: What significant events or developments occurred following the 1911 First Solvay Conference, particularly in relation to the scientists who attended and the discussions they had on quantum theory and other topics?


    2025-09-12 20:21:54,916 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:22:00,221 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(cq_c_response.response) 
```


--- Response -------<br/>Following the 1911 First Solvay Conference, significant developments occurred in the realm of quantum theory and other scientific areas. The conference itself was a pivotal moment for the discussion of quantum theory, bringing together key figures like Marie Curie, Albert Einstein, Max Planck, and others who were instrumental in advancing the field. After the conference, these scientists continued to develop their groundbreaking theories and research.

Albert Einstein further developed his theories on relativity, which continued to reshape the understanding of space and time. Max Planck's work on energy quanta laid the foundation for future quantum mechanics developments. The interactions and debates among these scientists, particularly between Einstein and Niels Bohr in later conferences, further propelled the exploration and understanding of quantum mechanics.

Marie Curie continued her pioneering research on radioactivity, contributing significantly to the field and maintaining her status as a leading scientist despite personal challenges. The conference also fostered collaborations and mutual respect among the attendees, which influenced their subsequent scientific endeavors and the broader scientific community.<br/>-------------------



```python
cq_c_response = cq_c_engine.chat("what happen after that?")
```

    2025-09-12 20:22:01,518 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:22:01,522 - INFO - Querying with: What significant developments and events occurred in the field of physics and among the scientists, such as Albert Einstein, Marie Curie, and others, following the 1911 First Solvay Conference?


    Querying with: What significant developments and events occurred in the field of physics and among the scientists, such as Albert Einstein, Marie Curie, and others, following the 1911 First Solvay Conference?


    2025-09-12 20:22:01,989 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:22:07,268 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(cq_c_response.response) 
```


--- Response -------<br/>Following the 1911 First Solvay Conference, several significant developments and events occurred in the field of physics and among the scientists who attended. Albert Einstein continued to develop his theories, leading to the publication of the general theory of relativity in 1915, which fundamentally changed our understanding of gravity. Marie Curie persisted in her pioneering work on radioactivity, furthering research that would have lasting impacts on both science and medicine.

The Solvay Conferences continued to be a crucial meeting ground for physicists, fostering discussions that would shape the future of quantum mechanics and relativity. Scientists like Max Planck, who had already made significant contributions to quantum theory, continued to influence the field, while figures like Niels Bohr engaged in pivotal debates with Einstein about the nature of quantum mechanics.

The scientific community also faced challenges due to the political tensions in Europe, which affected collaborations and the movement of scientists. Despite these challenges, the relationships and exchanges fostered at events like the Solvay Conferences played a vital role in advancing scientific knowledge during this period.<br/>-------------------


### Context Chat Engine


```python
from llama_index.core.memory import ChatMemoryBuffer


memory = ChatMemoryBuffer.from_defaults(token_limit=3900)
ctx_c_engine = index.as_chat_engine(
    chat_mode="context"
    , memory=memory
    , system_prompt = (
        "You are familiar with biographies of Albert and Marie, as well as their professional and social friendships and relationships."
    ))
```


```python
ctx_c_response = ctx_c_engine.chat("who are the scientists in these documents?")
```

    2025-09-12 20:22:07,676 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:22:11,057 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(ctx_c_response.response)
```


--- Response -------<br/>The documents mention several prominent scientists who were part of the early 20th-century scientific community, particularly those who attended the Solvay Conferences. Here are the scientists mentioned:

1. Albert Einstein
2. Marie Curie
3. Paul Langevin
4. Max Planck
5. Henri Poincaré
6. Ernest Rutherford
7. Hendrik Lorentz
8. Niels Bohr
9. Walther Nernst
10. Marcel Brillouin
11. Ernest Solvay
12. Emil Warburg
13. Jean Baptiste Perrin
14. Wilhelm Wien
15. Robert Goldschmidt
16. Heinrich Rubens
17. Arnold Sommerfeld
18. Frederick Lindemann
19. Maurice de Broglie
20. Martin Knudsen
21. Friedrich Hasenöhrl
22. Georges Hostelet
23. Edouard Herzen
24. James Hopwood Jeans
25. Heike Kamerlingh Onnes

These scientists were part of a closely-knit community working on cutting-edge physics and often met at the Solvay Conferences to discuss significant scientific advancements, particularly in the field of quantum mechanics and relativity.<br/>-------------------



```python
ctx_c_response = ctx_c_engine.chat("Have these scientist met in their lifetime?")
```

    2025-09-12 20:22:11,669 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:22:19,349 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(ctx_c_response.response)
```


--- Response -------<br/>Yes, many of these scientists met in their lifetime, particularly at the Solvay Conferences, which were pivotal gatherings for discussing advancements in physics. The Solvay Conferences, starting in 1911, served as a primary meeting ground for these scientists. For example:

- Albert Einstein and Marie Curie attended multiple Solvay Conferences together, including the first one in 1911 and the famous fifth conference in 1927.
- Paul Langevin, Max Planck, Henri Poincaré, Ernest Rutherford, and Hendrik Lorentz were also present at the 1911 Solvay Conference.
- Niels Bohr attended later Solvay Conferences, including the 1927 conference, where he engaged in famous debates with Einstein about quantum mechanics.

These conferences brought together many of the leading scientists of the time, allowing them to collaborate, debate, and advance the field of physics collectively.<br/>-------------------



```python
ctx_c_response = ctx_c_engine.chat("what are the topics they discussed?")
```

    2025-09-12 20:22:19,720 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:22:26,312 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(ctx_c_response.response)
```


--- Response -------<br/>The scientists at the Solvay Conferences discussed several groundbreaking topics in physics, particularly focusing on quantum theory and relativity. Here are some of the key topics they explored:

1. **Quantum Theory:** The early Solvay Conferences, starting with the first one in 1911, were pivotal in discussing the emerging field of quantum mechanics. Scientists debated the nature of atomic and subatomic particles, energy quantization, and the implications of quantum theory on classical physics.

2. **Theory of Relativity:** Albert Einstein's theories of special and general relativity were significant topics of discussion. These theories challenged existing notions of space, time, and gravity, leading to profound implications for physics.

3. **Radioactivity:** Marie Curie's work on radioactivity was a crucial subject, as it opened new realms in understanding atomic structure and nuclear physics.

4. **Atomic Structure:** Discussions on the structure of the atom, including models proposed by scientists like Niels Bohr, were central to these conferences.

5. **Wave-Particle Duality:** The dual nature of light and matter, exhibiting both wave-like and particle-like properties, was a topic of intense debate, particularly between Einstein and Bohr.

6. **Statistical Mechanics and Thermodynamics:** These areas were explored to understand the behavior of systems at the atomic level, contributing to the development of statistical physics.

7. **Philosophical Implications of Physics:** The conferences also delved into the philosophical questions raised by new physical theories, such as determinism, causality, and the nature of reality.

These discussions were instrumental in shaping modern physics, as they brought together the leading minds to collaborate and challenge each other's ideas, leading to significant advancements in the field.<br/>-------------------



```python
ctx_c_response = ctx_c_engine.chat("what are the other topics they discussed?")
```

    2025-09-12 20:22:27,337 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:22:33,928 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(ctx_c_response.response)    
```


--- Response -------<br/>In addition to the major topics previously mentioned, the scientists at the Solvay Conferences and in their personal interactions likely discussed a variety of other scientific and philosophical topics, including:

1. **Electromagnetism:** The integration of electromagnetic theory with quantum mechanics and relativity was a significant area of interest, particularly in understanding light and radiation.

2. **Nuclear Physics:** As the understanding of the atomic nucleus developed, discussions likely included nuclear reactions, isotopes, and the forces within the nucleus.

3. **Chemical Physics:** The intersection of chemistry and physics, particularly in understanding molecular structures and reactions, was an area of exploration, especially relevant to Marie Curie's work on radioactivity.

4. **Experimental Techniques:** Advances in experimental methods and instrumentation for studying atomic and subatomic phenomena were crucial for validating theoretical predictions.

5. **Mathematical Physics:** The development of mathematical tools and frameworks to describe physical phenomena, including tensor calculus and group theory, was essential for advancing theories like relativity and quantum mechanics.

6. **Philosophy of Science:** Broader philosophical discussions about the nature of scientific inquiry, the role of observation and theory, and the limits of scientific knowledge were likely part of their conversations.

7. **Social and Political Issues:** Given the historical context, they may have discussed the impact of political events on scientific collaboration, funding, and the movement of scientists across borders.

These topics reflect the broad and interdisciplinary nature of the discussions among these pioneering scientists, as they sought to understand and explain the fundamental principles governing the natural world.<br/>-------------------



```python
ctx_c_response = ctx_c_engine.chat("What are the most significant things that have happened among them?")
```

    2025-09-12 20:22:34,452 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:22:48,844 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(ctx_c_response.response)    
```


--- Response -------<br/>Several significant events and interactions occurred among these scientists, shaping the course of modern physics and their personal and professional lives. Here are some of the most notable:

1. **Solvay Conferences:** The Solvay Conferences themselves were significant events, bringing together the greatest minds in physics to discuss and debate the latest scientific theories and discoveries. The 1927 conference, in particular, is famous for the debates between Albert Einstein and Niels Bohr on the interpretation of quantum mechanics.

2. **Einstein and Curie's Friendship:** Albert Einstein and Marie Curie developed a close personal and professional friendship. They exchanged letters discussing scientific ideas and personal matters, and Curie supported Einstein against anti-German sentiment in France.

3. **Development of Quantum Mechanics:** The collaboration and debates among these scientists, including figures like Niels Bohr, Werner Heisenberg, and Erwin Schrödinger, were crucial in developing and refining quantum mechanics, a cornerstone of modern physics.

4. **Einstein's Theory of Relativity:** Albert Einstein's development of the theories of special and general relativity revolutionized the understanding of space, time, and gravity, influencing many of his contemporaries and future generations of physicists.

5. **Marie Curie's Work on Radioactivity:** Marie Curie's pioneering research on radioactivity laid the groundwork for nuclear physics and chemistry, earning her two Nobel Prizes and inspiring many scientists in the field.

6. **Einstein's Flight from Nazi Germany:** Einstein's emigration to the United States in 1933, due to the rise of the Nazi regime, was a significant event, impacting his life and career and highlighting the broader challenges faced by scientists during this period.

7. **Philosophical Debates:** The philosophical debates, particularly between Einstein and Bohr, about the nature of reality and the interpretation of quantum mechanics, had a lasting impact on the philosophy of science.

These events and interactions not only advanced scientific knowledge but also demonstrated the importance of collaboration, debate, and friendship in the scientific community.<br/>-------------------



```python
ctx_c_response = ctx_c_engine.chat("what happen after that?")
```

    2025-09-12 20:22:49,292 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:23:01,150 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(ctx_c_response.response)    
```


--- Response -------<br/>After the significant events and interactions among these scientists, several developments unfolded in both their personal lives and the broader scientific community:

1. **Continued Scientific Advancements:** The foundational work laid by these scientists continued to influence and propel advancements in physics. Quantum mechanics and relativity became integral parts of modern physics, leading to new discoveries and technologies.

2. **World War II and the Manhattan Project:** The onset of World War II had a profound impact on the scientific community. Many scientists, including some from the Solvay Conferences, were involved in the development of the atomic bomb through the Manhattan Project. Although Einstein was not directly involved in the project, his letter to President Roosevelt urging atomic research was a catalyst for its initiation.

3. **Post-War Scientific Collaboration:** After the war, there was a renewed emphasis on international scientific collaboration. Organizations like CERN were established to foster cooperative research in Europe, partly as a response to the wartime disruptions.

4. **Einstein's Later Years:** Albert Einstein spent his later years at the Institute for Advanced Study in Princeton, New Jersey, working on a unified field theory, though he was unsuccessful. He remained active in social and political causes, advocating for civil rights and nuclear disarmament until his death in 1955.

5. **Legacy of Marie Curie:** Marie Curie's legacy continued through her contributions to science and her family. Her daughter, Irène Joliot-Curie, followed in her footsteps, winning a Nobel Prize in Chemistry in 1935 for her work on artificial radioactivity.

6. **Development of New Theories:** The groundwork laid by these scientists paved the way for new theories and discoveries in physics, including the development of quantum field theory and the Standard Model of particle physics.

7. **Cultural Impact:** The cultural impact of these scientists, particularly Einstein, continued to grow. Einstein became an enduring symbol of genius and intellectual achievement, influencing both scientific thought and popular culture.

These developments highlight the lasting influence of the early 20th-century scientific community on both the scientific world and society at large.<br/>-------------------



```python
ctx_c_response = ctx_c_engine.chat("what happen after that?")
```

    2025-09-12 20:23:01,738 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:23:09,421 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(ctx_c_response.response)
```


--- Response -------<br/>Following the post-war period and the contributions of these scientists, several key developments and trends emerged in the scientific and global landscape:

1. **Cold War Era Science:** The Cold War period saw significant scientific advancements driven by competition between the United States and the Soviet Union. This included the space race, leading to milestones like the launch of Sputnik and the Apollo moon landings.

2. **Expansion of Physics:** The fields of quantum mechanics and relativity continued to expand, leading to the development of quantum electrodynamics (QED) and later quantum chromodynamics (QCD), which are part of the Standard Model of particle physics.

3. **Technological Innovations:** The foundational work in physics contributed to numerous technological innovations, including the development of semiconductors, transistors, and eventually, computers and the internet.

4. **Nuclear Energy and Weapons:** The development of nuclear energy for both civilian and military purposes continued to evolve, with ongoing debates about its safety, ethical implications, and environmental impact.

5. **Human Rights and Scientific Responsibility:** Influenced by the humanitarian concerns of scientists like Einstein, there was a growing emphasis on the ethical responsibilities of scientists, particularly regarding the use of scientific discoveries for military purposes.

6. **Global Scientific Collaboration:** International collaboration in science became more prominent, with organizations like the United Nations Educational, Scientific and Cultural Organization (UNESCO) promoting scientific cooperation across borders.

7. **Einstein's Enduring Influence:** Albert Einstein's theories continued to be tested and confirmed, with his work remaining a cornerstone of modern physics. His influence extended beyond science, as he became an icon of intellectual curiosity and humanitarian values.

8. **Legacy of the Solvay Conferences:** The tradition of international scientific conferences continued, fostering dialogue and collaboration among scientists worldwide, much like the original Solvay Conferences.

These developments reflect the enduring impact of the early 20th-century scientific community on both the progression of science and its integration into broader societal and global contexts.<br/>-------------------


### Condense Context Chat Engine
Process of condensing conversation context and user messages into a standalone question: A multiturn chat mode that condenses a conversation into a standard alone question. Then enriching that standalone question by additional context retrieved, and generating a response using an LLM.


```python
from tabnanny import verbose
from llama_index.core.memory import ChatMemoryBuffer 

condenseContext_memory = ChatMemoryBuffer.from_defaults(token_limit=3900)

condenseContext_engine = index.as_chat_engine(
    chat_mode= "condense_plus_context"
    ,memory= condenseContext_memory
    ,llm = llm
    , context_prompt =  "You are familiar with biographies of Albert and Marie, as well as their professional and social friendships and relationships."
    , verbose = True
)
```


```python
condenseContext_response =condenseContext_engine.chat("who are the scientists in these documents?")
```

    2025-09-12 20:23:09,464 - INFO - Condensed question: who are the scientists in these documents?


    Condensed question: who are the scientists in these documents?


    2025-09-12 20:23:09,829 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:23:22,937 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(condenseContext_response.response)
```


--- Response -------<br/>To help identify the scientists in the documents, it would be useful to know which documents you are referring to. However, if you are asking about scientists commonly associated with Albert Einstein and Marie Curie, here are a few notable ones:

1. **Albert Einstein**:
   - **Max Planck**: A physicist known for his work on quantum theory, which Einstein built upon.
   - **Niels Bohr**: A physicist who made foundational contributions to understanding atomic structure and quantum theory.
   - **Werner Heisenberg**: Known for the development of quantum mechanics and the uncertainty principle.
   - **Erwin Schrödinger**: A physicist who developed wave mechanics, one of the formulations of quantum mechanics.
   - **Wolfgang Pauli**: Known for the Pauli exclusion principle in quantum physics.
   - **Satyendra Nath Bose**: Collaborated with Einstein on Bose-Einstein statistics.

2. **Marie Curie**:
   - **Henri Becquerel**: Discovered radioactivity, which Curie further investigated.
   - **Pierre Curie**: Marie Curie's husband and collaborator in her research on radioactivity.
   - **Irène Joliot-Curie**: Marie Curie's daughter, who also won a Nobel Prize in Chemistry.
   - **Frédéric Joliot-Curie**: Irène's husband, who collaborated with her on artificial radioactivity.
   - **Albert Einstein**: Although primarily associated with physics, Einstein and Curie had mutual respect and were contemporaries.

If you have specific documents or contexts in mind, please provide more details for a more tailored response.<br/>-------------------



```python
condenseContext_response =condenseContext_engine.chat("Have these scientist met in their lifetime?")
```

    2025-09-12 20:23:24,663 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:23:24,672 - INFO - Condensed question: Did the scientists associated with Albert Einstein and Marie Curie, such as Max Planck, Niels Bohr, Werner Heisenberg, Erwin Schrödinger, Wolfgang Pauli, Satyendra Nath Bose, Henri Becquerel, Pierre Curie, Irène Joliot-Curie, and Frédéric Joliot-Curie, meet each other during their lifetimes?


    Condensed question: Did the scientists associated with Albert Einstein and Marie Curie, such as Max Planck, Niels Bohr, Werner Heisenberg, Erwin Schrödinger, Wolfgang Pauli, Satyendra Nath Bose, Henri Becquerel, Pierre Curie, Irène Joliot-Curie, and Frédéric Joliot-Curie, meet each other during their lifetimes?


    2025-09-12 20:23:25,076 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:23:39,422 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(condenseContext_response.response)
```


--- Response -------<br/>Yes, many of the scientists mentioned did meet during their lifetimes, particularly those who were contemporaries and active in the early to mid-20th century. Here are some notable interactions:

1. **Albert Einstein and Marie Curie**: They met on several occasions and had a mutual respect for each other's work. They both attended the Solvay Conferences, which were gatherings of prominent scientists to discuss issues in physics. Einstein admired Curie's perseverance and scientific contributions.

2. **Albert Einstein and Niels Bohr**: They had a famous series of debates on the fundamentals of quantum mechanics, particularly at the Solvay Conferences. These debates were pivotal in the development of quantum theory.

3. **Marie Curie and Henri Becquerel**: They collaborated closely after Becquerel discovered radioactivity. Curie's research expanded on his initial findings, leading to her own groundbreaking discoveries.

4. **Marie Curie and Pierre Curie**: As husband and wife, they worked closely together on their research into radioactivity, which led to their joint Nobel Prize in Physics in 1903.

5. **Irène Joliot-Curie and Frédéric Joliot-Curie**: They were married and collaborated on research that led to their Nobel Prize in Chemistry in 1935 for their synthesis of new radioactive elements.

6. **Albert Einstein and Max Planck**: They had a professional relationship and mutual respect. Planck was one of the early supporters of Einstein's theory of relativity.

7. **Albert Einstein and Satyendra Nath Bose**: Although they collaborated on Bose-Einstein statistics, it was primarily through correspondence. It is not well-documented whether they met in person.

These interactions were part of a vibrant scientific community in Europe during the early 20th century, where many of these scientists met through conferences, academic institutions, and collaborative research.<br/>-------------------



```python
condenseContext_response =condenseContext_engine.chat("what are the topics they discussed?")
```

    2025-09-12 20:23:40,852 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:23:40,854 - INFO - Condensed question: What topics did the scientists mentioned, such as Albert Einstein, Marie Curie, Niels Bohr, and others, discuss during their meetings and interactions?


    Condensed question: What topics did the scientists mentioned, such as Albert Einstein, Marie Curie, Niels Bohr, and others, discuss during their meetings and interactions?


    2025-09-12 20:23:41,265 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:23:49,963 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(condenseContext_response.response)
```


--- Response -------<br/>The interactions among these scientists often revolved around some of the most groundbreaking and complex topics in physics and chemistry of their time. Here are some of the key topics they discussed:

1. **Albert Einstein and Marie Curie**:
   - **Radioactivity**: Curie's pioneering work in radioactivity was a topic of great interest, and Einstein admired her contributions to the field.
   - **Scientific Collaboration and Recognition**: They both navigated the challenges of scientific recognition and the politics of the Nobel Prize, often discussing the broader implications of their work.

2. **Albert Einstein and Niels Bohr**:
   - **Quantum Mechanics**: Their debates, particularly at the Solvay Conferences, focused on the interpretation of quantum mechanics. Einstein famously challenged the probabilistic nature of quantum mechanics, encapsulated in his quote, "God does not play dice with the universe."
   - **Wave-Particle Duality**: Discussions on the nature of light and matter, which were central to the development of quantum theory.

3. **Marie Curie and Henri Becquerel**:
   - **Radioactivity**: They discussed the nature and properties of radioactivity, which Becquerel discovered and Curie further explored, leading to the identification of new radioactive elements like polonium and radium.

4. **Marie Curie and Pierre Curie**:
   - **Discovery of Radium and Polonium**: Their collaborative work focused on isolating and studying these elements, which were crucial to understanding radioactivity.
   - **Applications of Radioactivity**: They explored the potential uses of radioactive materials in medicine and science.

5. **Irène Joliot-Curie and Frédéric Joliot-Curie**:
   - **Artificial Radioactivity**: They discussed and conducted experiments that led to the discovery of artificial radioactivity, which had significant implications for nuclear physics and chemistry.

6. **Albert Einstein and Max Planck**:
   - **Theory of Relativity**: Planck was an early supporter of Einstein's theory, and they discussed its implications for physics.
   - **Quantum Theory**: While Planck laid the groundwork for quantum theory, Einstein's work on the photoelectric effect furthered its development, leading to discussions on the dual nature of light.

7. **Albert Einstein and Satyendra Nath Bose**:
   - **Bose-Einstein Statistics**: Their collaboration through correspondence led to the development of Bose-Einstein statistics, which describe the behavior of indistinguishable particles and laid the groundwork for the concept of Bose-Einstein condensates.

These discussions were instrumental in advancing scientific understanding and often took place in formal settings like conferences, as well as through personal correspondence and collaborations.<br/>-------------------



```python
condenseContext_response =condenseContext_engine.chat("what are the other topics they discussed?")
```

    2025-09-12 20:23:50,992 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:23:50,995 - INFO - Condensed question: What additional topics did these scientists discuss during their interactions?


    Condensed question: What additional topics did these scientists discuss during their interactions?


    2025-09-12 20:23:51,299 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:23:59,728 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(condenseContext_response.response)
```


--- Response -------<br/>Beyond their scientific work, these scientists also engaged in discussions on a variety of other topics, reflecting their broader interests and the socio-political context of their times:

1. **Philosophy of Science**:
   - **Albert Einstein and Niels Bohr**: Their debates on quantum mechanics often touched on philosophical questions about the nature of reality, determinism, and the role of the observer in scientific measurements.

2. **Education and Scientific Collaboration**:
   - **Marie Curie**: As a pioneering female scientist, Curie was deeply involved in discussions about education, particularly for women, and the importance of international scientific collaboration. She helped establish the Radium Institute in Paris, which became a hub for scientific research.

3. **Ethics and Responsibility**:
   - **Albert Einstein**: He was vocal about the ethical responsibilities of scientists, especially in the context of nuclear weapons development during and after World War II. He famously signed a letter to President Franklin D. Roosevelt urging the development of atomic research, which contributed to the Manhattan Project.

4. **Social and Political Issues**:
   - **Albert Einstein**: He was an advocate for civil rights, pacifism, and Zionism. He often discussed these topics in public forums and private correspondences, emphasizing the role of science in promoting peace and understanding.
   - **Marie Curie**: While less politically active than Einstein, Curie was involved in efforts to support scientific research and education, particularly during and after World War I, when she helped equip ambulances with X-ray machines to aid in medical treatment.

5. **Personal and Professional Challenges**:
   - **Marie Curie**: She faced significant challenges as a woman in science, including issues of recognition and funding. Her correspondence and interactions often reflected her efforts to overcome these barriers.
   - **Albert Einstein**: He discussed the challenges of working in a politically turbulent Europe, particularly as a Jewish scientist during the rise of Nazism, which eventually led to his emigration to the United States.

These discussions reveal that these scientists were not only focused on advancing their respective fields but were also deeply engaged with the broader implications of their work and the societal issues of their time.<br/>-------------------



```python
condenseContext_response =condenseContext_engine.chat("What are the most significant things that have happened among them?")
```

    2025-09-12 20:24:00,618 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:24:00,621 - INFO - Condensed question: What are the most significant events or interactions that occurred among these scientists?


    Condensed question: What are the most significant events or interactions that occurred among these scientists?


    2025-09-12 20:24:01,027 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:24:09,664 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(condenseContext_response.response)
```


--- Response -------<br/>The interactions and collaborations among these scientists led to several significant developments in science and had a profound impact on the scientific community and beyond. Here are some of the most notable events and achievements:

1. **Albert Einstein and Marie Curie**:
   - **Solvay Conferences**: Both attended these influential meetings, which were critical for the development of modern physics. These conferences facilitated discussions on quantum mechanics and relativity, bringing together the brightest minds of the time.

2. **Albert Einstein and Niels Bohr**:
   - **Einstein-Bohr Debates**: Their debates on the interpretation of quantum mechanics were pivotal in shaping the philosophical foundations of quantum theory. These discussions highlighted the tension between Einstein's preference for deterministic theories and Bohr's acceptance of probabilistic interpretations.

3. **Marie Curie and Henri Becquerel**:
   - **Discovery of Radioactivity**: Becquerel's discovery of radioactivity, followed by Curie's extensive research, led to the identification of polonium and radium. This work laid the foundation for the field of nuclear physics and had significant implications for medicine and industry.

4. **Marie Curie and Pierre Curie**:
   - **Nobel Prize in Physics (1903)**: Marie and Pierre Curie, along with Henri Becquerel, were awarded the Nobel Prize for their joint research on radioactivity. This recognition was a landmark achievement for Marie Curie, making her the first woman to win a Nobel Prize.

5. **Irène Joliot-Curie and Frédéric Joliot-Curie**:
   - **Nobel Prize in Chemistry (1935)**: Their discovery of artificial radioactivity was a significant advancement in nuclear chemistry, leading to further research in nuclear reactions and the development of nuclear energy.

6. **Albert Einstein and Max Planck**:
   - **Support for Relativity**: Planck's support of Einstein's theory of relativity helped gain acceptance for the theory within the scientific community. This collaboration was crucial in establishing relativity as a cornerstone of modern physics.

7. **Albert Einstein and Satyendra Nath Bose**:
   - **Bose-Einstein Statistics**: Their collaboration led to the development of Bose-Einstein statistics, which describe the behavior of particles known as bosons. This work was foundational for later developments in quantum mechanics and the study of Bose-Einstein condensates.

These significant events and achievements not only advanced scientific knowledge but also influenced the direction of research and the development of new technologies in the 20th century. The collaborations and debates among these scientists were instrumental in shaping modern physics and chemistry.<br/>-------------------



```python
condenseContext_response =condenseContext_engine.chat("what happen after that?")
```

    2025-09-12 20:24:10,828 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:24:10,833 - INFO - Condensed question: What significant developments or events occurred following these achievements and interactions among the scientists?


    Condensed question: What significant developments or events occurred following these achievements and interactions among the scientists?


    2025-09-12 20:24:11,368 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:24:23,240 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(condenseContext_response.response)
```


--- Response -------<br/>After these significant achievements and interactions, the legacy of these scientists continued to influence the fields of physics and chemistry, as well as broader societal and scientific developments. Here's what happened in the subsequent years:

1. **Albert Einstein**:
   - **Later Years and Legacy**: Einstein continued to work on theoretical physics, focusing on a unified field theory, although he did not achieve a breakthrough comparable to his earlier work. He became an iconic public figure, advocating for peace, civil rights, and scientific collaboration. Einstein's theories, particularly relativity, have continued to be foundational in physics, influencing areas such as cosmology and quantum mechanics.
   - **Impact on Technology**: His work laid the groundwork for technologies like GPS, which relies on the principles of general relativity.

2. **Marie Curie**:
   - **Continued Research and Influence**: Curie continued her research on radioactivity until her death in 1934. Her work paved the way for advancements in medical treatments, such as cancer radiotherapy. She also established research institutes in Paris and Warsaw, which became centers for scientific research.
   - **Legacy and Recognition**: Curie's legacy as a pioneering woman in science has inspired generations of female scientists. She remains the only person to have won Nobel Prizes in two different scientific fields (Physics and Chemistry).

3. **Niels Bohr**:
   - **Contributions to Quantum Mechanics**: Bohr continued to develop quantum theory and played a crucial role in the establishment of the Copenhagen interpretation. He also contributed to the development of nuclear energy and was involved in discussions about the ethical implications of atomic weapons.
   - **Post-War Efforts**: After World War II, Bohr advocated for peaceful uses of nuclear energy and international cooperation in science.

4. **Irène Joliot-Curie and Frédéric Joliot-Curie**:
   - **Scientific and Political Involvement**: Both continued their research in nuclear physics and were involved in the French atomic energy program. They also engaged in political activities, advocating for scientific research and education.
   - **Legacy**: Their work on artificial radioactivity had lasting impacts on nuclear science and technology.

5. **Max Planck**:
   - **Later Life and Influence**: Planck continued to be an influential figure in the scientific community, serving as president of the Kaiser Wilhelm Society (later the Max Planck Society). His contributions to quantum theory remain fundamental to modern physics.

6. **Satyendra Nath Bose**:
   - **Recognition and Influence**: Bose's work on quantum statistics gained recognition over time, and he became a prominent figure in Indian science. The concept of bosons, named in his honor, is central to particle physics.

The collective contributions of these scientists have had a profound and lasting impact on science and technology, shaping the modern world in countless ways. Their work continues to inspire new generations of scientists and researchers.<br/>-------------------



```python
condenseContext_response =condenseContext_engine.chat("what happen after that?")
```

    2025-09-12 20:24:24,372 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 20:24:24,374 - INFO - Condensed question: What developments and impacts followed the significant achievements and interactions of these scientists?


    Condensed question: What developments and impacts followed the significant achievements and interactions of these scientists?


    2025-09-12 20:24:24,885 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 20:24:48,210 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(condenseContext_response.response)
```


--- Response -------<br/>Following the significant contributions and interactions of these scientists, their work continued to influence scientific progress and societal developments in various ways:

1. **Advancements in Physics and Chemistry**:
   - **Quantum Mechanics and Relativity**: The foundational work of Einstein, Bohr, Planck, and others laid the groundwork for further advancements in quantum mechanics and relativity. These theories have been integral to developments in particle physics, cosmology, and quantum computing.
   - **Nuclear Science**: The research initiated by Marie Curie and continued by Irène Joliot-Curie and Frédéric Joliot-Curie contributed to the development of nuclear energy and medical applications, such as cancer treatments using radiation therapy.

2. **Technological Innovations**:
   - **Applications of Relativity**: Einstein's theories have been crucial for technologies like GPS, which requires precise time measurements adjusted for relativistic effects.
   - **Quantum Technologies**: The principles of quantum mechanics have led to the development of technologies such as semiconductors, lasers, and quantum computers.

3. **Scientific Institutions and Collaboration**:
   - **Research Institutes**: Institutions like the Radium Institute in Paris and the Max Planck Society in Germany have continued to be leading centers for scientific research and innovation.
   - **International Collaboration**: The legacy of these scientists has fostered a spirit of international collaboration in science, exemplified by organizations like CERN and the International Atomic Energy Agency (IAEA).

4. **Social and Ethical Implications**:
   - **Nuclear Weapons and Peace Efforts**: The development of nuclear weapons during World War II, which was indirectly influenced by the work on radioactivity and nuclear physics, led to significant ethical debates. Scientists like Einstein and Bohr were involved in discussions about the peaceful use of nuclear energy and the prevention of nuclear proliferation.
   - **Science and Society**: The contributions of these scientists have highlighted the importance of science in addressing global challenges, from energy and health to environmental sustainability.

5. **Inspiration and Education**:
   - **Role Models**: Marie Curie, in particular, has become an enduring symbol of women's contributions to science, inspiring countless women to pursue careers in STEM fields.
   - **Educational Impact**: The discoveries and theories developed by these scientists are integral parts of science education worldwide, forming the basis of curricula in physics and chemistry.

Overall, the work and legacy of these scientists have had a lasting impact on both the scientific community and society at large, continuing to influence research, technology, and policy decisions well into the 21st century.<br/>-------------------


You can configure retriever which is the primary function of a "retriever in RAG systems" is to find and prioritize chunks or nodes that are most relevant to the input query. The default retriever that’s used by VectorStoreIndex is VectorIndexRetriever.


```python
from llama_index.core.retrievers import VectorIndexRetriever


retriever = VectorIndexRetriever(index=index, similarity_top_k=3)
```

## Configure response synthesizer
Synthesizes responses by generating them using a user query, large language model (LLM), and a set of retrieved chunks/nodes.

**Response Synthesizer**:This synthesizes the retrieved information and the LLM's understanding into a coherent final answer[^3].


```python
from llama_index.core import get_response_synthesizer

synthesizer = get_response_synthesizer(response_mode="refine")
```

The Retriever retrieves and ranks relevant chunks or nodes in response to a query. Here the synthesizer directly load all nodes into the response synthesis module without additional processing to generate the final answer.

Now you can create retriever query engine:


```python
from llama_index.core.query_engine import RetrieverQueryEngine


retriever_query_engine = RetrieverQueryEngine(
    retriever = retriever, response_synthesizer=synthesizer
)
```


```python
retriever_response = retriever_query_engine.query("Who met at the 1911 First Solvay Conference?")
```

    2025-09-12 21:31:31,350 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    2025-09-12 21:31:33,319 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 21:31:34,622 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"
    2025-09-12 21:31:35,441 - INFO - HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
in_md(retriever_response.response)
```


--- Response -------<br/>At the 1911 First Solvay Conference, Marie Curie and Albert Einstein were among the notable attendees.<br/>-------------------


Instead it is possible to make index as a retriever:


```python
retrieved_index =  index.as_retriever(similarity_top_k=3)
```


```python
retrieved_nodes = retrieved_index.retrieve("Who met at the 1911 First Solvay Conference?")
```

    2025-09-12 21:37:21,695 - INFO - HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"



```python
from llama_index.core.response.notebook_utils import display_source_node


for text_node in retrieved_nodes:
    print(text_node)
```

    Node ID: 245c9289-4899-4e04-8909-c6d7b3c9cc25
    Text: Based on my research, Einstein and Marie Curie shared many
    mutual acquaintances through scientific conferences, particularly the
    famous Solvay Conferences, and the broader European scientific
    community of the early 20th century. Here are the key people both
    scientists knew and how they were connected: Major Mutual
    Acquaintances Paul Langevin (18...
    Score:  0.841
    
    Node ID: 2e1fb072-65d1-4889-b906-5d499f866244
    Text: # When Marie Curie Met Albert Einstein  ## Brussels, October
    1911  The first Solvay Conference buzzed with intellectual energy as
    the greatest minds in physics gathered to discuss the revolutionary
    concept of quantum theory. Among the distinguished attendees, two
    figures commanded particular attention: the legendary Marie Curie,
    recently awarded...
    Score:  0.832
    
    Node ID: eb0fd574-b6ec-402f-b7c0-47d87b103fe3
    Text: 29 Legendary Scientists Came Together in the "Most Intelligent
    Photo" Ever Taken 1927 Fifth Solvay Conference (the famous "most
    intelligent photo"): Both Einstein and Curie attended this conference,
    which included many Nobel Prize winners and featured the famous
    debates about quantum mechanics "The Most Intelligent Photo Ever
    Taken": The 1927 So...
    Score:  0.829
    


Above there are 3 nodes because we specified that `similarity_top_k=3`.

## Evaluation

Necessary to measuring whether a found document is either relevant or irrelevant: the most commonly used valuation metrics are **precision** \eqref{eq:precision} and **recall** \eqref{eq:recall} where Precision is the fraction of retrieved documents that are relevant, while recall is the fraction of relevant documents that are successfully retrieved.

\\(R\\) - represents all the relevant documents

\\(NR\\) - represent all the irrelevant ones in a corpus of documents $$D$$

\\(Rq\\) - represent relevant documents found

\\(Dq\\) - represent documents returned by the system

$$
\begin{equation}
\text{precision}=\dfrac{Rq}{Dq} \label{eq:precision}
\end{equation}
$$

$$
\begin{equation}
\text{recall}=\dfrac{R_{q}}{R} \label{eq:recall}
\end{equation}
$$

However, these two metrics don't represent ranking. Therefore, retriever uses the ***top-k*** of documents for the context to rank to assume. 

> Whenever we find a relevant document in the rank, **recall** increases. **Precision**, on the other hand, increases with documents but decreases with each irrelevant document.
{:.info-box}

**Hit Rate** in LlamaIndex is a fundamental retrieval evaluation metric that measures how often the correct or relevant document appears within the ***top-k*** retrieved results for a given query. The calculation is straightforward: for each query, you assign a score of 1 if the ground truth (correct) node appears anywhere in the top-k retrieved results, and 0 if it doesn't. The overall hit rate is then the average across all queries. For example, if you have 10 queries and 8 of them have their correct answer node present in the top-k retrieved results, your hit rate would be 8/10 = 0.8.

You must have a method to evaluate whether changes in the system prompt improve user-query hit rates. Is the improvement 1%, 2%, or more[^5]?

**Mean average precision** (***MAP***) \eqref{eq:map} calculate precision values at the points where a relevant item is retrieved called average precision (AP) and then average these APs. For example

The avarage precision (AP) value for the single query is

$$
\begin{equation}
MAP = \dfrac{\sum_{\text{} }^{} \text{precision at each relevant item}}{\text{Total number of relevant items}} \label{eq:map}
\end{equation}
$$

> Hit rate will not be always a right metric to look for in the retrieval evaluation. It doesn't take into account whether the correct node is in the first few position let's say the first position or the second position or say towards the nth position of the retrieved nodes. This is why it's often used alongside Mean Reciprocal Rank (MRR), which considers the position of the correct result.

The **Mean Reciprocal Rrank** (***MRR***) \eqref{eq:mrr}  which access the quality of shrot-ranked list having the correct answer (usually of human labels). The reciprocal rank is the reciprocal of the rank of the first item relevant to the question. For a set of queries $Q$, we take the reciprocal ranks and conduct the average:

$$
\begin{equation}
MRR = \frac{1}{Q} \sum_{i = 1}^{Q} \frac{1}{rank_{i}} \label{eq:mrr}
\end{equation}
$$

### Response Evaluation

Response evaluation in LlamaIndex assesses the quality of the final generated outputs from your RAG system. Key evaluation dimensions include:

- *Faithfulness*: Measures whether the generated answer is grounded in the retrieved context and doesn't contain hallucinations.
- *Relevance*: Evaluates how well the response addresses the original query.
- *Coherence*: Assesses the logical flow and readability of the generated text.
- *Completeness*: Determines if the response fully answers the question asked.

> LlamaIndex has the capability to autonomously generate questions from your data, paving the way for an evaluation pipeline to assess the RAG application.




```python
import nest_asyncio
nest_asyncio.apply()

import logging
import sys

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# clear any existing handlers
logger.handlers = []

# Setup the stream handler
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.INFO)

logger.addHandler(handler)
```


```python
import pandas as pd

logging.basicConfig(stream=sys.stdout, level=logging.INFO)
logging.getLogger().addFilter(logging.StreamHandler(stream=sys.stdout))

from llama_index.core.evaluation import (DatasetGenerator
    , FaithfulnessEvaluator
    , RelevancyEvaluator
    , CorrectnessEvaluator
    , RetrieverEvaluator
    , generate_qa_embedding_pairs
)

from llama_index.core import (SimpleDirectoryReader
    , VectorStoreIndex
    , Response
)


```


```python
dataset_generator = DatasetGenerator.from_documents(documents
    , llm=llm
    , show_progress=False
)

eval_dataset = dataset_generator.generate_dataset_from_nodes(num=20)
```

Here the generated 20 questions:


```python
for i, q  in enumerate(list(eval_dataset.queries.values())):
    print(f"Q.{i+1}: {q}")
```

    Q.1: What pivotal childhood experience did Albert Einstein have that contributed to his scientific curiosity?
    Q.2: Describe the circumstances under which Einstein left school in Munich and how he eventually gained admission to the Swiss Federal Polytechnic.
    Q.3: What role did Einstein's position at the Swiss Patent Office play in his scientific career?
    Q.4: List and briefly explain the four groundbreaking papers Einstein published during his "Annus Mirabilis" in 1905.
    Q.5: How did Einstein's work on the photoelectric effect contribute to quantum theory, and what recognition did he receive for it?
    Q.6: Explain the significance of Einstein's theory of special relativity and its impact on the concepts of space and time.
    Q.7: What is the famous equation derived from Einstein's work on special relativity, and what does it signify?
    Q.8: Outline Einstein's academic career progression from 1908 to 1914, including the institutions he was affiliated with.
    Q.9: How did Sir Arthur Eddington's 1919 solar eclipse expedition contribute to Einstein's international fame?
    Q.10: Describe Einstein's contributions to quantum mechanics and his stance on its probabilistic interpretation.
    Q.11: What significant scientific theory did Albert Einstein complete in 1915, and how did it redefine the concept of gravity?
    Q.12: How did the 1919 solar eclipse expedition led by Sir Arthur Eddington contribute to Einstein's international fame?
    Q.13: Describe Einstein's contributions to quantum mechanics and his philosophical stance on its probabilistic interpretation.
    Q.14: Outline Einstein's personal life, including his marriages and family, highlighting any significant events.
    Q.15: What were the circumstances that led Einstein to flee Nazi Germany in 1933, and where did he eventually settle?
    Q.16: Discuss Einstein's involvement in the development of atomic weapons during World War II and his reasons for supporting this research.
    Q.17: What was Einstein's focus during his later years, and how was his pursuit of a unified field theory perceived by his contemporaries?
    Q.18: How did Einstein contribute to political and social causes, and what notable position did he decline in 1952?
    Q.19: Summarize the scientific legacy of Albert Einstein, including his contributions to relativity, quantum mechanics, and cosmology.
    Q.20: How has Einstein's cultural impact extended beyond his scientific achievements, and what are some of his famous quotes that reflect his philosophy?


Create a evaluation qurey to evaluate which is consistent with the above.


```python
eval_query = "What is Einstein's miracle year?"
```

Using GTP-3.5-Turbo for generate response and GPT-4 for evaluation:


```python
gpt35_llm = OpenAI(model="gpt-3.5-turbo", temperature=0)
gpt4_llm = OpenAI(model="gpt-4", temperature=0)
```

Create vector index and query engine from that for evaluation:


```python
vector_index = VectorStoreIndex.from_documents( documents, llm=gpt35_llm)
query_eval_engine = vector_index.as_query_engine()

```

    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"


Now create a retriever:


```python
query_eval_retriever = vector_index.as_retriever(similarity_top_k=3)
eval_nodes = query_eval_retriever.retrieve(eval_query)
```

    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"



```python
import pprint
pprint.pprint(eval_nodes[1].get_text())
```

    ('# Albert Einstein: A Biography\n'
     '\n'
     '## Early Life (1879-1896)\n'
     '\n'
     'Albert Einstein was born on March 14, 1879, in Ulm, in the Kingdom of '
     'Württemberg in the German Empire. His parents were Hermann Einstein, a '
     'salesman and engineer, and Pauline Koch Einstein. When Albert was one year '
     'old, the family moved to Munich, where his father and uncle founded '
     'Elektrotechnische Fabrik J. Einstein & Cie, a company that manufactured '
     'electrical equipment.\n'
     '\n'
     'Einstein showed early signs of intellectual curiosity, though contrary to '
     'popular myth, he was not a poor student. He excelled in mathematics and '
     'physics from a young age. When he was five, his father gave him a compass, '
     'and Einstein was fascinated by the invisible forces that moved the needle—an '
     'experience he later described as pivotal in developing his scientific '
     'curiosity.\n'
     '\n'
     "In 1894, Einstein's family moved to Italy for business reasons, but Albert "
     'remained in Munich to finish his education. However, he left school early '
     'and rejoined his family in Italy. He then applied to the Swiss Federal '
     'Polytechnic in Zurich but failed the entrance exam, though he scored '
     'exceptionally well in mathematics and physics. After completing his '
     'secondary education in Switzerland, he was accepted to the Polytechnic in '
     '1896.\n'
     '\n'
     '## Education and Early Career (1896-1905)\n'
     '\n'
     'Einstein studied at the Swiss Federal Polytechnic from 1896 to 1900, where '
     'he met Mileva Marić, a fellow physics student who would later become his '
     'first wife. After graduating in 1900, Einstein struggled to find academic '
     'employment and worked various temporary jobs, including as a tutor and '
     'substitute teacher.\n'
     '\n'
     'In 1902, he secured a position at the Swiss Patent Office in Bern, where he '
     'worked as a technical assistant examiner. This job provided him with '
     'financial stability and, perhaps more importantly, time to pursue his own '
     'scientific research. The work at the patent office also exposed him to '
     'practical applications of electromagnetic theory, which influenced his later '
     'work.\n'
     '\n'
     'Einstein earned his doctorate from the University of Zurich in 1905 with a '
     'dissertation titled "On a New Determination of Molecular Dimensions."\n'
     '\n'
     '## The Miracle Year (1905)\n'
     '\n'
     '1905 became known as Einstein\'s "Annus Mirabilis" (miracle year) because he '
     'published four groundbreaking papers that revolutionized physics:\n'
     '\n'
     '### 1. Photoelectric Effect\n'
     "Einstein's paper on the photoelectric effect explained how light could "
     'behave as particles (photons), providing crucial evidence for quantum '
     'theory. This work earned him the Nobel Prize in Physics in 1921.\n'
     '\n'
     '### 2. Brownian Motion\n'
     'His explanation of Brownian motion provided empirical evidence for the '
     'existence of atoms and molecules, convincing skeptics of atomic theory.\n'
     '\n'
     '### 3. Special Theory of Relativity\n'
     'Perhaps his most famous contribution, special relativity introduced the '
     'concept that space and time are interwoven into spacetime, and that the '
     'speed of light is constant for all observers. This theory challenged '
     "Newton's absolute concepts of space and time.\n"
     '\n'
     '### 4. Mass-Energy Equivalence\n'
     'The famous equation E=mc² emerged from his work on special relativity, '
     'showing that mass and energy are interchangeable.\n'
     '\n'
     '## Academic Career and General Relativity (1905-1915)\n'
     '\n'
     'Following his 1905 publications, Einstein gained recognition in the '
     'scientific community. He moved through various academic positions:\n'
     '\n'
     '- 1908: Lecturer at the University of Bern\n'
     '- 1909: Professor at the University of Zurich\n'
     '- 1911: Professor at Charles University in Prague\n'
     '- 1912: Professor at ETH Zurich\n'
     '- 1914: Director of the Kaiser Wilhelm Institute for Physics in Berlin\n'
     '\n'
     'During this period, Einstein worked on extending his special theory of '
     'relativity to include gravity. In 1915, he completed his General Theory of '
     'Relativity, which described gravity not as a force, but as a curvature of '
     'spacetime caused by mass and energy. This theory made several predictions '
     'that were later confirmed experimentally, including the bending of light '
     'around massive objects.\n'
     '\n'
     '## International Fame (1915-1933)\n'
     '\n'
     "Einstein's general relativity gained worldwide attention when Sir Arthur "
     "Eddington's 1919 solar eclipse expedition confirmed the theory's prediction "
     'that light would bend around the sun. Overnight, Einstein became an '
     'international celebrity and the face of modern science.\n'
     '\n'
     'During this period, Einstein made significant contributions to quantum '
     'mechanics, statistical mechanics, and cosmology, though he remained '
     "skeptical of quantum mechanics' probabilistic interpretation, famously "
     'stating "God does not play dice with the universe."\n'
     '\n'
     '## Personal Life\n'
     '\n'
     'Einstein married Mileva Marić in 1903, and they had two sons: Hans Albert '
     'and Eduard.')


### Faithfullness Evaluator
Measures for the hallucination if the response from a query engine matches any source nodes.


```python
faithfulness_evaluator = FaithfulnessEvaluator(llm=gpt4_llm)
```


```python
eval_response_vector = query_eval_engine.query(eval_query)
```

    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
eval_response_result = faithfulness_evaluator.evaluate_response(
    response=eval_response_vector
)
```

    HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"


If not hallucinated, `passing` should be `True` as the following:


```python
eval_response_result.passing
```




    True




```python
pprint.pprint(eval_response_result.contexts)
```

    ['In 1915, he completed his General Theory of Relativity, which described '
     'gravity not as a force, but as a curvature of spacetime caused by mass and '
     'energy. This theory made several predictions that were later confirmed '
     'experimentally, including the bending of light around massive objects.\n'
     '\n'
     '## International Fame (1915-1933)\n'
     '\n'
     "Einstein's general relativity gained worldwide attention when Sir Arthur "
     "Eddington's 1919 solar eclipse expedition confirmed the theory's prediction "
     'that light would bend around the sun. Overnight, Einstein became an '
     'international celebrity and the face of modern science.\n'
     '\n'
     'During this period, Einstein made significant contributions to quantum '
     'mechanics, statistical mechanics, and cosmology, though he remained '
     "skeptical of quantum mechanics' probabilistic interpretation, famously "
     'stating "God does not play dice with the universe."\n'
     '\n'
     '## Personal Life\n'
     '\n'
     'Einstein married Mileva Marić in 1903, and they had two sons: Hans Albert '
     'and Eduard. The couple also had a daughter, Lieserl, born before their '
     'marriage, whose fate remains unknown. Einstein and Mileva divorced in 1919.\n'
     '\n'
     'Later in 1919, Einstein married his cousin Elsa Löwenthal, who had been '
     'caring for him during his illness. Elsa died in 1936.\n'
     '\n'
     'Einstein was known for his distinctive appearance—wild hair, casual dress, '
     'and pipe smoking—and his quirky personality. He was a pacifist, civil rights '
     'advocate, and spoke out against racism and nationalism.\n'
     '\n'
     '## Flight from Nazi Germany (1933-1939)\n'
     '\n'
     'As the Nazi party rose to power in Germany, Einstein, being Jewish, faced '
     'increasing persecution. His books were burned, and he was forced to flee '
     'Germany in 1933. He accepted a position at the Institute for Advanced Study '
     'in Princeton, New Jersey, where he would spend the rest of his life.\n'
     '\n'
     'Einstein became an American citizen in 1940 while retaining his Swiss '
     'citizenship. During World War II, despite his pacifist beliefs, he wrote a '
     'letter to President Roosevelt urging the development of atomic weapons '
     'research, fearing Nazi Germany might develop them first. This led to the '
     'Manhattan Project, though Einstein himself was not involved in the actual '
     'development of the atomic bomb.\n'
     '\n'
     '## Later Years and Unified Field Theory (1939-1955)\n'
     '\n'
     'Einstein spent his later years searching for a "theory of everything" that '
     'would unify the fundamental forces of nature. His pursuit of a unified field '
     'theory was unsuccessful, and many colleagues thought he was pursuing an '
     'impossible dream.\n'
     '\n'
     'He continued his work at Princeton and remained active in political and '
     'social causes, advocating for civil rights, nuclear disarmament, and world '
     'government. He declined an offer to become the second President of Israel in '
     '1952.\n'
     '\n'
     '## Death and Legacy\n'
     '\n'
     'Einstein died on April 18, 1955, at age 76, from an abdominal aortic '
     "aneurysm. His last words were spoken in German to a night nurse who didn't "
     'understand the language, so they are lost to history.\n'
     '\n'
     '## Scientific Legacy\n'
     '\n'
     "Einstein's contributions to science are immeasurable:\n"
     '\n'
     '- **Relativity**: Both special and general relativity remain cornerstones of '
     'modern physics and have practical applications in GPS systems, particle '
     'accelerators, and astronomy.\n'
     '\n'
     '- **Quantum Mechanics**: Despite his philosophical objections to quantum '
     'mechanics, his early work laid important foundations for the field.\n'
     '\n'
     '- **Cosmology**: His field equations became the basis for modern '
     "cosmological models of the universe's expansion and evolution.\n"
     '\n'
     '- **Scientific Method**: Einstein emphasized the importance of thought '
     'experiments and conceptual clarity in physics.\n'
     '\n'
     '## Cultural Impact\n'
     '\n'
     'Beyond science, Einstein became a cultural icon representing genius and '
     'intellectual achievement. His image and quotes are widely recognized, and he '
     'remains a symbol of creativity, curiosity, and the power of human '
     'imagination.\n'
     '\n'
     "Einstein's work fundamentally changed our understanding of reality, space, "
     'time, and the universe itself. His theories continue to be tested and '
     'confirmed, and his influence on physics and human thought remains profound '
     'more than a century after his greatest discoveries.\n'
     '\n'
     '## Famous Quotes\n'
     '\n'
     '"Imagination is more important than knowledge."\n'
     '\n'
     '"The important thing is not to stop questioning."\n'
     '\n'
     '"Try not to become a person of success, but rather try to become a person of '
     'value."\n'
     '\n'
     '"Logic will get you from A to B. Imagination will take you everywhere."\n'
     '\n'
     "Einstein's life story is one of intellectual courage, scientific revolution, "
     'and humanitarian concern—a testament to the power of human curiosity and the '
     'pursuit of truth.',
     '# Albert Einstein: A Biography\n'
     '\n'
     '## Early Life (1879-1896)\n'
     '\n'
     'Albert Einstein was born on March 14, 1879, in Ulm, in the Kingdom of '
     'Württemberg in the German Empire. His parents were Hermann Einstein, a '
     'salesman and engineer, and Pauline Koch Einstein. When Albert was one year '
     'old, the family moved to Munich, where his father and uncle founded '
     'Elektrotechnische Fabrik J. Einstein & Cie, a company that manufactured '
     'electrical equipment.\n'
     '\n'
     'Einstein showed early signs of intellectual curiosity, though contrary to '
     'popular myth, he was not a poor student. He excelled in mathematics and '
     'physics from a young age. When he was five, his father gave him a compass, '
     'and Einstein was fascinated by the invisible forces that moved the needle—an '
     'experience he later described as pivotal in developing his scientific '
     'curiosity.\n'
     '\n'
     "In 1894, Einstein's family moved to Italy for business reasons, but Albert "
     'remained in Munich to finish his education. However, he left school early '
     'and rejoined his family in Italy. He then applied to the Swiss Federal '
     'Polytechnic in Zurich but failed the entrance exam, though he scored '
     'exceptionally well in mathematics and physics. After completing his '
     'secondary education in Switzerland, he was accepted to the Polytechnic in '
     '1896.\n'
     '\n'
     '## Education and Early Career (1896-1905)\n'
     '\n'
     'Einstein studied at the Swiss Federal Polytechnic from 1896 to 1900, where '
     'he met Mileva Marić, a fellow physics student who would later become his '
     'first wife. After graduating in 1900, Einstein struggled to find academic '
     'employment and worked various temporary jobs, including as a tutor and '
     'substitute teacher.\n'
     '\n'
     'In 1902, he secured a position at the Swiss Patent Office in Bern, where he '
     'worked as a technical assistant examiner. This job provided him with '
     'financial stability and, perhaps more importantly, time to pursue his own '
     'scientific research. The work at the patent office also exposed him to '
     'practical applications of electromagnetic theory, which influenced his later '
     'work.\n'
     '\n'
     'Einstein earned his doctorate from the University of Zurich in 1905 with a '
     'dissertation titled "On a New Determination of Molecular Dimensions."\n'
     '\n'
     '## The Miracle Year (1905)\n'
     '\n'
     '1905 became known as Einstein\'s "Annus Mirabilis" (miracle year) because he '
     'published four groundbreaking papers that revolutionized physics:\n'
     '\n'
     '### 1. Photoelectric Effect\n'
     "Einstein's paper on the photoelectric effect explained how light could "
     'behave as particles (photons), providing crucial evidence for quantum '
     'theory. This work earned him the Nobel Prize in Physics in 1921.\n'
     '\n'
     '### 2. Brownian Motion\n'
     'His explanation of Brownian motion provided empirical evidence for the '
     'existence of atoms and molecules, convincing skeptics of atomic theory.\n'
     '\n'
     '### 3. Special Theory of Relativity\n'
     'Perhaps his most famous contribution, special relativity introduced the '
     'concept that space and time are interwoven into spacetime, and that the '
     'speed of light is constant for all observers. This theory challenged '
     "Newton's absolute concepts of space and time.\n"
     '\n'
     '### 4. Mass-Energy Equivalence\n'
     'The famous equation E=mc² emerged from his work on special relativity, '
     'showing that mass and energy are interchangeable.\n'
     '\n'
     '## Academic Career and General Relativity (1905-1915)\n'
     '\n'
     'Following his 1905 publications, Einstein gained recognition in the '
     'scientific community. He moved through various academic positions:\n'
     '\n'
     '- 1908: Lecturer at the University of Bern\n'
     '- 1909: Professor at the University of Zurich\n'
     '- 1911: Professor at Charles University in Prague\n'
     '- 1912: Professor at ETH Zurich\n'
     '- 1914: Director of the Kaiser Wilhelm Institute for Physics in Berlin\n'
     '\n'
     'During this period, Einstein worked on extending his special theory of '
     'relativity to include gravity. In 1915, he completed his General Theory of '
     'Relativity, which described gravity not as a force, but as a curvature of '
     'spacetime caused by mass and energy. This theory made several predictions '
     'that were later confirmed experimentally, including the bending of light '
     'around massive objects.\n'
     '\n'
     '## International Fame (1915-1933)\n'
     '\n'
     "Einstein's general relativity gained worldwide attention when Sir Arthur "
     "Eddington's 1919 solar eclipse expedition confirmed the theory's prediction "
     'that light would bend around the sun. Overnight, Einstein became an '
     'international celebrity and the face of modern science.\n'
     '\n'
     'During this period, Einstein made significant contributions to quantum '
     'mechanics, statistical mechanics, and cosmology, though he remained '
     "skeptical of quantum mechanics' probabilistic interpretation, famously "
     'stating "God does not play dice with the universe."\n'
     '\n'
     '## Personal Life\n'
     '\n'
     'Einstein married Mileva Marić in 1903, and they had two sons: Hans Albert '
     'and Eduard.']


### Relevency Evaluation
Mesures if the response and source nodes match the query.

Create relevancy evaluator:


```python
relevancy_evaluator = RelevancyEvaluator(llm=gpt4_llm)
```

Generate the response:


```python
from llama_index.core.indices import query


eval_response_result = relevancy_evaluator.evaluate_response(
    query=eval_query, response=eval_response_vector
)
```

    Retrying request to /chat/completions in 0.477346 seconds
    HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"



```python
eval_response_result.query
```




    "What is Einstein's miracle year?"




```python
eval_response_result.response
```




    "Einstein's miracle year is 1905."




```python
eval_response_result.passing
```




    True



### Retrieval Evaluation
Evaluates the quality of Retriever module defined in LlamaIndex.

Will resue `query_eval_retriever`:


```python
retrieval_eval_nodes = query_eval_retriever.retrieve(eval_query)
```

    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"



```python
for node in retrieval_eval_nodes:
    pprint.pprint(node)
```

    NodeWithScore(node=TextNode(id_='61b7c18b-b156-4e27-9904-c9ff286975af', embedding=None, metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/AlbertEinstein.txt', 'file_name': 'AlbertEinstein.txt', 'file_type': 'text/plain', 'file_size': 8235, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, excluded_embed_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], excluded_llm_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], relationships={<NodeRelationship.SOURCE: '1'>: RelatedNodeInfo(node_id='2a37d51d-ac93-4091-aad5-06b963941e44', node_type='4', metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/AlbertEinstein.txt', 'file_name': 'AlbertEinstein.txt', 'file_type': 'text/plain', 'file_size': 8235, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, hash='ebbeab8f1fb4d45db4be9071d503bd1d253736c0a2213119e2ac3946f6f207d0'), <NodeRelationship.PREVIOUS: '2'>: RelatedNodeInfo(node_id='4c8360c9-ad67-4171-b113-2215001eb01e', node_type='1', metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/AlbertEinstein.txt', 'file_name': 'AlbertEinstein.txt', 'file_type': 'text/plain', 'file_size': 8235, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, hash='9ae1df663260d045e1cbe0f113223faa4ea914fcfb8973706c3a90fc68bf06aa')}, metadata_template='{key}: {value}', metadata_separator='\n', text='In 1915, he completed his General Theory of Relativity, which described gravity not as a force, but as a curvature of spacetime caused by mass and energy. This theory made several predictions that were later confirmed experimentally, including the bending of light around massive objects.\n\n## International Fame (1915-1933)\n\nEinstein\'s general relativity gained worldwide attention when Sir Arthur Eddington\'s 1919 solar eclipse expedition confirmed the theory\'s prediction that light would bend around the sun. Overnight, Einstein became an international celebrity and the face of modern science.\n\nDuring this period, Einstein made significant contributions to quantum mechanics, statistical mechanics, and cosmology, though he remained skeptical of quantum mechanics\' probabilistic interpretation, famously stating "God does not play dice with the universe."\n\n## Personal Life\n\nEinstein married Mileva Marić in 1903, and they had two sons: Hans Albert and Eduard. The couple also had a daughter, Lieserl, born before their marriage, whose fate remains unknown. Einstein and Mileva divorced in 1919.\n\nLater in 1919, Einstein married his cousin Elsa Löwenthal, who had been caring for him during his illness. Elsa died in 1936.\n\nEinstein was known for his distinctive appearance—wild hair, casual dress, and pipe smoking—and his quirky personality. He was a pacifist, civil rights advocate, and spoke out against racism and nationalism.\n\n## Flight from Nazi Germany (1933-1939)\n\nAs the Nazi party rose to power in Germany, Einstein, being Jewish, faced increasing persecution. His books were burned, and he was forced to flee Germany in 1933. He accepted a position at the Institute for Advanced Study in Princeton, New Jersey, where he would spend the rest of his life.\n\nEinstein became an American citizen in 1940 while retaining his Swiss citizenship. During World War II, despite his pacifist beliefs, he wrote a letter to President Roosevelt urging the development of atomic weapons research, fearing Nazi Germany might develop them first. This led to the Manhattan Project, though Einstein himself was not involved in the actual development of the atomic bomb.\n\n## Later Years and Unified Field Theory (1939-1955)\n\nEinstein spent his later years searching for a "theory of everything" that would unify the fundamental forces of nature. His pursuit of a unified field theory was unsuccessful, and many colleagues thought he was pursuing an impossible dream.\n\nHe continued his work at Princeton and remained active in political and social causes, advocating for civil rights, nuclear disarmament, and world government. He declined an offer to become the second President of Israel in 1952.\n\n## Death and Legacy\n\nEinstein died on April 18, 1955, at age 76, from an abdominal aortic aneurysm. His last words were spoken in German to a night nurse who didn\'t understand the language, so they are lost to history.\n\n## Scientific Legacy\n\nEinstein\'s contributions to science are immeasurable:\n\n- **Relativity**: Both special and general relativity remain cornerstones of modern physics and have practical applications in GPS systems, particle accelerators, and astronomy.\n\n- **Quantum Mechanics**: Despite his philosophical objections to quantum mechanics, his early work laid important foundations for the field.\n\n- **Cosmology**: His field equations became the basis for modern cosmological models of the universe\'s expansion and evolution.\n\n- **Scientific Method**: Einstein emphasized the importance of thought experiments and conceptual clarity in physics.\n\n## Cultural Impact\n\nBeyond science, Einstein became a cultural icon representing genius and intellectual achievement. His image and quotes are widely recognized, and he remains a symbol of creativity, curiosity, and the power of human imagination.\n\nEinstein\'s work fundamentally changed our understanding of reality, space, time, and the universe itself. His theories continue to be tested and confirmed, and his influence on physics and human thought remains profound more than a century after his greatest discoveries.\n\n## Famous Quotes\n\n"Imagination is more important than knowledge."\n\n"The important thing is not to stop questioning."\n\n"Try not to become a person of success, but rather try to become a person of value."\n\n"Logic will get you from A to B. Imagination will take you everywhere."\n\nEinstein\'s life story is one of intellectual courage, scientific revolution, and humanitarian concern—a testament to the power of human curiosity and the pursuit of truth.', mimetype='text/plain', start_char_idx=3691, end_char_idx=8222, metadata_seperator='\n', text_template='{metadata_str}\n\n{content}'), score=0.8298978569689672)
    NodeWithScore(node=TextNode(id_='4c8360c9-ad67-4171-b113-2215001eb01e', embedding=None, metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/AlbertEinstein.txt', 'file_name': 'AlbertEinstein.txt', 'file_type': 'text/plain', 'file_size': 8235, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, excluded_embed_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], excluded_llm_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], relationships={<NodeRelationship.SOURCE: '1'>: RelatedNodeInfo(node_id='2a37d51d-ac93-4091-aad5-06b963941e44', node_type='4', metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/AlbertEinstein.txt', 'file_name': 'AlbertEinstein.txt', 'file_type': 'text/plain', 'file_size': 8235, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, hash='ebbeab8f1fb4d45db4be9071d503bd1d253736c0a2213119e2ac3946f6f207d0'), <NodeRelationship.NEXT: '3'>: RelatedNodeInfo(node_id='61b7c18b-b156-4e27-9904-c9ff286975af', node_type='1', metadata={}, hash='c0cb8aeb3ee55886421ab49b5cc8b2cfba747e0b11de1c5cb9bbc908117f7dda')}, metadata_template='{key}: {value}', metadata_separator='\n', text='# Albert Einstein: A Biography\n\n## Early Life (1879-1896)\n\nAlbert Einstein was born on March 14, 1879, in Ulm, in the Kingdom of Württemberg in the German Empire. His parents were Hermann Einstein, a salesman and engineer, and Pauline Koch Einstein. When Albert was one year old, the family moved to Munich, where his father and uncle founded Elektrotechnische Fabrik J. Einstein & Cie, a company that manufactured electrical equipment.\n\nEinstein showed early signs of intellectual curiosity, though contrary to popular myth, he was not a poor student. He excelled in mathematics and physics from a young age. When he was five, his father gave him a compass, and Einstein was fascinated by the invisible forces that moved the needle—an experience he later described as pivotal in developing his scientific curiosity.\n\nIn 1894, Einstein\'s family moved to Italy for business reasons, but Albert remained in Munich to finish his education. However, he left school early and rejoined his family in Italy. He then applied to the Swiss Federal Polytechnic in Zurich but failed the entrance exam, though he scored exceptionally well in mathematics and physics. After completing his secondary education in Switzerland, he was accepted to the Polytechnic in 1896.\n\n## Education and Early Career (1896-1905)\n\nEinstein studied at the Swiss Federal Polytechnic from 1896 to 1900, where he met Mileva Marić, a fellow physics student who would later become his first wife. After graduating in 1900, Einstein struggled to find academic employment and worked various temporary jobs, including as a tutor and substitute teacher.\n\nIn 1902, he secured a position at the Swiss Patent Office in Bern, where he worked as a technical assistant examiner. This job provided him with financial stability and, perhaps more importantly, time to pursue his own scientific research. The work at the patent office also exposed him to practical applications of electromagnetic theory, which influenced his later work.\n\nEinstein earned his doctorate from the University of Zurich in 1905 with a dissertation titled "On a New Determination of Molecular Dimensions."\n\n## The Miracle Year (1905)\n\n1905 became known as Einstein\'s "Annus Mirabilis" (miracle year) because he published four groundbreaking papers that revolutionized physics:\n\n### 1. Photoelectric Effect\nEinstein\'s paper on the photoelectric effect explained how light could behave as particles (photons), providing crucial evidence for quantum theory. This work earned him the Nobel Prize in Physics in 1921.\n\n### 2. Brownian Motion\nHis explanation of Brownian motion provided empirical evidence for the existence of atoms and molecules, convincing skeptics of atomic theory.\n\n### 3. Special Theory of Relativity\nPerhaps his most famous contribution, special relativity introduced the concept that space and time are interwoven into spacetime, and that the speed of light is constant for all observers. This theory challenged Newton\'s absolute concepts of space and time.\n\n### 4. Mass-Energy Equivalence\nThe famous equation E=mc² emerged from his work on special relativity, showing that mass and energy are interchangeable.\n\n## Academic Career and General Relativity (1905-1915)\n\nFollowing his 1905 publications, Einstein gained recognition in the scientific community. He moved through various academic positions:\n\n- 1908: Lecturer at the University of Bern\n- 1909: Professor at the University of Zurich\n- 1911: Professor at Charles University in Prague\n- 1912: Professor at ETH Zurich\n- 1914: Director of the Kaiser Wilhelm Institute for Physics in Berlin\n\nDuring this period, Einstein worked on extending his special theory of relativity to include gravity. In 1915, he completed his General Theory of Relativity, which described gravity not as a force, but as a curvature of spacetime caused by mass and energy. This theory made several predictions that were later confirmed experimentally, including the bending of light around massive objects.\n\n## International Fame (1915-1933)\n\nEinstein\'s general relativity gained worldwide attention when Sir Arthur Eddington\'s 1919 solar eclipse expedition confirmed the theory\'s prediction that light would bend around the sun. Overnight, Einstein became an international celebrity and the face of modern science.\n\nDuring this period, Einstein made significant contributions to quantum mechanics, statistical mechanics, and cosmology, though he remained skeptical of quantum mechanics\' probabilistic interpretation, famously stating "God does not play dice with the universe."\n\n## Personal Life\n\nEinstein married Mileva Marić in 1903, and they had two sons: Hans Albert and Eduard.', mimetype='text/plain', start_char_idx=0, end_char_idx=4656, metadata_seperator='\n', text_template='{metadata_str}\n\n{content}'), score=0.8272692481783651)
    NodeWithScore(node=TextNode(id_='dee2bf96-618c-49e1-96a7-066a86efa166', embedding=None, metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/meetingMarieAlbert.txt', 'file_name': 'meetingMarieAlbert.txt', 'file_type': 'text/plain', 'file_size': 2970, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, excluded_embed_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], excluded_llm_metadata_keys=['file_name', 'file_type', 'file_size', 'creation_date', 'last_modified_date', 'last_accessed_date'], relationships={<NodeRelationship.SOURCE: '1'>: RelatedNodeInfo(node_id='3671ed1c-c30f-49a7-b114-89ae1c502763', node_type='4', metadata={'file_path': '/Users/ojitha/GitHub/rag_llamaindex/Science_Community/data/meetingMarieAlbert.txt', 'file_name': 'meetingMarieAlbert.txt', 'file_type': 'text/plain', 'file_size': 2970, 'creation_date': '2025-09-12', 'last_modified_date': '2025-09-12'}, hash='2c787a09eb16dae22374d0976a5d2909d7e639a9399b9a160c14036f46544a4d')}, metadata_template='{key}: {value}', metadata_separator='\n', text='# When Marie Curie Met Albert Einstein\n\n## Brussels, October 1911\n\nThe first Solvay Conference buzzed with intellectual energy as the greatest minds in physics gathered to discuss the revolutionary concept of quantum theory. Among the distinguished attendees, two figures commanded particular attention: the legendary Marie Curie, recently awarded her second Nobel Prize, and the rising star Albert Einstein, whose theories were reshaping our understanding of space and time.\n\nEinstein, then 32, approached the 44-year-old Curie during a break between sessions. His wild hair was already becoming his trademark, while she maintained her characteristic composed demeanor despite the recent scandal surrounding her personal life that had dominated French newspapers.\n\n"Madame Curie," Einstein said in his accented French, offering a slight bow. "Your work on radioactivity has opened entirely new realms of physics. I confess, your dedication to isolating pure radium by hand is something I could never accomplish—I lack both the patience and the physical strength."\n\nMarie smiled, a rare moment of warmth crossing her typically serious expression. "Monsieur Einstein, your theory of relativity has challenged everything we thought we knew about the universe. I find myself wondering how radioactive decay might behave in your curved spacetime."\n\nThey found themselves deep in conversation, sketching equations on napkins and gesturing animatedly. Einstein was struck by Marie\'s methodical approach to problems, while she admired his ability to visualize complex physical phenomena through thought experiments.\n\n"You know," Einstein said, lowering his voice, "I\'ve read about the treatment you\'ve received in the French press. It\'s shameful how they attack your character when they should be celebrating your genius."\n\nMarie\'s eyes hardened slightly. "Science doesn\'t care about scandal, only truth. My work speaks for itself."\n\n"Indeed it does," Einstein replied with conviction. "And history will remember your contributions long after the gossips are forgotten."\n\nAs the conference continued, they often sought each other out during breaks, discussing not only physics but also their shared concerns about the growing tensions in Europe. Both had experienced the challenges of being outsiders in the scientific community—she as a woman, he as a Jew—and they found understanding in each other\'s struggles.\n\nYears later, when Einstein reflected on that first meeting, he would write: "Marie Curie is, of all celebrated beings, the only one whom fame has not corrupted." Their mutual respect would endure through correspondence and later meetings, two revolutionary minds bound by their dedication to unraveling the mysteries of the universe.\n\nIn that bustling hotel in Brussels, surrounded by the leading scientists of their age, Marie Curie and Albert Einstein discovered something rarer than radium or more elegant than relativity—a kindred intellectual spirit.', mimetype='text/plain', start_char_idx=0, end_char_idx=2962, metadata_seperator='\n', text_template='{metadata_str}\n\n{content}'), score=0.8038104489514425)


Let's create dataset for quality assurance:


```python
from llama_index.core.evaluation import generate_question_context_pairs

qa_dataset = generate_question_context_pairs(
    retrieval_eval_nodes, llm=gpt4_llm, num_questions_per_chunk=2,show
)
```

      0%|          | 0/3 [00:00<?, ?it/s]

    HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"


     33%|███▎      | 1/3 [00:01<00:03,  1.98s/it]

    HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"


     67%|██████▋   | 2/3 [00:06<00:03,  3.32s/it]

    HTTP Request: POST https://api.openai.com/v1/chat/completions "HTTP/1.1 200 OK"


    100%|██████████| 3/3 [00:08<00:00,  2.97s/it]


Check the results fo the QA dataset:


```python
qa_queries = qa_dataset.queries.values()
```


```python
pprint.pprint(list(qa_queries)[4])
```

    ('Describe the initial interaction between Marie Curie and Albert Einstein at '
     'the first Solvay Conference in 1911. What were the key topics they discussed '
     'and how did they express their mutual respect and admiration for each '
     "other's work?")


Create MRR evaluator:


```python
retriever_evaluator = RetrieverEvaluator.from_metric_names(
    ["mrr", "hit_rate"], retriever=query_eval_retriever
)
```

Test for the sample query


```python
sample_id, sample_query = list(qa_dataset.queries.items())[0]
sample_expected = qa_dataset.relevant_docs[sample_id]

eval_result = retriever_evaluator.evaluate(sample_query, sample_expected)
print(eval_result)
```

    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    Query: "Discuss the impact of Einstein's General Theory of Relativity on modern physics and provide examples of its practical applications as mentioned in the text."
    Metrics: {'mrr': 1.0, 'hit_rate': 1.0}
    


Evaluate for entire dataset


```python
# try it out on an entire dataset
qa_dataset_eval_results = await retriever_evaluator.aevaluate_dataset(qa_dataset)
```

    Retrying request to /embeddings in 0.488101 seconds
    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"
    HTTP Request: POST https://api.openai.com/v1/embeddings "HTTP/1.1 200 OK"



```python
metric_dicts = []
for eval_result in qa_dataset_eval_results:
    metric_dict = eval_result.metric_vals_dict
    metric_dicts.append(metric_dict)

full_df = pd.DataFrame(metric_dicts)

hit_rate = full_df["hit_rate"].mean()
mrr = full_df["mrr"].mean()

metric_df = pd.DataFrame(
    { "Hit Rate": [hit_rate], "MRR": [mrr]}
)

metric_df


```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Hit Rate</th>
      <th>MRR</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1.0</td>
      <td>0.833333</td>
    </tr>
  </tbody>
</table>
</div>



As shown in the above, results are pretty good may be because I am using only three documents and my evaluation question is very straight where inferencing is very easy to demonstrate the concepts in here.

[^1]: [Generative AI for Cloud Solutions](https://learning.oreilly.com/library/view/generative-ai-for/9781835084786/){:target="_blank"}

[^2]: [Building Retrieval Augmented Generation (RAG) Applications with LlamaIndex: From Basic Components to Advanced RAG Systems](https://learning.oreilly.com/course/building-retrieval-augmented/0790145860415/){:target="_blank"}

[^3]: [30 Agents Every AI Engineer Must Build](https://learning.oreilly.com/library/view/30-agents-every/9781806109012/){:target="_blank"}

[^4]: [Building Data-Driven Applications with LlamaIndex](https://learning.oreilly.com/library/view/building-data-driven-applications/9781835089507/)

[^5]: [Effective Conversational AI](https://learning.oreilly.com/library/view/effective-conversational-ai/9781633436404/)
