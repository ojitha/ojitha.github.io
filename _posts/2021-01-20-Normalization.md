---
layout: post
title:  Normalization
date:   2021-01-20
categories: [RDBMS]
---

E. F. Codd proposed three normal forms 1NF, 2NF and 3NF (1970). Revised definition (1974) was given by F. Boyce and Codd which is known as Boyce-Codd Normal Form (BCNF which is 3.5NF) to distinguish it from the old definition of third normal form. R. Faign introduced 4NF(1977) and 5NF(1979) and DKNF(1981). All the normal forms depend on the functional dependency, but 4NF and 5NF have been proposed which are based on the concept of multivalued dependency and joining dependency, respectively.

* TOC
{:toc}

<!--more-->

<script src="https://unpkg.com/mermaid@8.8.4/dist/mermaid.min.js"></script>
<script type="text/javascript" id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js">
</script>
<script type="text/javascript">
window.MathJax = {
  tex: {
    packages: ['base', 'ams']
  },
  loader: {
    load: ['ui/menu', '[tex]/ams']
  }
};
</script>


## Why Normalization?

Normalization theory provides the guidelines to assess the quality of a database in designing process. 

> The normalization[^2] is the application of set of simple rules called Normal Forms (NF) to the relation schema.

Good schema has the following:

- Minimum redundancy
    - Insertion anomaly:
    - Deletion anomaly
    - Modification anomaly
- Fewer `null` values in Tuples

## Decompostion

The decomposition of relation schema $$R$$ defined as its replacement by a set of relation schemas such that each relation schema contains a subset of attributes of $$R$$. Ensure that each attribute in $$R$$ must appear in at least one relation schema $$R_{i}$$.



$$
\begin{aligned}\sum R_{i}=R\\
\end{aligned}
$$

This is called **attribute prevention**.

Let `X` and `Y` are subset of se of attributes of a relation $R$ , then an instance $r$ of $R$ satisfies functional dependency (FD) $$\left( FD\right) X\rightarrow Y$$, if and only if for any two tuples $$t_{1}$$ and $$t_{2}$$ in $$r$$ that have $$t_{1}[X] = t_{2}[X]$$ and $$t_{1}[Y] = t_{2}[Y]$$

> $$X\rightarrow Y$$ mean, `Y` is functionally dependent on `X` or `X` determine `Y`. Here `X` is determinant and `Y` is the dependent.

The FD diagram is

<div class="mermaid">
graph LR;
    X-->Y;
</div>

> The large set of FDs can reduce the efficiency of database system. Generally an $$\left( FD\right) A\rightarrow B$$ is trivial, if and only if $$B\subseteq A$$. Only **non-trivial dependencies** are considered. 				
> 									

For example, CART{order_number, order_date, item, item_qty, customer, address}.



## First Normal Form

A relation $$R$$ is said to be in 1NF if an only if the domains of all attributes of $$R$$ contain atomic values only.

Creating one tuple for each value in multivalued attributes in the CART is the example to show.



## Second Normal Form

This level depends on full FD. An attribute `Y` of relation schema $$R$$ is said to be **fully functional dependent** on attribute `X` $$(X \rightarrow Y)$$, if there is no `A`, where `A` is proper subset of `X` such that $$A\rightarrow Y$$, otherwise this is called **partial functional dependency**.

<div class="mermaid">
flowchart LR
  customer --> address
  order_number --> address  
  subgraph order_item
    	order_item.order_number[order_number]
    	item
  end
  order_number-->order_date
  order_item --> item_qty
  order_number --> customer	
</div>

A relation schema $$R$$ is said to be in 2NF if every non-key attribute `A` in $$R$$ is fully FD on the primary key.

Now two relatonal schemas

CART{order_number, order_date, customer, address}

ORDER_ITEM{order_number, item, item qty}

Above FD diagram depicts the two relations.

## Third Normal Form

The third normal form is based on the concept of transitive dependency. An attribute `Y` of a relation schema $$R$$ is said to be **transitively dependent** on attribute `X` $$X \rightarrow Y$$, if there is set of attributes `A` that is neither a candidate key nor a subset of any key of $$R$$ and both $$X \rightarrow A $$ and $$A \rightarrow Y$$ hold.

For example, $$order\_number \rightarrow address$$ is transitive through `customer` as shown in the above diagram: $$order\_number\rightarrow customer$$ and $$customer\rightarrow address$$. To simplify the situation, I have introduce **surrogate key** `customer_id`.

<div class="mermaid">
flowchart LR
	subgraph customer
		customer_id
	end	
	customer --> address  
</div>

Now the remaining class is 

<div class="mermaid">
flowchart LR
	subgraph cart
		order_number
		customer_id
		order_date
	end
</div>

The attribute `item` kept simple to show the normalization process clear. See more complex normalization example here[^1].
REF

[^1]: [What is Normalization? 1NF, 2NF, 3NF, BCNF Database Example](https://www.guru99.com/database-normalization.html)

[^2]: [Introduction to Database Systems](https://learning.oreilly.com/library/view/introduction-to-database/9788131731925/) by ITL Education Solutions Limited*Published by [Pearson India](https://learning.oreilly.com/library/publisher/pearson-india/), 2008*