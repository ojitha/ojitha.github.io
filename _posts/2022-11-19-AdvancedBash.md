---
layout: post
title:  Notes on Introduction to Advanced Bash Usage
date:   2022-11-19
categories: [Bash]
---

While I am going through the following, the [youtube talk](https://www.youtube.com/watch?v=BJ0uHhBkzOQ) and it's associated [presentation](http://talk.jpnc.info/bash_lfnw_2017.pdf), my hand-ons recorded here. You can also refer to the [Bash Ref Manual](https://www.gnu.org/software/bash/manual/html_node/index.html#SEC_Contents) for more information.

<!--more-->

------

* TOC
{:toc}
------

## Parameters
There are **Positional parameters** such as `$1`, `$2` and so on. if you use above 9, you must use braces such as `${11}`. You can find about **special parameters** from the [documentation](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html).



```bash
set -- first second
echo $*
echo $2 and $1
```

    first second
    second and first


If the command returns 0 when successful, otherwise number 1 -255. Use the `$?` to capture the return value. Many programs signal different types of failure with different return values.


```bash
whoami
echo $?
```

    ojitha
    0


Use special variables such as `$*`, `$@` and so on has been explained in the following code snippet:


```bash
bash <<'EOF' -s -- Ojitha "How are you" 

echo "$2 $1 ?"
echo arguement with *: $*
echo arguement with @: $@
echo number of arguments $#

j=0
for i in $@
do
  echo "$j element: $i"
  (( j = j+1 ))
done

EOF

```

    How are you Ojitha ?
    arguement with *: Ojitha How are you
    arguement with @: Ojitha How are you
    number of arguments 2
    0 element: Ojitha
    1 element: How
    2 element: are
    3 element: you



```bash
function login(){
    if [[ ${@} =~ "-user" && ${@} =~ "-pass" ]]; then
        echo "login as $2"
    else
        echo "Bad Syntax. Usage: -user [username] -pass [password] required"
    fi
}

login -user "Ojitha" -pass "two"
login -pass "two" -user "one" 
login "one" "two"
```

    login as Ojitha
    login as two
    Bad Syntax. Usage: -user [username] -pass [password] required


There are compound commands
- iterations: such as `while`, `until`, `for`, and `select`.
- conditions: `if` and `case`
- command groups: `(list)` and {list;}`


```bash
i=0
while [ $i -lt 3 ]
do
  echo i: $i
  ((i=i+1))
done

```

    i: 0
    i: 1
    i: 2


Another example

The `until` is the opposite of the `while`.


```bash
seq 1 3 > a
while read e; do
    printf '%d\n' $(( e ** 2 ))
done < a    
```

    1
    4
    9



```bash
i=0

until [ $i -gt 3 ]
do
  echo i: $i
  ((i=i+1))
done

```

    i: 0
    i: 1
    i: 2
    i: 3


Following is C lang style For loop


```bash
for (( i=0 ; i < 3 ; i++ ))
do
    echo $i
done    
```

    0
    1
    2


here the iterator


```bash
for i in $(seq 1 3) ; do echo $i; done
```

    1
    2
    3


or


```bash
seq 1 3 | while read line; do  printf '%d\n' $((line)); done
```

    1
    2
    3


as well as


```bash
for i in a b "c and d"
do
 echo "=> $i"
done
```

    => a
    => b
    => c and d


or


```bash
for i in {0..8..2}
do
    echo $i
done    
```

    0
    2
    4
    6
    8


The `select` statement example is hard to show in the notebook because it is interactive.

```bash 
select choice in one two "no choice"
do
    echo $choice
done    
```

will give you to select the choice

```
1) one
2) two
3) no choice
#?
```

You can select 1, 2 or 3 from the stdin.

## Expressions

The `[]` matches any one of the enclosed characters. The new way is `[[...]]`, which returns a status of 0 or 1 depending on the evaluation of the conditional expression.


```bash
s1="ojitha"
s2=""
[[ -n $s1 ]]
echo "s1: $?"

# test string is non-empty
[[ -n $s2 ]]
echo "s2: $?"
```

    s1: 0
    s2: 1


To test string is empty:


```bash
s2=""
[[ -z $s2 ]]
echo "s2: $?"
```

    s2: 0


test the strings are the same


```bash
s1="ojitha"
s2="hewa"

# matched
[[ 'Hello' == 'Hello' ]]
echo $?

