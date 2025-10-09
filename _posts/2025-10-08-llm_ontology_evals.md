---
layout: post
title:  Ontology Evals for LLMs
date:   2025-10-08
maths: true
categories: [AI, AWS]
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../../blog/assets/images/${filename}
---


My previous work on ontologies defined in RDF Structured Data mining[^12] and Apache Jena[^14] provide formal, structured representations of domain knowledge that can be harnessed as evaluation frameworks (Evals) for assessing outputs of LLMs. Using the well-known Pizza ontology[^13] as a running example, illustrate how **domain-specific ontologies** can guide the evaluation of LLM-generated content such as recipe emails. The framework emphasises mapping unstructured LLM outputs into ontology-aligned structured data, applying reasoning engines to **verify factual and logical coherence, and deriving quantitative and qualitative evaluation metrics**.

<!--more-->

------

* TOC
{:toc}
------

## 1. Introduction

Large language models (LLMs) have demonstrated remarkable capabilities in generating coherent and contextually relevant text across diverse domains. However, evaluating the factual accuracy, domain consistency, and logical coherence of LLM outputs remains a critical challenge. Traditional evaluation metrics often rely on surface-level similarity measures or human judgment, which may not capture deeper semantic correctness or adherence to domain knowledge.

Ontologies—formal, explicit specifications of conceptualisations—offer a promising avenue to address this challenge. Defined in languages such as the Resource Description Framework (RDF) and the Web Ontology Language (OWL), ontologies encode domain knowledge as classes, properties, and relations with formal semantics. By leveraging ontologies as structured evaluation frameworks (Evals), it becomes possible to systematically assess whether LLM-generated content aligns with domain-specific knowledge and constraints.

that integrates ontology parsing, semantic extraction, reasoning, and metric computation. The Pizza ontology, a canonical OWL ontology modelling pizza types and ingredients, serves as an illustrative example to concretise the approach.



## 2. Background and Literature Review

### 2.1 Ontologies in Computer Science

Ontologies formalise domain knowledge by defining concepts (classes), their properties, and interrelations within a domain [^1]. They enable shared understanding and interoperability across systems by providing explicit semantics. Ontologies are widely used in knowledge representation, the semantic web, and artificial intelligence to support reasoning and decision-making.

### 2.2 RDF and OWL as Ontology Languages

The Resource Description Framework (RDF) models information as triples (subject-predicate-object), forming directed labelled graphs [^2]. RDF provides a flexible syntax for encoding metadata and domain knowledge. The Web Ontology Language (OWL) builds on RDF to offer richer expressivity, including class hierarchies, property restrictions, and logical axioms [^3]. OWL ontologies enable automated reasoning about domain concepts and constraints.

### 2.3 Ontologies and Large Language Models

Recent research explores integrating ontologies with LLMs to enhance knowledge grounding, alignment, and evaluation[^4] in discussion[^5]: Ontologies can guide LLM training, prompt engineering, and output verification by providing structured domain schemas. However, direct use of RDF/OWL ontologies as evaluation frameworks for LLM outputs remains an emerging area.

### 2.4 Ontology-Based Evaluation Frameworks

Ontology-driven evaluation involves mapping LLM-generated text to ontology-aligned structured data and applying reasoning to verify consistency and completeness[^6]. Frameworks such as OntoTune demonstrate ontology-guided self-training and alignment of LLMs[^7]. Lightweight inference rules (e.g., N3Logic) facilitate mechanised reasoning over RDF/OWL data[^8]. 

> Despite conceptual advances, practical pipelines for converting ontologies like pizza.owl into Eval scripts are nascent.
{:.yellow}

---

## 3. Methodology: Framework for Ontology-Based LLM Evaluation

We propose a multi-stage framework to operationalise RDF/OWL ontologies as Eval frameworks for LLM-generated outputs:

### 3.1 Ontology Parsing and Representation

- **Objective:** Extract domain classes, properties, and axioms from the ontology file (e.g., pizza.owl).
- **Tools:** OWL API, Apache Jena, or RDFLib can parse OWL/RDF files and expose ontology elements programmatically.
- **Output:** Machine-readable ontology schema including class hierarchies, object/data properties, and logical constraints.

### 3.2 Semantic Extraction from LLM Outputs

