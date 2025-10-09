---
layout: notes 
title: Machine Learning
mermaid: true
maths: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../assets/images/${filename}
---

# Notes on ML
{:.no_toc}

---

* TOC
{:toc}

---

## ML

Algorithms

```mermaid
graph LR
    Dataset[Dataset] --> Target{Contain<br/>target value?}
    
    Target -->|Yes| SL[Supervised<br/>Learning]
    Target -->|No| UL[Unsupervised<br/>Learning]
    
    %% Supervised Learning Branch
    SL --> Cat[Categorical]
    SL --> Cont[Continuous]
    
    %% Classification Branch
    Cat --> Class[Classification]
    Class --> Binary[Binary]
    Class --> Multi[Multiclass]
    
    Binary --> LR[Logistic Regression]
    Binary --> DT1[Decision Trees]
    Binary --> RF1[Random Forest]
    Binary --> SVM1[SVM]
    
    Multi --> LR2[Logistic Regression]
    Multi --> DT2[Decision Trees]
    Multi --> RF2[Random Forest]
    Multi --> KNN1[K-Nearest Neighbors]
    
    %% Regression Branch
    Cont --> Reg[Regression]
    Reg --> Simple[Simple Linear]
    Reg --> Multiple[Multiple Linear]
    Reg --> Poly[Polynomial]
    Reg --> Ridge[Ridge]
    Reg --> Lasso[Lasso]
    Reg --> DTR[Decision Tree]
    Reg --> RFR[Random Forest]
    
    %% Unsupervised Learning Branch
    UL --> Discrete[Discrete<br/>Group]
    UL --> Outliers[Outliers]
    UL --> DimRed[Dimensionality<br/>Reduction]
    UL --> Assoc[Association<br/>Rules]
    
    %% Clustering Branch
    Discrete --> Cluster[Clustering]
    Cluster --> KMeans[K-Means]
    Cluster --> Hierarchical[Hierarchical]
    Cluster --> DBSCAN[DBSCAN]
    
    %% Anomaly Detection Branch
    Outliers --> Anomaly[Anomaly<br/>Detection]
    Anomaly --> IsoForest[Isolation Forest]
    Anomaly --> LOF[Local Outlier Factor]
    Anomaly --> OCSVM[One-Class SVM]
    
    %% Dimensionality Reduction Branch
    DimRed --> PCA[PCA]
    DimRed --> tSNE[t-SNE]
    DimRed --> LDA[LDA]
    
    %% Association Rules Branch
    Assoc --> Apriori[Apriori]
    Assoc --> FPGrowth[FP-Growth]
    
    style Dataset fill:#f9f,stroke:#333,stroke-width:2px
    style Target fill:#fcf,stroke:#333,stroke-width:2px
    style SL fill:#bbf,stroke:#333,stroke-width:2px
    style UL fill:#bfb,stroke:#333,stroke-width:2px
    style Class fill:#fbb,stroke:#333,stroke-width:2px
    style Reg fill:#fbf,stroke:#333,stroke-width:2px
    style Cluster fill:#bff,stroke:#333,stroke-width:2px
    style Anomaly fill:#ffb,stroke:#333,stroke-width:2px
```



## Linear Algebra for ML

What is Linear Algebra?

If it has an exponential term, it isn't linear algebra such as $2x^2+5 = 13$ or $2\sqrt{x}+6=13$. There can be 3 solutions in linear algebra:

1. one solution
2. no solution
3. infinite solution

In a given system, there could be many equations and many unknowns as $y=a+bx_{1}+cx_{2}+\ldots +mx_{n}$.



[^1]: [Linear Algebra for Machine Learning](https://learning.oreilly.com/course/linear-algebra-for/9780137398119/){:target="_blank"}