# unmatched
[[ 'Hello' == 'ojitha' ]]
echo $?
```

    0
    1


To match the regular expression.


```bash
set -- "the pen is my brother's" # set $1 to sample string

RE='^the' # regex
[[ $1 =~ $RE ]]
echo $?
```

    0


or


```bash
a=ojitha
[[ $a == +(oj|aj)itha ]]
echo $?
```

    0


The return value `0` is a successful match.

Expression | Description
----|----
`[[ -e file ]]` | file exists
`[[ -f file ]]` | file is a regular file
`[[ -d file ]]` | file is a directory
`[[ -t fd ]]` | fd idopen and refer to terminal

In the conditional statement:


```bash
if [[ 'Hello' == 'oj' ]] then 
    echo 'true' 
else 
    echo "false" 
fi
```

    false


Use with regex


```bash
a=ojitha
if [[ $a == +(oj|aj)itha ]]; then echo yes; else echo no; fi
```

    yes


## Pattern Matching

The `case` is a great way to match patterns. The pipe character between two patterns entails a match on condition `OR`.


```bash
case "ojitha Hello" in
    o) 
        echo 'o'
        ;;
    o*) 
        echo 'o*'
        ;;
    *) 
        echo 'nope'
        ;;
esac    
```

    o*


## Command Groups
Evaluate the list of commands in a subshell using `(...)`.
>NOTE: To evaluate a list of commands in the current shell, use `{ list; }`. Here the spaces next to the curly braces and trailing semicolon are compulsory.


```bash
a="Ojitha"
( # subshell
    # inside    
    a="Disinee" 
    echo "In the subshell $a" 
)
# outside
echo "Outside the subshell $a"

```

    In the subshell Disinee
    Outside the subshell Ojitha


If you use the group command 


```bash
a="Ojitha"
{ # group command
    # inside    
    a="Disinee" 
    echo "In the subshell $a" 
}
# outside
echo "Outside the subshell $a"
```

    In the subshell Disinee
    Outside the subshell Disinee



```bash
echo b; echo a | sort
echo ------ in the subshell ---
(echo b; echo a) | sort # subshell
```

    b
    a
    ------ in the subshell ---
    a
    b


Another use of parenthesis:


```bash
echo I am $(whoami)
echo I am `(whoami)` #same as above
```

    I am ojitha
    I am ojitha


## Redirection

If not specified, `fd 1` (`STDOUT`) is assumed when redirecting output. Alternative file descriptors may be specified by prepending the `fd number`. To direct error to file: `2>file`. To redirect to a file descriptor, append `&` and the `fd number`: `2>&1` to redirect `STDERR` to the current target for `STDOUT`.

In the above, `$(whoami)` is a **command substitution**. The **Process substitution** feeds the output of a process (or processes) into the `stdin` of another process. For example, I want to compare two directories:

First, create directories and files inside the directories.

```bash
mkdir first && touch first/f1.txt first/f2.txt first/common.txt
mkdir second && touch second/s1.txt second/s2.txt  second/common.txt
```

to compare

```bash
diff <(ls first) <(ls second)
```

output

```
2,3c2,3
< f1.txt
< f2.txt
---
> s1.txt
> s2.txt
```

NOTE: The file common.txt is not visible because that exists in both of the directories.

## Parameter Expansion
Find the [documentation](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html).

Following code, if the `param` is empty, it returns the default (in this case `$(whoami)`) value but is not set to the variable.


```bash
who=""
echo who without default: $who
echo who with default: ${who:-$(whoami)}
echo who without default: $who