- **Objective:** Convert unstructured LLM-generated text (e.g., pizza recipe email) into structured data aligned with ontology schema.
- **Techniques:**
  - Named entity recognition (NER) and relation extraction tuned to ontology concepts.
  - Prompt engineering or template-based generation to elicit structured triples from LLMs.
  - Semantic parsing to RDF triples referencing ontology classes and properties.
- **Output:** Instance data representing entities and relations extracted from text, formatted as RDF triples or OWL individuals.

### 3.3 Reasoning and Consistency Checking

- **Objective:** Verify that extracted instance data conforms to ontology axioms and constraints.
- **Tools:** OWL reasoners such as Pellet, Hermit, or N3Logic engines.
- **Checks:**
  - Class membership validation (e.g., `ingredient` instances belong to `PizzaIngredient` subclasses).
  - Property constraint verification (e.g., `toppings` linked via the `hasTopping` property).
  - Logical consistency and completeness (e.g., all required components present).
- **Output:** Reasoning results indicating consistency, inferred classifications, and detected violations.

### 3.4 Eval Metric Formulation

- **Objective:** Quantify the quality of LLM output based on ontology alignment.
- **Metrics:**
  - **Factual Coverage:** Proportion of required ontology classes and properties mentioned.
  - **Relation Correctness:** Accuracy of stated relations against ontology definitions.
  - **Logical Coherence:** Degree of consistency and absence of contradictions per reasoning.
  - **Completeness Score:** Extent to which all necessary components (e.g., crust, sauce, cheese) are included.
- **Output:** Composite Eval scores or qualitative flags guiding assessment.

### 3.5 Iterative Refinement and Feedback

- **Objective:** Use Eval results to improve LLM outputs via fine-tuning or prompt adjustment iteratively.
- **Approach:** Incorporate ontology-driven feedback loops as in OntoTune [^7] to align LLM knowledge with domain ontology.

---

## 4. Key Findings and Illustrative Example: Pizza Ontology Eval

### 4.1 Pizza Ontology Overview

The Pizza ontology[^9] models pizza types, ingredients, toppings, and preparation concepts in OWL. It defines classes such as `Pizza`, `PizzaBase`, and `Topping`, as well as properties like `hasTopping` and `hasBase`. The ontology encodes hierarchical relations and constraints (e.g., certain toppings are only valid for specific pizza types).

### 4.2 Applying the Framework to a Pizza Recipe Email

**Step 1: Ontology Parsing**

- Load `pizza.owl` using OWL API.
- Extract classes: `Pizza`, `MargheritaPizza`, `MozzarellaTopping`, etc.
- Extract properties: `hasTopping`, `hasBase`.

**Step 2: Semantic Extraction**

- Input: LLM-generated email describing a pizza recipe.
- Use NER and relation extraction to identify entities: "Margherita pizza", "mozzarella cheese", "tomato sauce".
- Map entities to ontology classes: "Margherita pizza" → `MargheritaPizza`, "mozzarella cheese" → `MozzarellaTopping`.
- Extract relations: `hasTopping(MargheritaPizza, MozzarellaTopping)`.

**Step 3: Reasoning**

- Use Pellet reasoner to check:
  - Are all toppings valid for `MargheritaPizza` per ontology?
  - Does the recipe include required components (base, sauce, cheese)?
  - Is the combination logically consistent?

**Step 4: Eval Metrics**

- Factual coverage: 90% (all required ingredients mentioned).
- Relation correctness: 100% (all toppings valid).
- Logical coherence: Pass (no contradictions).
- Completeness: High (all preparation steps included).

**Step 5: Feedback**

- If missing components are detected, prompt LLM to include them in subsequent generations.

### 4.3 Benefits and Challenges

- **Benefits:** Ontology-based Evals provide domain-aware, semantically rich evaluation beyond surface text similarity.
- **Challenges:** *Mapping free text to ontology instances requires sophisticated NLP*; reasoning can be computationally intensive; tooling integration is nontrivial.

---

## 5. Discussion

### 5.1 Implications for LLM Evaluation

Ontology-driven evaluation frameworks enable a rigorous and interpretable assessment of LLM outputs, grounded in **formal domain knowledge**. This approach can enhance trustworthiness and domain alignment, particularly in specialised fields (e.g., medicine, law, insurance, banking, culinary arts, and others).

### 5.2 Limitations

