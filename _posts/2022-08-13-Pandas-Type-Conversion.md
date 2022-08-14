---
layout: post
title:  Pandas type conversion
date:   2022-08-13
categories: [AWS]
---

Sometimes we need to remove unnecessary data and save the column in the right format in the Pandas data frames.

<!--more-->

If you want real time testing, please refer to the posts [AWS Glue run locally]({% post_url 2022-08-13-AWS-Glue-run-locally %}) or [Glue Development using Jupyter]({% post_url 2022-07-11-Glue development using Jupyter %}).

```dockerfile
FROM amazon/aws-glue-libs:glue_libs_3.0.0_image_01
WORKDIR /home/glue_user/workspace/jupyter_workspace
ENV DISABLE_SSL=true
RUN pip3 install pyathena
RUN pip3 install seaborn
CMD [ "./start.sh" ]
```

First import the `pandas` and `seaborn` :


```pyspark
import pandas as pd
import seaborn as sns
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


Show the tips data frame contents:


```pyspark
tips = sns.load_dataset('tips')
tips.head()
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


       total_bill   tip     sex smoker  day    time  size
    0       16.99  1.01  Female     No  Sun  Dinner     2
    1       10.34  1.66    Male     No  Sun  Dinner     3
    2       21.01  3.50    Male     No  Sun  Dinner     3
    3       23.68  3.31    Male     No  Sun  Dinner     2
    4       24.59  3.61  Female     No  Sun  Dinner     4

Information about the data frame:


```pyspark
tips.info()
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 244 entries, 0 to 243
    Data columns (total 7 columns):
     #   Column      Non-Null Count  Dtype   
    ---  ------      --------------  -----   
     0   total_bill  244 non-null    float64 
     1   tip         244 non-null    float64 
     2   sex         244 non-null    category
     3   smoker      244 non-null    category
     4   day         244 non-null    category
     5   time        244 non-null    category
     6   size        244 non-null    int64   
    dtypes: category(4), float64(2), int64(1)
    memory usage: 7.4 KB

Only the data types of the columns:


```pyspark
tips.dtypes
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


    total_bill     float64
    tip            float64
    sex           category
    smoker        category
    day           category
    time          category
    size             int64
    dtype: object

Convert columns:


```pyspark
tips['size_str'] = tips['size'].astype(str)
tips.head()
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


       total_bill   tip     sex smoker  day    time  size size_str
    0       16.99  1.01  Female     No  Sun  Dinner     2        2
    1       10.34  1.66    Male     No  Sun  Dinner     3        3
    2       21.01  3.50    Male     No  Sun  Dinner     3        3
    3       23.68  3.31    Male     No  Sun  Dinner     2        2
    4       24.59  3.61  Female     No  Sun  Dinner     4        4


```pyspark
tips.dtypes
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


    total_bill     float64
    tip            float64
    sex           category
    smoker        category
    day           category
    time          category
    size             int64
    size_str        object
    dtype: object

Extract the rows based on the index:


```pyspark
tips.loc[[1,2,20]]
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


        total_bill   tip   sex smoker  day    time  size size_str
    1        10.34  1.66  Male     No  Sun  Dinner     3        3
    2        21.01  3.50  Male     No  Sun  Dinner     3        3
    20       17.92  4.08  Male     No  Sat  Dinner     2        2

When `total_bill` changed to the string:


```pyspark
temp_df = tips.head(5)
temp_df.loc[[1,3], 'total_bill'] = "test"
temp_df
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


      total_bill   tip     sex smoker  day    time  size size_str
    0      16.99  1.01  Female     No  Sun  Dinner     2        2
    1       test  1.66    Male     No  Sun  Dinner     3        3
    2      21.01  3.50    Male     No  Sun  Dinner     3        3
    3       test  3.31    Male     No  Sun  Dinner     2        2
    4      24.59  3.61  Female     No  Sun  Dinner     4        4
    /home/glue_user/.local/lib/python3.7/site-packages/pandas/core/indexing.py:1817: SettingWithCopyWarning: 
    A value is trying to be set on a copy of a slice from a DataFrame.
    Try using .loc[row_indexer,col_indexer] = value instead
    
    See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
      self._setitem_single_column(loc, value, pi)


```pyspark
temp_df.dtypes
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


    total_bill      object
    tip            float64
    sex           category
    smoker        category
    day           category
    time          category
    size             int64
    size_str        object
    dtype: object

As shown in the above, now `total_bill` is an object type.

It is not possible to convert back `temp_df.total_bill` back to the numeric because of the `test` string. 
Therefore, you have to use the `to_numeric(...)` method in this case:


```pyspark
pd.to_numeric(temp_df.total_bill, errors="coerce")
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


    0    16.99
    1      NaN
    2    21.01
    3      NaN
    4    24.59
    Name: total_bill, dtype: float64

In addition to the above `coerce`, `ignore` also possible, but the string will be remained.
As shown above, which cannot be converted to numeric has been converted as Not a Number(NaN).


```pyspark
pd.to_numeric(temp_df.total_bill, errors="ignore", downcast='float')
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


    0    16.99
    1     test
    2    21.01
    3     test
    4    24.59
    Name: total_bill, dtype: object

To check the categorical columns:


```pyspark
tips['smoker'].cat.categories
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


    Index(['Yes', 'No'], dtype='object')

To find the codes:


```pyspark
tips['smoker'].cat.codes
```


    FloatProgress(value=0.0, bar_style='info', description='Progress:', layout=Layout(height='25px', width='50%'),…


    0      1
    1      1
    2      1
    3      1
    4      1
          ..
    239    1
    240    0
    241    0
    242    1
    243    1
    Length: 244, dtype: int8

As shown in the above results, 0s and 1s are represent the `Yes` and `No`.

