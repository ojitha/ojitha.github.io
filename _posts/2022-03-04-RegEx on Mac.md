---
layout: post
title:  RegEx on MacOS
date:   2022-03-04
categories: [RegEx]
---


As I understood, RegExs are very useful for general work. Most of the following regular expressions (RegEx)s can be run on the MacOs terminal, where you can get the great value of command line tools that have no value without RegExs (`grep`, `sed` and so on). In addition, I've used some popular tools to explain complex operations later in the document, which has been referenced under the footnotes.

<!--more-->

------

* TOC
{:toc}
------

## macOS grep or ggrep

For the MacOs, the default `grep` (FreeBSD version) is very limited. You cannot run all the bash commands expressed in this blog post using the MacOs standard `grep` command. Therefore install the grep from the home-brew:

```bash
brew install grep
```

and use the command `ggrep` instead of `grep`. For the help

```bash
ggrep --help
```

NOTE: The improved grep is `ggrep`.

For testing purposes, download the texts of Shakespeare[^1] as a zip file after you extract the zip file.

## Find a text in a file

To find the word in the TXT file:

```bash
egrep --color the hamlet_TXT_FolgerShakespeare.txt
```

This will show you something similar to the following output.

![image-20220304192546992](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220304192546992.png)

You can see the `the` is highlighted.

## Find in the folder

Locate the file in the file system where every file shows the lines that contain text `henry`.

```bash
find . -exec egrep -H 'Henry IV' {} \; 2>/dev/null
```

![List the file which has the seach](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220304195622052.png)

For example, case-sensitive match:

```bash
egrep --color 'the|is' hamlet_TXT_FolgerShakespeare.txt
```

![multiple words in the search](/assets/images/multiple words in the search.png)

For case insensitive match, use the `-i` option

```bash
egrep --color -i 'england' hamlet_TXT_FolgerShakespeare.txt
```

![case-intensive-search](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/case-intensive-search.jpg)

To implement the Enhanced Regular Expressions (ERE) dialect, use `grep -E`(`grep -P` say PCRE, for MacOS use the `perl` in the terminal), and `egrep` is the shortened form of that.

If you want a collection of text to match, you can use either alternation `|` or an external text file with the words. 

```
echo 'england' >>  search_keywords.txt
echo 'ambassadors' >>  search_keywords.txt
echo 'gives' >> search_keywords.txt
```

Search command is

```bash
egrep --color -f search_keywords.txt hamlet_TXT_FolgerShakespeare.txt
```

To show the lines do not match (negative of the above), use `v` option:

```bash
egrep --color -v -i -f search_keywords.txt hamlet_TXT_FolgerShakespeare.txt
```



## Character Class

You can create complex search key expressions using a class of characters. To create a character class, use the `[]` in the search. For example

```bash
egrep --color -i '[abc]' hamlet_TXT_FolgerShakespeare.txt
```

![Character class example](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220304230229838.png)

The complement of the above is `[^abc]`.

![complement of the character class](/assets/images/complement of the character class.png)

For example:

### Generic Character classes

| Generic | Class          |
| ------- | -------------- |
| `\d`    | `[0-9]`        |
| \D      | `[^0-9]`       |
| `\w`    | `[a-zA-Z0-9]`  |
| `\W`    | `[^a-zA-Z0-9]` |
| `\s`    | `[\t\n\r\f]`   |
| `\S`    | `[^\t\n\r\f]`  |

For example

```bash
echo 'Hello Ojitha 1234' | grep --color -i '\D'
```

![Generic character class example](/assets/images/Generic character class example.png)

Only the words are selected.

![Select only the part of the searching word](/assets/images/2022-03-04-RegEx on Mac/Select only the part of the searching word.jpg)

### Posix Character Classes



This has been created to simplify the character classes. The syntax is `[[:CLASS:]]`. Use the `^` as the complement `[[:^CLASS:]]`.

> Only Perl regex supports the following classes.
>
> Use `Perl` in the macOS terminal

| Posix   | Characte Class | Description        |
| ------- | -------------- | ------------------ |
| `alnum` | [a-zA-Z0-9]    | letters and digits |
| `word`  | [a-zA-Z0-9]    | word characters    |
| `alpha` | [a-zA-Z]       | Letters            |
| `digit` | [0-9]          | Digits             |
| `lower` | [a-z]          | lower case letters |
| `upper` | [A-Z]          | upper case letters |
| `space` | [\t\n\f\r]     | White space        |



```bash
grep --color -E  '[[:upper:]]' hamlet_TXT_FolgerShakespeare.txt
```

Or

```bash
perl  -ne 'print if /[[:^word:]]/' hamlet_TXT_FolgerShakespeare.txt
```

Or

