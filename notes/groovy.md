--- 
layout: notes 
title: Groovy
---

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
