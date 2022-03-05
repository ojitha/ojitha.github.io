---
layout: post
title:  RegEx on bash shell
date:   2022-03-04
categories: [RegEx]
---

How to use RegEx in MacOs. One good use of RegEx is text processing which may specially help you to find text files where regular expression has been met. 

<!--more-->

For the MacOs, the default `grep` (FreeBSD version) is very limited. You cannot run all the bash command express in theis blog post using MacOs standard `grep` command. There for install the grep from the home-brew:

```bash
brew install grep
```

and use the command `ggrep` instead of `grep`. For the help

```bash
ggrep --help
```



For testing purpose downloand the texts of Shakespeare[^1] as a zip file. After you extract the zip file.



## Find in the file

To find the word in the TXT file:

```bash
egrep --color the hamlet_TXT_FolgerShakespeare.txt
```

This will show you something similar to the following output.

![image-20220304192546992](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220304192546992.png)

You can see the `the` is hilighted.

## Fine in the folder

Locate the file in the file system where every file show the lines of the that contains text `henry`.

```bash
find . -exec egrep -H 'Henry IV' {} \; 2>/dev/null
```

![List the file which has the seach](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220304195622052.png)

For example, case sensitive match:

```bash
egrep --color 'the|is' hamlet_TXT_FolgerShakespeare.txt
```

![multiple words in the search](/assets/images/multiple words in the search.png)



for case insensitive match, use the `-i` option

```bash
egrep --color -i 'england' hamlet_TXT_FolgerShakespeare.txt
```

![case-intensive-search](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/case-intensive-search.jpg)

To implements tha Enhanced Regular Expressions (ERE) dialect use `grep -E`(`grep -P` say PCRE, for MacOS use the `perl` in the terminal) and `egrep` is the shorten form of that. Only for `grep` you have to escape te `|`.

If you want collection of text to match, you can use either `|` or another text file with the words. 

```
echo 'england' >>  search_keywords.txt
echo 'ambassadors' >>  search_keywords.txt
echo 'gives' >> search_keywords.txt
```

Search command is

```bash
egrep --color -f search_keywords.txt hamlet_TXT_FolgerShakespeare.txt
```

To show the lines do not mach (negative of the above), use `v` option:

```bash
egrep --color -v -i -f search_keywords.txt hamlet_TXT_FolgerShakespeare.txt
```

## Character Class

You can create complex search key expression using class of characters. To create character class, use the `[]` in the search. For example

```bash
egrep --color -i '[abc]' hamlet_TXT_FolgerShakespeare.txt
```

![Character class example](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220304230229838.png)

For the complement of the above is `[^abc]`.

![complement of the character class](/assets/images/complement of the character class.png)

for example.

### Generic Character classes

| Generic | Class          |
| ------- | -------------- |
| `\d`    | `[0-9]`        |
| \D      | `[^0-9]`       |
| `\w`    | `[a-zA-Z0-9]`  |
| `\W`    | `[^a-zA-Z0-9]` |
| `\s`    | `[\t\n\r\f]`   |
| `\S`    | `[^\t\n\r\f]`  |

For exmple

```bash
echo 'Hello Ojitha 1234' | grep --color -i '\D'
```

![Generic character class example](/assets/images/Generic character class example.png)

Only the words are selected.

### Posix Character Classes



This has been created to simplify the character classes. The syntax is `[[:CLASS:]]`. Use the `^` as the complement `[[:^CLASS:]]`.

> Only perl regex support the following classes.
>
> Use `perl` in the MacOS terminal

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



## Quantifiers

In the regex expression we want to quantify how many characters we want to mach for exsample.

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

will give you the 

![Use_of_quantifier](/assets/images/Use_of_quantifier.png)

In the Perl regex

```bash
echo 'my 20 Birtday party @ Bay' |grep --color -E '[[:upper:]]{1}'
```

output is 

![Use Quntifiers with Posix classes](/assets/images/Use Quntifiers with Posix classes.png)

### Inline Modifiers

| Modifier | Description                                                  |
| -------- | ------------------------------------------------------------ |
| `(?x)`   | Embed whitespace                                             |
| `(?i)`   | Case insensitive match                                       |
| `(?s)`   | Single line mode                                             |
| `(?m)`   | Multi line mode, here `\A` start if the string and `\Z` end of the string. |

For example, although I specify the Posix class `lower` for lower letters, when you specify modifier `(?xi)` it shows all the word ignoring the Upper case letters.

```bash
echo 'my 20 Birtday party @ BAY' |ggrep --color -P '(?xi) [[:lower:]]'
```

![Use of modifiers](/assets/images/Use of Modifier.png)

Example use of multi-lines

```bash
echo 'Hello
Ojitha
How are you' | ggrep --color -Pz '(?xm) ^Hello .* '
```

![image-20220305154939892](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220305154939892.png)



## Stream editor

The `sed` commmand is capable to modify a file inline using `-i` option.

```bash
touch test.txt
echo 'Hi ojitha' > test.txt
sed -i '.bak' 's/ojitha/OJ/' test.txt
```

![image-20220304201448235](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/image-20220304201448235.png)







[^1]: Download The Folger Shakespeare – [Complete Set](https://shakespeare.folger.edu/download-the-folger-shakespeare-complete-set/)