```bash
ggrep --color -P  '[[:upper:]]' hamlet_TXT_FolgerShakespeare.txt
```

another example to search 12 and non other digits:

![not numbers except 1 and 2](/assets/images/2022-03-04-RegEx on Mac/CleanShot 2023-05-13 at 21.29.33@2x.jpg)

## Quantifiers

In the regex expression, we want to quantify how many characters we want to match, for example.



| Quantifier | Description       |
| ---------- | ----------------- |
| `?`        | 0 or 1            |
| `*`        | 0 or more         |
| `+`        | 1 or more         |
| `{n}`      | n                 |
| `{n,}`     | match n or more   |
| `{n,m}`    | match n thorugh m |

For example 

```bash
echo 'my 20 birtday party @ bay' |egrep --color '\d{2}\s\w{3}'
```

can be visualized[^2] as:

![quantifier example](/assets/images/2022-03-04-RegEx on Mac/quantifier_example.png)


The output of the above regex is

![Use_of_quantifier](/assets/images/Use_of_quantifier.png)

In the Perl regex

```bash
echo 'my 20 Birtday party @ Bay' |grep --color -E '[[:upper:]]{1}'
```

output is 

![Use Quntifiers with Posix classes](/assets/images/Use Quntifiers with Posix classes.png)

See the following example:

![Quantifiers are greedy](/assets/images/2022-03-04-RegEx on Mac/CleanShot 2023-05-13 at 21.59.50@2x.jpg)

Quantifiers are greedy, the consume as much as they can.



### Inline Modifiers

| Modifier | Description                                                  |
| -------- | ------------------------------------------------------------ |
| `(?x)`   | Embed whitespace                                             |
| `(?i)`   | Case insensitive match                                       |
| `(?s)`   | Single line mode                                             |
| `(?m)`   | Multi line mode, here `\A` start if the string and `\Z` end of the string. |

For example, although I specify the Posix class `lower` for lower letters, when you specify modifier `(?xi)`, it shows all the words ignoring the Upper case letters.

```bash
echo 'my 20 Birtday party @ BAY' |ggrep --color -P '(?xi) [[:lower:]]'
```

![Use of modifiers](/assets/images/Use of Modifier.png)

Example use of multi-lines, starting (`^`) with `Hello`:

```bash
echo 'Hello
Ojitha
How are you' | ggrep --color -Pz '(?xm) ^Hello .* '
```

![image-20220305154939892](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220305154939892.png)

In the above bash command, `-z` option allows the input data to be a sequence of lines.

See the modification above for single line modifier:

```bash
echo 'Hello
Ojitha
How are you' | ggrep --color -Pz '(?xs) ^Hello .* '
```

![image-20220305162321037](/assets/images/image-20220305162321037.png)

All the lines are selected because `\n` new line has been tread as another character in the single line(`s`) mode.

example of embedding white space

![Embedding whitespace](/assets/images/2022-03-04-RegEx on Mac/CleanShot 2023-05-13 at 22.14.36@2x.jpg)

In the above regex the whitespace to search is given as `\x20`.

![Multi-line as single line](/assets/images/2022-03-04-RegEx on Mac/CleanShot 2023-05-13 at 22.34.18@2x.jpg)

In the above regex, the new line is treated as `\n` because `s` treated the two lines as an one line.

if you use `m` instad of `s`:

![Search in the multi-lines](/assets/images/2022-03-04-RegEx on Mac/CleanShot 2023-05-13 at 22.35.38@2x.jpg)



### Bounding

Bonding regex does not match characters, but they specify where in the string the regex is to be matched.

| Bounding | Meaning                                 |
| -------- | --------------------------------------- |
| `^`      | Beginning                               |
| `$`      | End of the string or before `\n`        |
| `\A`     | begining of string                      |
| `\Z`     | end of string                           |
| `\b`     | begining or end of a word               |
| `\B`     | complement of begining or end of a word |

```bash
echo "the pen is my brother's" | ggrep -P --color '\bthe'
```

![use of bounding \a](/assets/images/image-20220305164948595.png)



As shown above, bro`the`r's is not selected because the word `the` is not the beginning of that word according to the bounding `\b`.

But, if you use bounding `\B`:

```bash
echo "the pen is my brother's" | ggrep -P --color '\Bthe'
```

<img src="/assets/images/image-20220305170512740.png" alt="image-20220305170512740" style="zoom:25%;" />

### alternation

Either match this or that: This has already been introduced in the beginning.

```bash
echo 'one and two are numbers' > test.txt
perl -pe 's/one|two/digit/' test.txt
```

```
digit and two are numbers
```

You can use alternation with bounds as follows:

```bash
echo 'I have borther
but I have no sisters
and any other ...' | ggrep -P --color '^I|the'
```