```

    who without default:
    who with default: ojitha
    who without default:


if you want to set the default to the `who` variable (use `:=`).
> Positional parameters and special parameters may not be assigned in this way.


```bash
who=""
echo who without default: $who
echo who with default: ${who:=$(whoami)}
echo who without default: $who
```

    who without default:
    who with default: ojitha
    who without default: ojitha

### Alternate


```bash
who=ojitha
echo ${who+aaa}
echo $who
```

    aaa
    ojitha


as well as


```bash
who=ojitha
echo ${who:+aaa}
echo $who
```

    aaa
    ojitha


If a parameter is null or unset, the expansion of the word (or a message to that effect if the word is not present) is written to the standard error and the shell, if it is not interactive, exits. Otherwise, the value of the parameter is substituted.

```bash
who=
echo ${who:?variable is null}
```

### Substring


```bash
who=ojitha
echo ${who:2}
echo ${who:2,3}
echo ${who#oj} # left edge
echo ${who%ha} # right edge
greedy=ojitha:hewa:kuma
echo ${greedy##*:} # greedy
```

    itha
    tha
    itha
    ojit
    kuma


From right to left


```bash
who=ojitha
echo ${who:(-1)} 
```

    a

### Expand to length


```bash
who=ojitha
echo length ${#who}
# indirect expansion
${!who}

```

    length 6

### Indirect expansion


```bash
surname=lastname; lastname=HEWA
echo ${!surname}
```

    HEWA

### List name-matching prefix


```bash
v1=""
v2=""
v3=""
v4=""

echo "${!v@}"
echo ${!v*} 
```

    v1 v2 v3 v4
    v1 v2 v3 v4


List the keys in an array `${!arr[*]}` or `${!arr[@]}`


```bash
# Declare an associative array
declare -A arr

arr[fruit]=Mango
arr[bird]=Cockatail
arr[flower]=Rose
arr[animal]=Tiger

for i in ${!arr[*]}
do
    echo $i
done
```

    flower
    fruit
    animal
    bird


### Pattern Substituion


```bash
who=abba
echo ${who/b/x}
# greedy
echo ${who//b/x}

```

    axba
    axxa


substitute at left edge


```bash
who=aabb
echo ${who/#aa/12}

```

    12bb


substitute at the right edge


```bash
who=aabb
echo ${who/%bb/12}
```

    aa12


## Arrays

make arrays


```bash
# declare the array
a=( 1 4 3 ojitha "Hello World" )
declare -p a
# add to array
a+=("Hewa")
declare -p a
echo "second element: ${a[1]}"
# print array indexes
echo Array indexes ${!a[@]}
```

    declare -a a=([0]="1" [1]="4" [2]="3" [3]="ojitha" [4]="Hello World")
    declare -a a=([0]="1" [1]="4" [2]="3" [3]="ojitha" [4]="Hello World" [5]="Hewa")
    second element: 4
    Array indexes 0 1 2 3 4 5


substitute `_` for all the spaces


```bash
# declare the array
a=( "This is an example of substituting underscore for spaces" "Hello World" )
a=( "${a[@]// /_}" )
declare -p a
```

    declare -a a=([0]="This_is_an_example_of_substituting_underscore_for_spaces" [1]="Hello_World")


Sub arraying


```bash
# declare the array
a=( 1 2 3 ojitha "Hello World" )
a=( ${a[@]:2:3} )
declare -p a
```

    declare -a a=([0]="3" [1]="ojitha" [2]="Hello" [3]="World")


Passing to function


```bash
#variable
a=(1 2 3 4)

function display(){
    arr=($*)
    for i in ${arr[@]}
    do 
        echo $i 
    done
}
display ${a[@]}
```

    1
    2
    3
    4


## Arithmatics


```bash
((1==1)); echo "1==1 $?"

((1!=1)); echo "1!=1 $?"

((1<2)); echo "1<2 $?"

((1>2)); echo "1>2 $?"
# adding
echo 1+1 = $((1+1))

# counter
count=1
# after evaluate
echo "count=1, count++ after evaluation is $((count++))"
# before evaluate
count=1
echo "count=1, ++count before evaluation is $((++count))"
```

    1==1 0
    1!=1 1
    1<2 0
    1>2 1
    1+1 = 2
    count=1, count++ after evaluation is 1
    count=1, ++count before evaulation is 2



```bash
# counter
count=5
# after evaluate
echo "count=5, count++ after evaluation is $((count--))"
# before evaluate
count=5
echo "count=5, ++count before evaluation is $((--count))"
```

    count=5, count++ after evaluation is 5
    count=5, ++count before evaluation is 4


## Brace Expansion
Generate arbitrary words


```bash
echo walk{,e{d,s},ing,ful{l,ly}}
```

    walk walked walkes walking walkfull walkfully



```bash
echo {1..5}{0,5}%
```

    10% 15% 20% 25% 30% 35% 40% 45% 50% 55%


## Session Portability
Import elements from the current session directly into a new local or remote session.
- `p` for parameters
- `f` for functions



```bash
#variable
who=ojitha

function hello(){
    echo Hello $1
}
# pass a variable and the function to a new shell
bash -c "$(declare -p who; declare -f hello); hello $who "
```

    Hello ojitha


You can pass the session to remote

```bash
ssh remote_host "$(declare -p parameter; declare -f func); your code "
```