- Lack of off-the-shelf tools to automate the entire pipeline from OWL ontology to Eval scripts.
- Semantic extraction from natural language remains a bottleneck requiring domain-specific tuning.
- Ontology completeness and correctness directly impact Eval reliability.

### 5.3 Connections to Broader Research

The framework aligns with ongoing research in ontology-LLM integration, knowledge graph construction, and semantic evaluation. It complements efforts in explainable AI by providing transparent, logic-based Eval criteria.

---

## 6. Conclusion and Future Work

This report presents a structured framework for leveraging RDF/OWL ontologies as evaluation frameworks for LLM-generated outputs, illustrated through the Pizza ontology example. By parsing ontologies, extracting structured data from text, applying reasoning, and formulating Eval metrics, practitioners can systematically assess LLM outputs for domain consistency and factual accuracy.

Future research should focus on developing integrated toolkits that automate ontology parsing, semantic extraction, and reasoning-based evaluation. Advances in semantic parsing and ontology alignment will further enhance the feasibility of ontology-driven LLM Evals. Extending this approach to diverse domains promises to enhance the reliability and domain awareness of LLM applications.



## References

[^1]: Ontology (information science), Wikipedia, https://<a href="https://en.wikipedia.org/wiki/Ontology_(information_science)" target="_blank">https://en.wikipedia.org/wiki/Ontology_(information_science)</a>
[^2]: Resource Description Framework, Wikipedia, https://<a href="https://en.wikipedia.org/wiki/Resource_Description_Framework" target="_blank">https://en.wikipedia.org/wiki/Resource_Description_Framework</a>
[^3]: Web Ontology Language, Wikipedia, https://<a href="https://en.wikipedia.org/wiki/Web_Ontology_Language" target="_blank">https://en.wikipedia.org/wiki/Web_Ontology_Language</a>
[^4]: "Integrating Ontologies with Large Language Models for Decision Making," Plain English AI, https://<a href="https://ai.plainenglish.io/integrating-ontologies-with-large-language-models-for-decision-making-bb1c600ce5a3" target="_blank">ai.plainenglish.io/integrating-ontologies-with-large-language-models-for-decision-making-bb1c600ce5a3</a>
[^5]: Nachi Keta, "Ontologies, LLMs and Knowledge Graphs: A Discussion," Medium, https://<a href="https://nachi-keta.medium.com/ontologies-llms-and-knowledge-graphs-a-discussion-cadeeabe1cc7" target="_blank">nachi-keta.medium.com/ontologies-llms-and-knowledge-graphs-a-discussion-cadeeabe1cc7</a>
[^6]: DocDigitizer, "A Comprehensive Guide to Ontologies and Large Language Models," https://<a href="https://www.docdigitizer.com/blog/ontologies-large-language-models-guide/" target="_blank">www.docdigitizer.com/blog/ontologies-large-language-models-guide/</a>
[^7]: Liu, Zhiqiang et al., "OntoTune: Ontology-Driven Self-training for Aligning Large Language Models," arXiv:2502.05478 (2025-02-08), http://arxiv.org/abs/2502.05478
[^8]: Tomaszuk, Dominik, "Inference rules for RDF(S) and OWL in N3Logic," arXiv:1601.02650 (2016-01-11), http://arxiv.org/abs/1601.02650
[^9]: Pizza Ontology, Stanford Protégé, https://<a href="https://protege.stanford.edu/ontologies/pizza/pizza.owl" target="_blank">protege.stanford.edu/ontologies/pizza/pizza.owl</a>
[^10]: Wisnesky, Ryan & Filonik, Daniel, "Relational to RDF Data Migration by Query Co-Evaluation," arXiv:2403.01630 (2024-03-03), http://arxiv.org/abs/2403.01630
[^11]: Lippolis, Anna Sofia et al., "Ontology Generation using Large Language Models," arXiv:2503.05388 (2025-03-07), http://arxiv.org/abs/2503.05388

[^12]: [Structured data meaning](https://ojitha.blogspot.com/2020/08/structured-data-meaning_69.html){:target="_blank"}

[^13]: [Missing Manual: Protégé OWL Tutorial](https://ojitha.blogspot.com/2010/09/missing-manual-protege-owl-tutorial.html){:target="_blank"}

[^14]: [Apache Jena to learn RDF and SPARQL](https://ojitha.blogspot.com/2020/08/apache-jena-to-learn-rdf-and-sparql_64.html){:target="_blank"}