![bounds with alternation](/assets/images/image-20220305174654431.png)

If you use in the group

```bash
echo 'I have borther
but I have no sisters
and any other ...' | ggrep -P --color '^(I|and)'
```

![alternation with group](/assets/images/image-20220305233313620.png)

### Lazy Quantifiers

Not going to consume greedy but minimally.

| Quntifier | Description                            |
| --------- | -------------------------------------- |
| `*?`      | zero or more minimal                   |
| `+?`      | one or more minimal                    |
| `??`      | zero or one minimal                    |
| `{n}?`    | n times minimal (n is numeric)         |
| `{n,}?`   | n times or more minimal (n is numeric) |
| `{n,m}?`  | n through m minimal (n is numeric)     |

As shown in the following screenshot, the first regex greedly consume and match the first letter a to last letter t. In the second regex, it matches the first and up to the closest letter t. 

![Lazy select closest](/assets/images/2022-03-04-RegEx on Mac/CleanShot 2023-05-14 at 13.20.12@2x.jpg)

In the first grep command there is only one mactch. In the second, there are two maches: 'azy is import' and 'ant'.

For example see the difference in the outputs when you apply lazy quantifier:

![Lazy Quantifier example -1 ](/assets/images/2022-03-04-RegEx on Mac/CleanShot 2023-05-14 at 13.01.35@2x.jpg)

another example:

![Lazy Quantifier example -2](/assets/images/2022-03-04-RegEx on Mac/CleanShot 2023-05-14 at 13.07.11@2x-4033706.jpg)

### Possessive Quantifier

| Quantifier | Description             |
| ---------- | ----------------------- |
| `*+`       | zero or more possessive |
| `++`       | one or more possessive  |
| ?+         | zero or one possessive  |



## Capture

You can create capture groups using `()` as follows:

```
(.+)\.(png|gif)
```

The graphical representation[^5] is 

<img src="/assets/images/2022-03-04-RegEx on Mac/CapturGroupDiagram.png" alt="Capture Group Diagram" style="zoom:50%;" />

The target string match as follows:

<img src="/assets/images/2022-03-04-RegEx on Mac/CaptureGroupOutput.png" alt="Capture group output" style="zoom:50%;" />

For non-capture groups, use the `?:` as follows:

```
(.+)\.(?:png|gif)
```

The above regex matched the string but hasn't captured the second group



<img src="/assets/images/2022-03-04-RegEx on Mac/noncapture.png" alt="non capture" style="zoom:50%;" />

<img src="/assets/images/2022-03-04-RegEx on Mac/image-20221220190642877.png" alt="non capture group" style="zoom:50%;" />

you can reference the captured group later in the expression by the positional value

<img src="/assets/images/2022-03-04-RegEx on Mac/reference capture by position.png" alt="reference capture by its position" style="zoom:50%;" />

```bash
echo 'Hello
ball
narrow
mirrrror' | ggrep -P --color '(.)\1'
```

![Captureing](/assets/images/image-20220305224430826.png)

and visualisation[^3]![back reference](/assets/images/2022-03-04-RegEx on Mac/back_reference.svg)

```bash
echo 'Hello
memo
mississippi
rivier
lala
mama mia' | ggrep -P --color '(.)(.)\1\2'
```

![image-20220305225344362](/assets/images/image-20220305225344362.png)

This is same as above

```bash
echo 'Hello
memo
mississippi
rivier
lala
mama mia' | ggrep -P --color '(..)\1'
```

notice `(..)\1`.

Word followed the same word:

```bash
echo ' the song
I like ba baba black ship
wonder why' | ggrep -P --color '\b(\w+)\s\1'
```

![repeat the same word twice](/assets/images/image-20220305231626340.png)

Good practical example is HTML tag matching such as `<(\w+)>.*?<\/\1>` as shown in the visualisation:

<img src="/assets/images/2022-03-04-RegEx on Mac/htm_tag_matching.png" alt="image-20221221155344369" style="zoom:50%;" />

<img src="/assets/images/2022-03-04-RegEx on Mac/html tag validation.png" alt="html tag validation" style="zoom:50%;" />

You can name the capture group as follows. In the editor[^4], you can substitute the HTML `em` tag in markdown bold text. More similar to boundary tokens. 

<img src="/assets/images/2022-03-04-RegEx on Mac/named capture group.png" alt="image-20221221115615187" style="zoom:50%;" />

Using Sed

```bash
sed -E 's/([a-z]*) (\d*)/text: \1, digits: \2/'
```

```
text: hello, digits: 123
```

For example, non capture using perl:

![first group is non capture](/assets/images/2022-03-04-RegEx on Mac/CleanShot 2023-05-14 at 12.38.53@2x.jpg)

