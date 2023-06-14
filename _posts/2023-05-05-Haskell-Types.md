---
layout: post
title:  Introduction to Haskell Types
date:   2023-04-28
categories: [Haskell]
---


You can define as 

```haskell
data Shape =  Circle Float | Rect Float Float
square n = Rect n n -- (1) square :: Float -> Shape
area (Circle r) = pi * r^2 -- (2) area :: Shape -> Float
area (Rect x y) = x * y
```

The `area` need `Shape` as input as shown in the (2), in turn `square` returns the `Shape` as shown in the (1), therefore, we can calcualte the area of the rectangle substituting `square` in the `area`:
```haskell
area (square 5)
-- 25.0  is the output
```

Or you can calculate the circle area

```haskell
area (Circle 3.0)
-- 28.274334 is the output
```