---
layout: notes 
title: Programming
---

**Notes on Programming**

* TOC
{:toc}

Here the important commands and information collected while programming. 

## Java

### jShell

To clean the jShell, in the Mac: CMD+K.

To find the type of the variable

```java
public static <T> Class<?> typeOf(final T value) { 
  return value.getClass(); 
}
```



## Groovy

### XML
XML processing in the groovy, you need to read xml file to the variable in the groovy shell:

```groovy
	import groovy.xml.*
	clients = new XmlParser().parseText(new File('sampl.xml').text)
	
	//define namespace
	ns = new Namespace('http://www.my.net.au/uc/bulkexport/clientxml')
```

Say you need to display the Status of the first Clients/Client

```groovy
//	<Clients xmlns:'http://www.my.net.au/uc/bulkexport/clientxml'...>
// 		<Client>
//			<Status>Y</Status>
//		</Client>
//		...
//		...
//	</Clients>

println clients.Client[1][ns.Status][0].text()

```

Your output will be 'Y'.

```groovy
//	for all the clients
clients.Client.each { println it[ns.Status].text()}
```

### LDAP
Here the program to test the ldap in groovy. File name is hello.groovy:

```groovy
import org.apache.directory.groovyldap.LDAP
import org.apache.directory.groovyldap.SearchScope

LDAP con = LDAP.newInstance('ldap://10.25.192.242:389','cn=ojitha,OU=oj Users,DC=aus', 'password')
assert (con.exists('cn=ojitha,OU=oj Users,DC=aus')):" Not exists!"
```

run as: `groovy -cp  ~/applications/groovyldap/dist/groovy-ldap.jar hello.groovy`
The thridparty lib available at https://directory.apache.org/api/groovy-api/1-groovy-ldap-download.html.

## Typescript

I use vscode for Typescript development. Install vscode:

```bash
brew install --cask visual-studio-code
```

Any time you can uninstall vscode as follows:

```bash
brew uninstall --cask visual-studio-code
rm -rf $HOME/Library/Application Support/Code
rm -rf $HOME/.vscode/
```

First install nodejs

```bash
brew install node
```

Check node is installed:

```bash
node --version
```

Follow the [TypeScript tutorial in Visual Studio Code](https://code.visualstudio.com/docs/typescript/typescript-tutorial) for more information.

To install typescript

```bash
npm install -g typescript
```

check

```bash
tsc --version
```

To install `express`:

```bash
npm i express
```

To intsall the express

```bash
npm i -D @types/express
```

My `tsconfig.json` is:

```bash
{
    "compilerOptions": {
        "target": "ES6",
        "module": "CommonJS",
        "outDir": "out",
        "sourceMap": true,
        "esModuleInterop": true,
        "allowSyntheticDefaultImports": true
    }
}
```

To run the express server:

```bash
px ts-node app.ts
```

The app.ts is:

```typescript
import express from "express";
const app = express();

app.get('/', (req,res) => {
    res.status(200);
    res.send("Hello")
})

app.listen(3000)
```

To check type `localhost:3000` in the browser.

### Using Yarn

Install yarn:

```bash
npm install --global yarn
```

check with

```bash
yarn --version
```

Install typescript:

```bash
yarn add typescript --dev
```

to check

```bash
yarn tsc --version
```

Install express

```bash
yarn add express
```

## Scala Notebooks

You can create Scala notebook using docker:

```bash
docker run --rm -it \
    -p 127.0.0.1:8192:8192 \
    -p 127.0.0.1:4040-4050:4040-4050 \
    -v `pwd`/config.yml:/opt/config/config.yml \
    -v `pwd`/notebooks:/opt/notebooks/ \
    -v $HOME/.aws:/home/polly/.aws polynote/polynote:latest \
    --config /opt/config/config.yml
```

You have to have the following `config.yml` file in your directory

```yaml
storage:
  dir: /opt/notebooks
  mounts:
    examples:
      dir: examples
```

## Haskell

You can write the basic recursive product of list elements as follows:

```haskell
myproduct [] = 1
myproduct (n:ns) = n * myproduct ns
```

This can be replace using `foldr` as follows:

```haskell
myproduct n = foldr (*) 1 n
```