## Lookarounds

Lookarounds are regex expression conditions that are not captured as a part of the match.

|                | Postive                                                      | Negative                |
| -------------- | ------------------------------------------------------------ | ----------------------- |
| **Lookahead**  | *T* `(?=c)`: Capture *T* which statisfy the condition `c` **after** it. | Negation of *T* `(?!c)` |
| **Lookbehind** | `(?<=c)` *T*: Capture T which satisfy the condtion `c` **before** it. | Negation of`(?<!c)` *T* |

Examples:

|                     |                                                              |                                                              |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Postive Lookahead   | <img src="/assets/images/2022-03-04-RegEx on Mac/positivelookahead.png" alt="image-20221221163509915" style="zoom:100%;" /> | <img src="/assets/images/2022-03-04-RegEx on Mac/positivelookaheadexample.png" alt="image-20221221163752540" style="zoom:50%;" /> |
| Negative Lookahead  | ![image-20221221164838168](/assets/images/2022-03-04-RegEx on Mac/NegativeLookahead.png) | <img src="/assets/images/2022-03-04-RegEx on Mac/NegativeLookaheadExample.png" alt="image-20221221164510708" style="zoom:50%;" /> |
| Positive lookbehind | <img src="/assets/images/2022-03-04-RegEx on Mac/image-20221221191545911.png" alt="image-20221221191545911" style="zoom:50%;" /> |                                                              |
| Negative Lookbehind | <img src="/assets/images/2022-03-04-RegEx on Mac/image-20221221191659565.png" alt="image-20221221191659565" style="zoom:50%;" /> |                                                              |

> NOTE: Python support only fixed-width lookarounds. Indermine quantifiers such as `*,?,+` are not allowed.

Example of Postive Lookahead where I want to remote `date_parse` and `date_format` function from the following line:

```sql
GROUP BY "date_trunc"('day', "date_parse"("date_format"(convert_timezone('Australia/Sydney', table-a.field-x), '%d/%m/%Y %H:%i:%s'), '%d/%m/%Y %H:%i:%s'))
```
The regular expression to find is `"date_parse"\(.*(convert_timezone.*?\)).*(?=\))` and the replacement in VSCode, is `$1`. The Postive Lookahead has been used to avoid the selection of last `)`.


## VSCode

You can use VSCode to capture the CSV column and modify it. For example,

| Before                                                       | After                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![before run replace](/assets/images/2022-03-04-RegEx on Mac/image-20220820204018978.png) | ![after run replace](/assets/images/2022-03-04-RegEx on Mac/image-20220820204056997.png) |

Look

VSCode support the lookarounds as well.

<img src="/assets/images/2022-03-04-RegEx on Mac/vscode_lookarounds.png" alt="VSCode lookarounds" style="zoom:50%;" />

## Stream editor

By default, sed uses the BRE dialect. The `-E` option uses ERE. The `sed` command can modify a file inline using the `-i` option.

```bash
touch test.txt
echo 'Hi ojitha' > test.txt
sed -i '.bak' 's/ojitha/OJ/' test.txt
```

![image-20220304201448235](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220304201448235.png)

Text mactches using `&`:

```bash
echo 'Hello ojitha' | sed 's/oj.*/(&)/g'
```

```
Hello (ojitha)
```

## Merge multiple lines to group of lines
For example you want to couple two lines to one line int he following text:

```text
11111,
22222,
33333,
44444,
55555,
66666,
77777,
88888,
99999,
```
You have to follow 4 steps in the visual studio code
1. search regex: `(^(\d+,\n){2})` and replace regex: `--$1--` and the result is
```text
--11111,
22222,
----33333,
44444,
----55555,
66666,
----77777,
88888,
--99999,
```
In the above code, 2 lines are selected to compose as an one line.
2. search regx: `\n` and replace regex: empty and the result is
```text
--11111,22222,----33333,44444,----55555,66666,----77777,88888,--99999,
```
3. search regex: `----` and replace regex: `\n` and the retults is
```text
--11111,22222,
33333,44444,
55555,66666,
77777,88888,--99999,
```
4. search : `--` and replace: empty and the result is
```text
11111,22222,
33333,44444,
55555,66666,
77777,88888,99999,
```



[^1]: Download The Folger Shakespeare – [Complete Set](https://shakespeare.folger.edu/download-the-folger-shakespeare-complete-set/)
[^2]: [Debuggex visualizer](https://www.debuggex.com){:target="_blank"}
[^3]: [regexper visualizer](https://regexper.com/){:target="_blank"}
[^4]: [regex101 editor](https://regex101.com/){:target="_blank"}
[^5]: [jex visualizer](https://jex.im/regulex){:target="_blank"}
