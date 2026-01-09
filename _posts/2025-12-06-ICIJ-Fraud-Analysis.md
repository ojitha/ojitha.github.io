---
layout: post
title:  ICIJ Fraud Analysis
date:   2025-12-06
categories: [Spark, Scala]
mermaid: true
maths: true
typora-root-url: /Users/ojitha/GitHub/ojitha.github.io
typora-copy-images-to: ../../blog/assets/images/${filename}
excerpt: '<div class="image-text-container"><div class="image-column"><img src="https://raw.githubusercontent.com/ojitha/blog/master/assets/images/2025-12-06-ICIJ-Fraud-Analysis/icij.png" alt="Scala Functors" width="150" height="150" /></div><div class="text-column">Uncover the hidden wealth of nations by analysing the ICIJ Offshore Leaks Database using Apache Spark and Scala. This technical guide demonstrates how to process more than 810,000 offshore entities identified in the Panama and Pandora Papers to detect financial fraud. We walk through the process of defining Schema Case Classes for nodes and relationships, loading CSV data into Spark Datasets, and executing complex multi-hop graph joins. Learn to reconstruct fragmented data into complete entity profiles, map beneficial ownership networks, and identify suspicious shell companies sharing registered addresses. Master graph database analysis techniques to expose global corruption and money laundering structures effectively.</div></div>'
---

<!--more-->

------

* TOC
{:toc}
------

## Introduction

ICIJ stands for the International Consortium of Investigative Journalists. It is a non-profit news organisation based in Washington, D.C., that operates as a global network of reporters and media organisations. They are best known for coordinating massive, cross-border investigations into corruption, money laundering, and tax abuse.

### What is in the database?

It is not just one leak; it is a "master list" combined from five different massive investigations. It contains data on more than **810,000 offshore companies**, trusts, and foundations from:

-   **Pandora Papers (2021):** The most recent major addition, exposing 35 world leaders.
-   **Paradise Papers (2017):** Focused heavily on multinational corporations (like Apple and Nike) and the ultra-wealthy.
-   **Bahamas Leaks (2016):** A leak from the corporate registry of the Bahamas.
-   **Panama Papers (2016):** The famous leak from the law firm Mossack Fonseca.
-   **Offshore Leaks (2013):** The original investigation that started the project.

### What does it actually show?

The database does **not** show bank balances, emails, or money transfers. It shows **relationships**.

-   **Beneficial Owners:** The actual human beings who own the companies (often hidden behind nominees).
-   **Intermediaries:** The lawyers, banks, and accountants who helped set up the structures.
-   **Addresses:** Physical locations linked to the owners. (You can literally search your own city to see who in your neighbourhood has an offshore account.)

The ICIJ Offshore Leaks Database is a free, publicly accessible search engine that tracks the ownership of anonymous shell companies. The ICIJ Offshore Leaks Database is not just a spreadsheet; it is a Graph Database exported into CSV format. To understand the hidden wealth of nations, you must understand how to reconstruct these fragments. The data is split into two primary concepts: Nodes (actors) and Relationships (actions).

-   **Nodes:** Every row represents a distinct object. These are not all companies; they are categorised into four different roles. Understanding this distribution is critical for filtering your analysis.
    -   `EntityNode`: The offshore companies, trusts, or foundations created in tax havens.
    -   `OfficerNode`: The people or companies playing a role (Director, Shareholder, Beneficiary).
    -   `Intermediary`: The lawyers, banks, or accountants (middle-men) who facilitate the setup.
    -   `AddressNode`: Physical locations linked to the other nodes.
    -   `OtherNode`
-   **Edges:** `Relationship`: The relationships.csv file is the bridge. It contains no names, only IDs. It connects a Start Node to an End Node via a specific Relationship Type. Without this file, the nodes are isolated islands of data.

![Nodes Relationships](https://raw.githubusercontent.com/ojitha/blog/master/assets/images/2025-12-06-ICIJ-Fraud-Analysis/nodes-relationships.png)





```scala
// create a case class for the `nodes-entities.csv`
/**
  * Represents an entity from the nodes-entities.csv file.
  *
  * @param node_id The unique identifier for the node.
  * @param name The name of the entity.
  * @param original_name The original name of the entity, if different.
  * @param former_name A previous name for the entity.
  * @param jurisdiction The legal jurisdiction of the entity.
  * @param jurisdiction_description A description of the jurisdiction.
  * @param company_type The type of company (e.g., Limited, Corp).
  * @param address The registered address of the entity.
  * @param incorporation_date The date the entity was incorporated.
  * @param inactivation_date The date the entity was inactivated.
  * @param struck_off_date The date the entity was struck off the register.
  * @param status The current status of the entity.
  * @param service_provider The service provider associated with the entity.
  * @param ibc_ruc The IBC or RUC number.
  * @param country_codes The country codes associated with the entity.
  * @param countries The countries associated with the entity.
  * @param sourceID The ID of the data source.
  * @param valid_until The date until which the data is considered valid.
  * @param note Any additional notes.
  */
case class EntityNode(
    node_id: String,
    name: Option[String],
    original_name: Option[String],
    former_name: Option[String],
    jurisdiction: Option[String],
    jurisdiction_description: Option[String],
    company_type: Option[String],
    address: Option[String],
    incorporation_date: Option[String],
    inactivation_date: Option[String],
    struck_off_date: Option[String],
    status: Option[String],
    service_provider: Option[String],
    ibcRuc: Option[String],
    country_codes: Option[String],
    countries: Option[String],
    sourceID: Option[String],
    valid_until: Option[String],
    note: Option[String]
)

```




    defined class EntityNode




```scala
// Read CSV and convert to Dataset
val entityNodeDS = spark.read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv(s"${filePath}full-oldb.LATEST/nodes-entities.csv")
  .as[EntityNode]

// Example queries
entityNodeDS.show(false)
```













    +--------+--------------------------------------------+----------------------------------------------------------+------------------------+------------+------------------------+------------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+------------------+-----------------+---------------+---------+-------------+----------------+------+-------------+-----------+-------------+----------------------------------------------+----+
    |node_id |name                                        |original_name                                             |former_name             |jurisdiction|jurisdiction_description|company_type|address                                                                                                                                      |internal_id|incorporation_date|inactivation_date|struck_off_date|dorm_date|status       |service_provider|ibcRUC|country_codes|countries  |sourceID     |valid_until                                   |note|
    +--------+--------------------------------------------+----------------------------------------------------------+------------------------+------------+------------------------+------------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+------------------+-----------------+---------------+---------+-------------+----------------+------+-------------+-----------+-------------+----------------------------------------------+----+
    |10000001|TIANSHENG INDUSTRY AND TRADING CO., LTD.    |TIANSHENG INDUSTRY AND TRADING CO., LTD.                  |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1001256    |23-MAR-2006       |18-FEB-2013      |15-FEB-2013    |NULL     |Defaulted    |Mossack Fonseca |25221 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000002|NINGBO SUNRISE ENTERPRISES UNITED CO., LTD. |NINGBO SUNRISE ENTERPRISES UNITED CO., LTD.               |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1001263    |27-MAR-2006       |27-FEB-2014      |15-FEB-2014    |NULL     |Defaulted    |Mossack Fonseca |25249 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000003|HOTFOCUS CO., LTD.                          |HOTFOCUS CO., LTD.                                        |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000896    |10-JAN-2006       |15-FEB-2012      |15-FEB-2012    |NULL     |Defaulted    |Mossack Fonseca |24138 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000004|SKY-BLUE GIFTS & TOYS CO., LTD.             |SKY-BLUE GIFTS & TOYS CO., LTD.                           |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000914    |06-JAN-2006       |16-FEB-2009      |15-FEB-2009    |NULL     |Defaulted    |Mossack Fonseca |24012 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000005|FORTUNEMAKER INVESTMENTS CORPORATION        |FORTUNEMAKER INVESTMENTS CORPORATION                      |NULL                    |SAM         |Samoa                   |NULL        |LOYAL PORT LIMITED 8/F; CRAWFORD TOWER 99 JERVOIS STREET SHEUNG WAN; HONG KONG                                                               |1001266    |19-APR-2006       |15-MAY-2009      |15-FEB-2008    |NULL     |Changed agent|Mossack Fonseca |R25638|HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000006|8808 HOLDING LIMITED                        |8808 HOLDING LIMITED (EX-DIAMOND LIMITED)                 |DIAMOND LIMITED         |SAM         |Samoa                   |NULL        |TWC MANAGEMENT LIMITED SUITE D; 19/F RITZ PLAZA122 AUSTIN ROADTSIM SHA TSUI; KOWLOON HONG KONG                                               |1000916    |05-JAN-2006       |NULL             |NULL           |NULL     |Active       |Mossack Fonseca |23835 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000007|KENT DEVELOPMENT LIMITED                    |KENT DEVELOPMENT LIMITED                                  |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000022    |26-JAN-2004       |03-MAY-2006      |15-FEB-2006    |NULL     |Defaulted    |Mossack Fonseca |15757 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000008|BONUS TRADE LIMITED                         |BONUS TRADE LIMITED                                       |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000049    |13-FEB-2004       |16-FEB-2009      |15-FEB-2009    |NULL     |Defaulted    |Mossack Fonseca |15910 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000009|AMARANDAN LTD.                              |AMARANDAN LTD.                                            |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000024    |26-JAN-2004       |03-MAY-2006      |15-FEB-2006    |NULL     |Defaulted    |Mossack Fonseca |15759 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000010|NEW IDEA LIMITED                            |NEW IDEA LIMITED                                          |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000079    |30-MAR-2004       |27-FEB-2007      |15-FEB-2007    |NULL     |Defaulted    |Mossack Fonseca |16462 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000011|HUGH POWER LIMITED                          |HUGH POWER LIMITED                                        |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000081    |30-MAR-2004       |02-JAN-2008      |15-FEB-2008    |NULL     |Defaulted    |Mossack Fonseca |16464 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000012|ULTIMATE GROUP LIMITED                      |ULTIMATE GROUP LIMITED                                    |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000095    |05-APR-2004       |NULL             |NULL           |NULL     |Active       |Mossack Fonseca |16573 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000013|VICTORY GROUP LIMITED                       |VICTORY GROUP LIMITED                                     |NULL                    |SAM         |Samoa                   |NULL        |GO SHINE MANAGEMENT CO.; LTD. ROOM B; 5F.; NO. 92; SEC. 1NANJING E. RD.; JHONGSHAN DISTRICT; TAIPEI CITY 104; TAIPEI TAIWAN                  |1000077    |30-MAR-2004       |20-FEB-2010      |15-FEB-2010    |NULL     |Defaulted    |Mossack Fonseca |16460 |TWN          |Taiwan     |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000014|CHARTER MARK LIMITED                        |CHARTER MARK LIMITED                                      |NULL                    |SAM         |Samoa                   |NULL        |AFOR LAW FIRM, SICHUAN CHENGDU SHUANGNAN PIK WAN ROAD NO. 60 ATTACHED CHENGDU PEOPLE'S REPUBLIC OF CHINA                                     |1000052    |13-FEB-2004       |17-FEB-2011      |15-FEB-2011    |NULL     |Defaulted    |Mossack Fonseca |15913 |CHN          |China      |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000015|Wide International Trading Co., Ltd.        |Wide International Trading Co., Ltd.                      |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000935    |06-JAN-2006       |NULL             |NULL           |NULL     |Active       |Mossack Fonseca |24014 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000019|HTSS ET CAPITAL LIMITED                     |HTSS ET CAPITAL LIMITED                                   |NULL                    |SAM         |Samoa                   |NULL        |TWC MANAGEMENT LIMITED SUITE D; 19/F RITZ PLAZA122 AUSTIN ROADTSIM SHA TSUI; KOWLOON HONG KONG                                               |1001721    |21-AUG-2006       |19-FEB-2015      |15-FEB-2015    |NULL     |Defaulted    |Mossack Fonseca |27502 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000020|JIE LUN INVESTMENT LIMITED                  |JIE LUN INVESTMENT LIMITED                                |NULL                    |SAM         |Samoa                   |NULL        |MEI SERVICES LIMITED ROOM E; 6TH FLOOR; EASTERN COMMERCIAL CENTRE; 395-399 HENNESSY ROAD HONG KONG                                           |1001323    |10-APR-2006       |NULL             |NULL           |NULL     |Active       |Mossack Fonseca |25475 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000021|FORTUNE PALACE LIMITED                      |FORTUNE PALACE LIMITED                                    |NULL                    |SAM         |Samoa                   |NULL        |AFOR LAW FIRM, SICHUAN CHENGDU SHUANGNAN PIK WAN ROAD NO. 60 ATTACHED CHENGDU PEOPLE'S REPUBLIC OF CHINA                                     |1000087    |29-MAR-2004       |03-MAY-2006      |15-FEB-2006    |NULL     |Defaulted    |Mossack Fonseca |16408 |CHN          |China      |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000024|LAKE STREET INVESTMENTS LTD.                |LAKE STREET INVESTMENTS LTD. (EX-QUEENSLAND OVERSEAS LTD.)|QUEENSLAND OVERSEAS LTD.|SAM         |Samoa                   |NULL        |FCI LTD. ATT.: MR. DAVID RISBEY POSTFACH 24 7270 DAVOS PLATZ SWITZERLAND*S.I.*                                                               |1000054    |06-FEB-2004       |01-FEB-2005      |15-FEB-2006    |NULL     |Inactivated  |Mossack Fonseca |15858 |CHE          |Switzerland|Panama Papers|The Panama Papers data is current through 2015|NULL|
    |10000016|NINGBO RAPID INTERNATIONAL TRADING CO., LTD.|NINGBO RAPID INTERNATIONAL TRADING CO., LTD.              |NULL                    |SAM         |Samoa                   |NULL        |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000944    |12-JAN-2006       |27-FEB-2014      |15-FEB-2014    |NULL     |Defaulted    |Mossack Fonseca |24181 |HKG          |Hong Kong  |Panama Papers|The Panama Papers data is current through 2015|NULL|
    +--------+--------------------------------------------+----------------------------------------------------------+------------------------+------------+------------------------+------------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+------------------+-----------------+---------------+---------+-------------+----------------+------+-------------+-----------+-------------+----------------------------------------------+----+
    only showing top 20 rows
    





    entityNodeDS: Dataset[EntityNode] = [node_id: string, name: string ... 19 more fields]




```scala
// create a case class for the `nodes-intermediaries.csv`
/**
  * Represents an intermediary from the nodes-intermediaries.csv file.
  *
  * @param node_id The unique identifier for the node.
  * @param name The name of the intermediary.
  * @param status The current status of the intermediary.
  * @param internal_id An internal identifier used by the source.
  * @param address The address of the intermediary.
  * @param countries The countries associated with the intermediary.
  * @param country_codes The country codes associated with the intermediary.
  * @param sourceID The ID of the data source.
  * @param valid_until The date until which the data is considered valid.
  * @param note Any additional notes.
  */
case class Intermediary(
    node_id: String,
    name: String,
    status: Option[String],
    internal_id: Option[String],
    address: Option[String],
    countries: Option[String],
    country_codes: Option[String],
    sourceID: String,
    valid_until: String,
    note: Option[String]
)
```




    defined class Intermediary




```scala
// Read CSV and convert to Dataset
val intermediaryDS = spark.read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv(s"${filePath}full-oldb.LATEST/nodes-intermediaries.csv")
  .as[Intermediary]

// Example queries
intermediaryDS.show(false)
```













    +--------+-----------------------------------+----------------------+-----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+---------------------+-------------+-------------+-----------------------------------------------+----+
    |node_id |name                               |status                |internal_id|address                                                                                                                                                    |countries            |country_codes|sourceID     |valid_until                                    |note|
    +--------+-----------------------------------+----------------------+-----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+---------------------+-------------+-------------+-----------------------------------------------+----+
    |11000001|MICHAEL PAPAGEORGE, MR.            |ACTIVE                |10001      |MICHAEL PAPAGEORGE; MR. 106 NICHOLSON STREET BROOKLYN PRETORIA 0002; GAUTENG (PWV) SOUTH AFRICA                                                            |South Africa         |ZAF          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000002|CORFIDUCIA ANSTALT                 |ACTIVE                |10004      |NULL                                                                                                                                                       |Liechtenstein        |LIE          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000003|DAVID, RONALD                      |SUSPENDED             |10014      |NULL                                                                                                                                                       |Monaco               |MCO          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000004|DE  BOUTSELIS, JEAN-PIERRE         |SUSPENDED             |10015      |NULL                                                                                                                                                       |Belgium              |BEL          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000005|THE LEVANT LAWYERS (TLL)           |ACTIVE                |10029      |NULL                                                                                                                                                       |Lebanon              |LBN          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000006|ABARTH, ANNELIESE                  |UNRECOVERABLE ACCOUNTS|1004       |MS. ANNELIESE ABARTH 20 BOULEVARD PRINCESSE CHARLOTTE MONTE CARLO, MONACO                                                                                  |Monaco               |MCO          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000007|FIGEST CONSEIL S.A.                |ACTIVE                |10064      |NULL                                                                                                                                                       |Switzerland          |CHE          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000008|MED ENERGY S.A.L.                  |ACTIVE                |10106      |NULL                                                                                                                                                       |Lebanon              |LBN          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000009|TRUSTCO LABUAN SDN BHD             |SUSPENDED             |10116      |TRUSTCO LABUAN SDN RHD (409273-A); UNIT 3; (1)  MAIN OFFICE TOWER; FINANCIAL PARK LABUAN JALAN MERDEKA; 87000 W.P. LABUAN MALAYSIA ATTENTION: LESLEY HAVILL|Malaysia             |MYS          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000010|SYL LOGIC SERVICES SA              |ACTIVE                |10121      |NULL                                                                                                                                                       |Switzerland          |CHE          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000011|LAFEVER, RONALD L.                 |SUSPENDED             |10140      |NULL                                                                                                                                                       |Spain                |ESP          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000012|BROUGH, CHARLES (MR.)              |INACTIVE              |1          |MR. CHARLES BROUGH 61 SANDY LANE CHEAM; SURREY SM2 7EN ENGLAND; UNITED KINGDOM                                                                             |United Kingdom       |GBR          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000013|MOURANT & CO. SECRETARIES LIMITED  |SUSPENDED             |10         |MOURANT & CO. SECRETARIES LIMITED P. O. BOX 87 22 GRENVILLE STREET ST. HELIER, JERSEY JE4 8PX CHANNEL ISLANDS                                              |Jersey;United Kingdom|JEY;GBR      |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000014|CREVON, GEORGES-ALAIN              |SUSPENDED             |10008      |NULL                                                                                                                                                       |France               |FRA          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000015|FIDUCIAIRE FERNAND KARTHEISER & CIE|SUSPENDED             |1003       |FIDUCIAIRE FERNAND KARTHEISER & CIE 57 ROUTE D'ARLON L-1140 LUXEMBOURG                                                                                     |Luxembourg           |LUX          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000016|FIDUCIAIRE A. RICHARD S.A.         |ACTIVE                |10050      |NULL                                                                                                                                                       |Switzerland          |CHE          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000017|HOLLYSIDE MANAGEMENT LIMITED       |SUSPENDED             |10060      |HOLLYSIDE MANAGEMENT LIMITED PA-TEH ROAD; SEC 4. NO.765; 5F-1 TAIPE 105; TAIWAN                                                                            |Taiwan               |TWN          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000018|FUDEM S.A.                         |SUSPENDED             |10069      |NULL                                                                                                                                                       |Switzerland          |CHE          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000019|GBC GLOBAL BUSINESS CENTER SARL    |ACTIVE                |10078      |NULL                                                                                                                                                       |Switzerland          |CHE          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    |11000020|GNIDIN, MIHHAIL                    |ACTIVE                |10086      |NULL                                                                                                                                                       |Estonia              |EST          |Panama Papers|The Panama Papers  data is current through 2015|NULL|
    +--------+-----------------------------------+----------------------+-----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+---------------------+-------------+-------------+-----------------------------------------------+----+
    only showing top 20 rows
    





    intermediaryDS: Dataset[Intermediary] = [node_id: string, name: string ... 8 more fields]




```scala
// create a case class for the `nodes-intermediaries.csv`
/**
  * Represents a node from the nodes-others.csv file.
  *
  * @param node_id The unique identifier for the node.
  * @param name The name associated with the node.
  * @param `type` The type of the node (e.g., 'company', 'person').
  * @param country_codes The country codes associated with the node.
  * @param countries The countries associated with the node.
  * @param sourceID The ID of the data source.
  * @param valid_until The date until which the data is considered valid.
  * @param note Any additional notes.
  */
case class OtherNode(
  node_id: String,
  name: Option[String],
  `type`: Option[String],
  country_codes: Option[String],
  countries: Option[String],
  sourceID: Option[String],
  valid_until: Option[String],
  note: Option[String]
)

```




    defined class OtherNode




```scala
// Read CSV and convert to Dataset
val otherNodeDS = spark.read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv(s"${filePath}full-oldb.LATEST/nodes-others.csv")
  .as[OtherNode]

// Example queries
otherNodeDS.show(false)
```













    +--------+-------------------------------------+-------------------------+------------------+---------------+-----------+------------+------------------------+---------+-------------+------------------------------------------+-----------------------------------------------------+----------------------------------------+
    |node_id |name                                 |type                     |incorporation_date|struck_off_date|closed_date|jurisdiction|jurisdiction_description|countries|country_codes|sourceID                                  |valid_until                                          |note                                    |
    +--------+-------------------------------------+-------------------------+------------------+---------------+-----------+------------+------------------------+---------+-------------+------------------------------------------+-----------------------------------------------------+----------------------------------------+
    |85004929|ANTAM ENTERPRISES N.V.               |LIMITED LIABILITY COMPANY|18-MAY-1983       |NULL           |28-NOV-2012|AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|Closed date stands for Cancelled date.  |
    |85008443|DEVIATION N.V.                       |LIMITED LIABILITY COMPANY|28-JUN-1989       |31-DEC-2002    |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85008517|ARIAZI N.V.                          |LIMITED LIABILITY COMPANY|19-JUL-1989       |NULL           |19-MAY-2004|AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|Closed date stands for Cancelled date.  |
    |85008542|FLAIRUBA N.V.                        |LIMITED LIABILITY COMPANY|27-JUL-1989       |24-JUL-2000    |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85008583|S.L. ARUBA FISHERIES TRADING N.V.    |LIMITED LIABILITY COMPANY|01-AUG-1989       |NULL           |29-OCT-2007|AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|Closed date stands for Cancelled date.  |
    |85008632|PALCOHI ARUBA N.V.                   |LIMITED LIABILITY COMPANY|18-AUG-1989       |23-APR-2009    |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85008634|CHEECHO (ARUBA) N.V.                 |LIMITED LIABILITY COMPANY|18-AUG-1989       |22-OCT-1996    |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85008647|WINTERGARDEN N.V.                    |LIMITED LIABILITY COMPANY|22-AUG-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85008675|CRUKEL (ARUBA) II N.V.               |LIMITED LIABILITY COMPANY|29-AUG-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85008706|CARAMBOLA N.V.                       |LIMITED LIABILITY COMPANY|04-SEP-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85008794|BEACH BUM CO N.V.                    |LIMITED LIABILITY COMPANY|29-SEP-1988       |30-DEC-2005    |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85008888|DE LANDAUER N.V.                     |LIMITED LIABILITY COMPANY|16-OCT-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85009016|RUPCHAND SONS N.V.                   |LIMITED LIABILITY COMPANY|16-NOV-1989       |NULL           |05-SEP-2016|AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|Closed date stands for Liquidation date.|
    |85009035|ASSANG TRADING COMPANY N.V.          |LIMITED LIABILITY COMPANY|20-NOV-1989       |NULL           |18-DEC-2007|AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|Closed date stands for Cancelled date.  |
    |85009054|RED SAIL SPORTS ARUBA N.V.           |LIMITED LIABILITY COMPANY|10-JAN-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85009128|DEALS ON WHEELS N.V.                 |LIMITED LIABILITY COMPANY|06-DEC-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85009129|JAVARUBA N.V.                        |LIMITED LIABILITY COMPANY|06-DEC-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85009212|FURNITURE OUTLET CENTER N.V.         |LIMITED LIABILITY COMPANY|28-DEC-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85009213|LING & SONS HOLDING & MANAGEMENT N.V.|LIMITED LIABILITY COMPANY|28-DEC-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    |85009339|ARTMAR N.V.                          |LIMITED LIABILITY COMPANY|28-DEC-1989       |NULL           |NULL       |AW          |Aruba                   |NULL     |NULL         |Paradise Papers - Aruba corporate registry|Aruba corporate registry data is current through 2016|NULL                                    |
    +--------+-------------------------------------+-------------------------+------------------+---------------+-----------+------------+------------------------+---------+-------------+------------------------------------------+-----------------------------------------------------+----------------------------------------+
    only showing top 20 rows
    





    otherNodeDS: Dataset[OtherNode] = [node_id: int, name: string ... 11 more fields]




```scala
/**
  * Represents an officer from the nodes-officers.csv file.
  *
  * @param node_id The ID of the node.
  * @param name The name of the officer.
  * @param country_codes The country codes associated with the officer.
  * @param countries The countries associated with the officer.
  * @param sourceID The ID of the source.
  * @param valid_until The date until which the data is valid.
  * @param note Any notes associated with the record.
  */
case class OfficerNode(
  node_id: String,
  name: Option[String],
  country_codes: Option[String],
  countries: Option[String],
  sourceID: Option[String],
  valid_until: Option[String],
  note: Option[String]
)

```




    defined class OfficerNode




```scala
// Read CSV and convert to Dataset
val officerNodeDS = spark.read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv(s"${filePath}full-oldb.LATEST/nodes-officers.csv")
  .as[OfficerNode]

// Example queries
officerNodeDS.show(false)
```













    +--------+---------------------------------+-----------+-------------+-------------+----------------------------------------------+----+
    |node_id |name                             |countries  |country_codes|sourceID     |valid_until                                   |note|
    +--------+---------------------------------+-----------+-------------+-------------+----------------------------------------------+----+
    |12000001|KIM SOO IN                       |South Korea|KOR          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000002|Tian Yuan                        |China      |CHN          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000003|GREGORY JOHN SOLOMON             |Australia  |AUS          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000004|MATSUDA MASUMI                   |Japan      |JPN          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000005|HO THUY NGA                      |Viet Nam   |VNM          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000006|RACHMAT ARIFIN                   |Australia  |AUS          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000007|TAN SUN-HUA                      |Philippines|PHL          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000008|Ou Yang Yet-Sing and Chang Ko    |Taiwan     |TWN          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000009|Wu Chi-Ping and Wu Chou Tsan-Ting|Taiwan     |TWN          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000010|ZHONG LI MING                    |China      |CHN          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000011|LIN PING                         |China      |CHN          |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000012|BOSHEN LTD./135-77               |NULL       |NULL         |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000013|BOSHEN LTD./133-58               |NULL       |NULL         |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000014|BOSHEN LTD./132-50               |NULL       |NULL         |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000015|BOSHEN LTD.                      |NULL       |NULL         |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000016|ALGONQUIN TRUST LTD.             |NULL       |NULL         |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000017|ALGONQUIN TRUST PANAMA           |NULL       |NULL         |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000018|MIRABAUD & CIE/111-40            |NULL       |NULL         |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000019|BOSHEN LTD./137-93               |NULL       |NULL         |Panama Papers|The Panama Papers data is current through 2015|NULL|
    |12000020|BOSHEN LTD./136-83               |NULL       |NULL         |Panama Papers|The Panama Papers data is current through 2015|NULL|
    +--------+---------------------------------+-----------+-------------+-------------+----------------------------------------------+----+
    only showing top 20 rows
    





    officerNodeDS: Dataset[OfficerNode] = [node_id: string, name: string ... 5 more fields]




```scala
// create AddressNode case class
case class AddressNode(
  node_id: String,
  address: Option[String],
  name: Option[String],
  countries: Option[String],
  country_codes: Option[String],
  sourceID: Option[String],
  valid_until: Option[String],
  note: Option[String]
)

```




    defined class AddressNode




```scala
// Read CSV and convert to Dataset
val addressNodeDS = spark.read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv(s"${filePath}full-oldb.LATEST/nodes-addresses.csv")
  .as[AddressNode]

// Example queries
addressNodeDS.show(false)
```













    +--------+--------------------------------------------------------------------------------------------------+----+---------+-------------+-------------+-----------------------------------------------------+----+
    |node_id |address                                                                                           |name|countries|country_codes|sourceID     |valid_until                                          |note|
    +--------+--------------------------------------------------------------------------------------------------+----+---------+-------------+-------------+-----------------------------------------------------+----+
    |24000001|ANNEX FREDERICK & SHIRLEY STS, P.O. BOX N-4805, NASSAU, BAHAMAS                                   |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000002|SUITE E-2,UNION COURT BUILDING, P.O. BOX N-8188, NASSAU, BAHAMAS                                  |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000003|LYFORD CAY HOUSE, LYFORD CAY, P.O. BOX N-7785, NASSAU, BAHAMAS                                    |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000004|P.O. BOX N-3708 BAHAMAS FINANCIAL CENTRE, P.O. BOX N-3708 SHIRLEY & CHARLOTTE STS, NASSAU, BAHAMAS|NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000005|LYFORD CAY HOUSE, 3RD FLOOR, LYFORD CAY, P.O. BOX N-3024, NASSAU, BAHAMAS                         |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000006|303 SHIRLEY STREET, P.O. BOX N-492, NASSAU, BAHAMAS                                               |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000007|OCEAN CENTRE, MONTAGU FORESHORE, P.O. BOX SS-19084 EAST BAY STREET, NASSAU, BAHAMAS               |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000008|PROVIDENCE HOUSE, EAST WING EAST HILL ST, P.O. BOX CB-12399, NASSAU, BAHAMAS                      |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000009|BAYSIDE EXECUTIVE PARK, WEST BAY & BLAKE, P.O. BOX N-4875, NASSAU, BAHAMAS                        |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000010|GROUND FLOOR, GOODMAN'S BAY CORPORATE CE, P.O. BOX N 3933, NASSAU, BAHAMAS                        |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000011|TK HOUSE, BAYSIDE EXECUTIVE PARK, P.O. BOX AP-59213 WEST BAY & BLAKE ROAD, NASSAU, BAHAMAS        |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000012|BAYSIDE HOUSE WEST BAY & BLAKE ROAD, P.O. BOX AP-59213, NASSAU, BAHAMAS                           |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000013|#308 EAST BAY ST. 4TH FLOOR, P.O. BOX N-7768, NASSAU, BAHAMAS                                     |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000014|THE RIGARNO BUILDING BAY & VICTORIA AVE., P.O. BOX N-4755, NASSAU, BAHAMAS                        |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000015|#1 MILLARS COURT, P.O. BOX N-7117, NASSAU, BAHAMAS                                                |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000016|MAREVA HOUSE 4 GEORGE STREET, P.O. BOX N-3937, NASSAU, BAHAMAS                                    |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000017|SASSOON HOUSE SHIRLEY ST. & VICTORIA AVE, P.O. BOX SS-5383, NASSAU, BAHAMAS                       |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000018|WINTERBOTHAM PLACE MARLBOROUGH & QUEEN, P.O. BOX N-10429, NASSAU, BAHAMAS                         |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000019|P.O. BOX N-3242, 3RD FLOOR, MONTAGUE STERLING CENTRE, EAST BAY STREET                             |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    |24000020|P.O. BOX N-9100, NASSAU, BAHAMAS                                                                  |NULL|Bahamas  |BHS          |Bahamas Leaks|The Bahamas Leaks data is current through early 2016.|NULL|
    +--------+--------------------------------------------------------------------------------------------------+----+---------+-------------+-------------+-----------------------------------------------------+----+
    only showing top 20 rows
    





    addressNodeDS: Dataset[AddressNode] = [node_id: string, address: string ... 6 more fields]




```scala
// create relationships case class
case class Relationship(node_id_start: String, 
    node_id_end: String, 
    rel_type: String, 
    link: String, 
    status: String, 
    start_date: String, 
    end_date: String, 
    sourceID: String)
```




    defined class Relationship




```scala
// Read CSV and convert to Dataset
val relationshipNodeDS = spark.read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv(s"${filePath}full-oldb.LATEST/relationships.csv")
  .as[Relationship]

// Example queries
relationshipNodeDS.show(false)
```













    +-------------+-----------+------------------+------------------+------+-----------+--------+-------------+
    |node_id_start|node_id_end|rel_type          |link              |status|start_date |end_date|sourceID     |
    +-------------+-----------+------------------+------------------+------+-----------+--------+-------------+
    |10002580     |14106952   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10004460     |14101133   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10023813     |14105100   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10023840     |14100712   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10010428     |14093957   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10012916     |14093957   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10016348     |14091822   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10016353     |14092974   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10022392     |14098791   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10022689     |14092925   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10033748     |14104667   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10000580     |14097397   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10005830     |14093248   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10012274     |14097854   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10008180     |14108697   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |12195425     |10000601   |officer_of        |shareholder of    |NULL  |17-NOV-2005|NULL    |Panama Papers|
    |10012071     |14093248   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10013135     |14091822   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10022242     |14100513   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    |10026712     |14096975   |registered_address|registered address|NULL  |NULL       |NULL    |Panama Papers|
    +-------------+-----------+------------------+------------------+------+-----------+--------+-------------+
    only showing top 20 rows
    





    relationshipNodeDS: Dataset[Relationship] = [node_id_start: string, node_id_end: string ... 6 more fields]



Find the available `rel_type`:


```scala
relationshipNodeDS.groupBy("rel_type").count().show(false)
```









    +------------------------+-------+
    |rel_type                |count  |
    +------------------------+-------+
    |registered_address      |832721 |
    |NULL                    |2      |
    |same_name_as            |104170 |
    |intermediary_of         |598546 |
    |officer_of              |1720357|
    |underlying              |1308   |
    |similar                 |46761  |
    |same_as                 |4272   |
    |connected_to            |12145  |
    |01-AUG-2011             |1      |
    |same_id_as              |3120   |
    |same_intermediary_as    |4      |
    |same_company_as         |15523  |
    |probably_same_officer_as|132    |
    |similar_company_as      |203    |
    |same_address_as         |5      |
    +------------------------+-------+
    


## 1. BASIC RELATIONSHIP JOINS - UNDERSTANDING THE GRAPH

1.1. Find all entities with their officers (SHAREHOLDER_OF, DIRECTOR_OF, OFFICER_OF)


```scala
val entitiesWithOfficers = entityNodeDS
  .join(
    relationshipNodeDS.filter($"rel_type".isin("officer_of", "shareholder_of", "director_of")),
    entityNodeDS("node_id") === relationshipNodeDS("node_id_end"),
    "inner"
  )
  .join(
    officerNodeDS,
    relationshipNodeDS("node_id_start") === officerNodeDS("node_id"),
    "inner"
  )
  .select(
    entityNodeDS("node_id").as("entity_id"),
    entityNodeDS("name").as("entity_name"),
    entityNodeDS("jurisdiction"),
    officerNodeDS("node_id").as("officer_id"),
    officerNodeDS("name").as("officer_name"),
    officerNodeDS("countries").as("officer_countries"),
    relationshipNodeDS("rel_type").as("relationship_type"),
    relationshipNodeDS("link"),
    relationshipNodeDS("start_date"),
    relationshipNodeDS("end_date")
  )

```




    entitiesWithOfficers: DataFrame = [entity_id: string, entity_name: string ... 8 more fields]




```scala
entityNodeDS.count()
relationshipNodeDS.count()
officerNodeDS.count()
entitiesWithOfficers.count()
```




















































    res17_0: Long = 814606L
    res17_1: Long = 3339270L
    res17_2: Long = 771366L
    res17_3: Long = 1711446L




```scala
entitiesWithOfficers.show()
```





















    +---------+--------------------+------------+----------+--------------------+-----------------+-----------------+--------------+----------+----------+
    |entity_id|         entity_name|jurisdiction|officer_id|        officer_name|officer_countries|relationship_type|          link|start_date|  end_date|
    +---------+--------------------+------------+----------+--------------------+-----------------+-----------------+--------------+----------+----------+
    |   140102|      Lanka Aces Ltd|         BVI|    100010| Balan Vijayarahavan|   Not identified|       officer_of|   director of|2004-12-09|      NULL|
    |   123348|  JADE TIGER LIMITED|         BVI|    100014|   Mary May-Lit Shih|   Not identified|       officer_of|shareholder of|      NULL|      NULL|
    |   133981| SIAM ORCHID LIMITED|         BVI|    100021|Asia Pacific Prop...|   Not identified|       officer_of|shareholder of|2003-12-17|      NULL|
    |   144930|      Sanwa Asan Ltd|         BVI|    100062|        Almo Santoso|   Not identified|       officer_of|shareholder of|2003-10-07|      NULL|
    |   144930|      Sanwa Asan Ltd|         BVI|    100062|        Almo Santoso|   Not identified|       officer_of|   director of|2003-11-07|      NULL|
    |   139318|         TopRun Ltd.|         BVI|    100070|     Wenchung Chuang|   Not identified|       officer_of|   director of|2005-05-31|      NULL|
    |   139318|         TopRun Ltd.|         BVI|    100070|     Wenchung Chuang|   Not identified|       officer_of|shareholder of|2005-05-31|      NULL|
    |   127040|LETS GO INVESTMEN...|         BVI|    100090|     Chau Hau Cheong|   Not identified|       officer_of|   director of|2002-01-21|2002-08-16|
    |   135568|   Shin Dan Co., Ltd|         BVI|    100129|     Ling Chang-Long|   Not identified|       officer_of|shareholder of|      NULL|      NULL|
    |   172010|NICE HARVEST ENTE...|         SAM|    100140|      Chang, Li-Hsin|   Not identified|       officer_of|   director of|2003-01-22|      NULL|
    |   161750|Portcullis TrustN...|       MAURI|    100156|  Orchid Nominee Ltd|   Not identified|       officer_of|shareholder of|1998-11-20|1998-11-20|
    |   150290|MONGOLIAN NATURAL...|         BVI|    100160|         LI XIAOMING|   Not identified|       officer_of|shareholder of|2006-05-20|      NULL|
    |   145748|TRADE POINT MANAG...|         BVI|    100191|          LI Siu Yin|   Not identified|       officer_of|   director of|2005-03-09|      NULL|
    |   145748|TRADE POINT MANAG...|         BVI|    100191|          LI Siu Yin|   Not identified|       officer_of|shareholder of|2005-03-09|      NULL|
    |   146645|MCC Pacific Holdi...|         BVI|    100192|         Chris Chang|      South Korea|       officer_of|   director of|2005-07-12|      NULL|
    |   146645|MCC Pacific Holdi...|         BVI|    100192|         Chris Chang|      South Korea|       officer_of|shareholder of|2005-07-12|      NULL|
    |   144014|WISHLIST HOLDINGS...|         BVI|    100200|Siney Nominee Lim...|        Hong Kong|       officer_of|  secretary of|2005-05-13|      NULL|
    |   148784|JOINT LINK DEVELO...|         BVI|    100200|Siney Nominee Lim...|        Hong Kong|       officer_of|  secretary of|2005-09-05|      NULL|
    |   148755|GLORY STEP TECHNO...|         BVI|    100208|       YANG, KANG-FA|           Taiwan|       officer_of|   director of|2005-09-26|      NULL|
    |   148755|GLORY STEP TECHNO...|         BVI|    100208|       YANG, KANG-FA|           Taiwan|       officer_of|shareholder of|2005-09-26|      NULL|
    +---------+--------------------+------------+----------+--------------------+-----------------+-----------------+--------------+----------+----------+
    only showing top 20 rows
    


1.2 Find all entities with their intermediaries


```scala
val entitiesWithIntermediaries = entityNodeDS
  .join(
    relationshipNodeDS.filter($"rel_type" === "intermediary_of"),
    entityNodeDS("node_id") === relationshipNodeDS("node_id_end"),
    "inner"
  )
  .join(
    intermediaryDS,
    relationshipNodeDS("node_id_start") === intermediaryDS("node_id"),
    "inner"
  )
  .select(
    entityNodeDS("node_id").as("entity_id"),
    entityNodeDS("name").as("entity_name"),
    entityNodeDS("jurisdiction"),
    intermediaryDS("node_id").as("intermediary_id"),
    intermediaryDS("name").as("intermediary_name"),
    intermediaryDS("countries").as("intermediary_countries"),
    intermediaryDS("status").as("intermediary_status")
  )
```




    entitiesWithIntermediaries: DataFrame = [entity_id: string, entity_name: string ... 5 more fields]




```scala
entitiesWithIntermediaries.show()
```

















    +---------+--------------------+------------+---------------+--------------------+----------------------+-------------------+
    |entity_id|         entity_name|jurisdiction|intermediary_id|   intermediary_name|intermediary_countries|intermediary_status|
    +---------+--------------------+------------+---------------+--------------------+----------------------+-------------------+
    | 10000007|KENT DEVELOPMENT ...|         SAM|       11001746|ORION HOUSE SERVI...|             Hong Kong|             ACTIVE|
    | 10000016|NINGBO RAPID INTE...|         SAM|       11001746|ORION HOUSE SERVI...|             Hong Kong|             ACTIVE|
    | 10000018|      CHEM D-T Corp.|         SAM|       11002484|GO SHINE MANAGEME...|                Taiwan|             ACTIVE|
    | 10000021|FORTUNE PALACE LI...|         SAM|       11005766|AFOR LAW FIRM, SI...|                 China|             ACTIVE|
    | 10000036|RIVIERA HOLDINGS ...|         SAM|       11000040|         GESTAR S.A.|           Switzerland|             ACTIVE|
    | 10000047|CORAL SEA GROUP LTD.|         SAM|       11012339|MEI SERVICES LIMITED|             Hong Kong|             ACTIVE|
    | 10000048|DELTORIA TRADING ...|         SAM|       11000504|     PERFECT COMPANY|             Hong Kong|          SUSPENDED|
    | 10000050|UNIVERSAL RESOURC...|         SAM|       11008027|MOSSACK FONSECA &...|             Singapore|             ACTIVE|
    | 10000055| SEG MECHANICAL LTD.|         SAM|       11011409|EUROFIN SERVICES ...|                  NULL|               NULL|
    | 10000108|       ENCHANTE S.A.|         SAM|       11000182|   WILLOW TRUST LTD.|  Guernsey;United K...|             ACTIVE|
    | 10000120|WESTBURY INVESTME...|         SAM|       11007763|COMPANY EXPRESS C...|        United Kingdom|             ACTIVE|
    | 10000136|    STAYBOND LIMITED|         SAM|       11001746|ORION HOUSE SERVI...|             Hong Kong|             ACTIVE|
    | 10000154|WESTLEIGH ENTERPR...|         PMA|       11013759|EBC FINANCIAL SER...|  Jersey;United Kin...|           INACTIVE|
    | 10000157|GRAND FORTUNE LIM...|         SAM|       11001727|DI SAN DI MANAGEM...|                Taiwan|             ACTIVE|
    | 10000172|     FAR WAY LIMITED|         SAM|       11001746|ORION HOUSE SERVI...|             Hong Kong|             ACTIVE|
    | 10000173|    TOWNSIDE LIMITED|         SAM|       11012037|PRIME CORPORATE S...|            Luxembourg|             ACTIVE|
    | 10000194|      WITZE CO., LTD|         SAM|       11001746|ORION HOUSE SERVI...|             Hong Kong|             ACTIVE|
    | 10000200|MIRACLE FAITH LIM...|         SAM|       11011863|MOSSACK FONSECA &...|                Panama|             ACTIVE|
    | 10000216|HARDWICKES FINANC...|         PMA|       11010502|          RAWI & CO.|        United Kingdom|             ACTIVE|
    | 10000235|WINS TOP ENTERPRI...|         SAM|       11001746|ORION HOUSE SERVI...|             Hong Kong|             ACTIVE|
    +---------+--------------------+------------+---------------+--------------------+----------------------+-------------------+
    only showing top 20 rows
    


1.3 Find entities with their registered addresses


```scala
val entitiesWithAddresses = entityNodeDS
  .join(
    relationshipNodeDS.filter($"rel_type" === "registered_address"),
    entityNodeDS("node_id") === relationshipNodeDS("node_id_start"),
    "inner"
  )
  .join(
    addressNodeDS,
    relationshipNodeDS("node_id_end") === addressNodeDS("node_id"),
    "inner"
  )
  .select(
    entityNodeDS("node_id").as("entity_id"),
    entityNodeDS("name").as("entity_name"),
    entityNodeDS("jurisdiction"),
    addressNodeDS("node_id").as("address_id"),
    addressNodeDS("address"),
    addressNodeDS("countries").as("address_countries")
  )

```




    entitiesWithAddresses: DataFrame = [entity_id: string, entity_name: string ... 4 more fields]




```scala
entitiesWithAddresses.show()
```





















    +---------+--------------------+------------+----------+--------------------+--------------------+
    |entity_id|         entity_name|jurisdiction|address_id|             address|   address_countries|
    +---------+--------------------+------------+----------+--------------------+--------------------+
    |   108047|        Robert Burns|         XXX|    105020|Robert Burns 10 M...|       United States|
    |   220320|Kennington Financ...|         XXX|    105020|Robert Burns 10 M...|       United States|
    |   220319|Blackstone Financ...|         XXX|    105020|Robert Burns 10 M...|       United States|
    |   147752|SAKURA ENTERPRISE...|         BVI|    105140|P.O. Box 1109 Geo...|      Cayman Islands|
    |101740505|HOMELAND SERVICES...|         BRB| 120000031|SUITE 203- BUILDI...|            Barbados|
    |101739974|CACIQUES DEL ESTE...|         BRB| 120000031|SUITE 203- BUILDI...|            Barbados|
    |101300802|LIQUID NUTRITION SRL|         BRB| 120000063|P.O.BOX 963, 2ND ...|            Barbados|
    |100328901|SOUND'N WAVE AUDI...|         BRB| 120000070|   """LITTLE HAVEN""|          BLACK ROCK|
    |100630827|THE CRANE WINDWAR...|         BRB| 120000077|MARCY BUILDING, 2...|British Virgin Is...|
    |100327920|   N. K. DENTAL INC.|         BRB| 120000080|FIRST FLOOR, TRID...|            Barbados|
    |100621686|CSC COMPUTER SCIE...|         BRB| 120000080|FIRST FLOOR, TRID...|            Barbados|
    |101421147|WEATHERFORD INTER...|         BRB| 120000080|FIRST FLOOR, TRID...|            Barbados|
    |101424071|         NC III, LLC|         BRB| 120000080|FIRST FLOOR, TRID...|            Barbados|
    |101421148|WEATHERFORD BERMU...|         BRB| 120000080|FIRST FLOOR, TRID...|            Barbados|
    |101411666|OMEGA INDUSTRIES ...|         BRB| 120000080|FIRST FLOOR, TRID...|            Barbados|
    |100910221|BEACH REINSURANCE...|         BRB| 120000080|FIRST FLOOR, TRID...|            Barbados|
    |101418550|BARRICK CAPITAL C...|         BRB| 120000080|FIRST FLOOR, TRID...|            Barbados|
    |101518096|ENERGIZER SALES, ...|         BRB| 120000081|SUITE 203, LAURIS...|            Barbados|
    |101515471|THOR EXPORT (1998...|         BRB| 120000102|TRIDENT CORPORATE...|            Barbados|
    |101838762|BEACH REGENERATIO...|         BRB| 120000149|ONE SANDY LANE, S...|            Barbados|
    +---------+--------------------+------------+----------+--------------------+--------------------+
    only showing top 20 rows
    


## 2. MULTI-HOP JOINS - NETWORK ANALYSIS

2.1 Complete entity profile: `Entity -> Officers + Intermediaries + Addresses`. Complete entity profiles combining all relationship types


```scala
import org.apache.spark.sql.functions.col

val completeEntityProfile = entityNodeDS
  // Join with officers
  .join(
    relationshipNodeDS.filter(col("rel_type").contains("officer"))
      .withColumnRenamed("node_id_start", "officer_node_id")
      .withColumnRenamed("node_id_end", "entity_node_id")
      .alias("officer_rel"),
    entityNodeDS("node_id") === col("officer_rel.entity_node_id"),
    "left"
  )
  .join(
    officerNodeDS.alias("officer"),
    col("officer_rel.officer_node_id") === col("officer.node_id"),
    "left"
  )
  // Join with intermediaries
  .join(
    relationshipNodeDS.filter(col("rel_type") === "intermediary_of")
      .withColumnRenamed("node_id_start", "intermediary_node_id")
      .withColumnRenamed("node_id_end", "entity_node_id_int")
      .alias("int_rel"),
    entityNodeDS("node_id") === col("int_rel.entity_node_id_int"),
    "left"
  )
  .join(
    intermediaryDS.alias("intermediary"),
    col("int_rel.intermediary_node_id") === col("intermediary.node_id"),
    "left"
  )
  // Join with addresses
  .join(
    relationshipNodeDS.filter(col("rel_type") === "registered_address")
      .withColumnRenamed("node_id_start", "entity_addr_start")
      .withColumnRenamed("node_id_end", "address_node_id")
      .alias("addr_rel"),
    entityNodeDS("node_id") === col("addr_rel.entity_addr_start"),
    "left"
  )
  .join(
    addressNodeDS.alias("address"),
    col("addr_rel.address_node_id") === col("address.node_id"),
    "left"
  )

```




    import org.apache.spark.sql.functions.col
    completeEntityProfile: DataFrame = [node_id: string, name: string ... 68 more fields]




```scala
completeEntityProfile.show(false)

```

    08:52:38.821 [scala-kernel-interpreter-1] WARN  org.apache.spark.sql.catalyst.util.SparkStringUtils - Truncated the string representation of a plan since it was too large. This behavior can be adjusted by setting 'spark.sql.debug.maxToStringFields'.


















































    +--------+--------------------------------------------+--------------------------------------------+-----------+------------+------------------------+----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+------------------+-----------------+---------------+---------+-------------------------------+-------------------+-------+-------------+--------------------------------+--------------+-----------------------------------------------+----+---------------+--------------+----------+--------------+------+-----------+-----------+--------------+--------+------------------------------+-----------+-------------+--------------+-----------------------------------------------+----+--------------------+------------------+---------------+---------------+------+----------+--------+--------------+--------+-----------------------------------+------+-----------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+-------------+--------------+-----------------------------------------------+----+-----------------+---------------+------------------+------------------+------+----------+--------+--------------+-------+-------------------------------------------------------------------------------------------------+----+---------+-------------+--------------+-----------------------------------------------+----+
    |node_id |name                                        |original_name                               |former_name|jurisdiction|jurisdiction_description|company_type                      |address                                                                                                                                      |internal_id|incorporation_date|inactivation_date|struck_off_date|dorm_date|status                         |service_provider   |ibcRUC |country_codes|countries                       |sourceID      |valid_until                                    |note|officer_node_id|entity_node_id|rel_type  |link          |status|start_date |end_date   |sourceID      |node_id |name                          |countries  |country_codes|sourceID      |valid_until                                    |note|intermediary_node_id|entity_node_id_int|rel_type       |link           |status|start_date|end_date|sourceID      |node_id |name                               |status|internal_id|address                                                                                                                                      |countries  |country_codes|sourceID      |valid_until                                    |note|entity_addr_start|address_node_id|rel_type          |link              |status|start_date|end_date|sourceID      |node_id|address                                                                                          |name|countries|country_codes|sourceID      |valid_until                                    |note|
    +--------+--------------------------------------------+--------------------------------------------+-----------+------------+------------------------+----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+------------------+-----------------+---------------+---------+-------------------------------+-------------------+-------+-------------+--------------------------------+--------------+-----------------------------------------------+----+---------------+--------------+----------+--------------+------+-----------+-----------+--------------+--------+------------------------------+-----------+-------------+--------------+-----------------------------------------------+----+--------------------+------------------+---------------+---------------+------+----------+--------+--------------+--------+-----------------------------------+------+-----------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+-------------+--------------+-----------------------------------------------+----+-----------------+---------------+------------------+------------------+------+----------+--------+--------------+-------+-------------------------------------------------------------------------------------------------+----+---------+-------------+--------------+-----------------------------------------------+----+
    |165928  |Rhapsody Holdings Investment Ltd            |NULL                                        |NULL       |BVI         |British Virgin Islands  |Business Company Limited by Shares|TrustNet Chambers P.O. Box 3444 Road Town, Tortola British Virgin Islands;52/F., Two Interantional Finance Centre 8 Finance Street Hong Kong |NULL       |24-JUN-2008       |NULL             |NULL           |NULL     |Active                         |Portcullis Trustnet|1488439|HKG;VGB      |Hong Kong;British Virgin Islands|Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|88817          |165928        |officer_of|director of   |NULL  |2008-06-24 |NULL       |Offshore Leaks|88817   |ANTONIO ONGSIAKO COJUANGCO    |Philippines|PHL          |Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|296719              |165928            |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Offshore Leaks|296719  |UBS AG (HK)                        |NULL  |NULL       |NULL                                                                                                                                         |Hong Kong  |HKG          |Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|165928           |235608         |registered_address|registered address|NULL  |NULL      |NULL    |Offshore Leaks|235608 |Zurich.  UBS AG of, 52/F, Two International Finance Centre, 8 Finance Street, Central, Hong Kong.|NULL|Hong Kong|HKG          |Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|
    |165928  |Rhapsody Holdings Investment Ltd            |NULL                                        |NULL       |BVI         |British Virgin Islands  |Business Company Limited by Shares|TrustNet Chambers P.O. Box 3444 Road Town, Tortola British Virgin Islands;52/F., Two Interantional Finance Centre 8 Finance Street Hong Kong |NULL       |24-JUN-2008       |NULL             |NULL           |NULL     |Active                         |Portcullis Trustnet|1488439|HKG;VGB      |Hong Kong;British Virgin Islands|Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|88817          |165928        |officer_of|shareholder of|NULL  |2008-06-24 |NULL       |Offshore Leaks|88817   |ANTONIO ONGSIAKO COJUANGCO    |Philippines|PHL          |Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|296719              |165928            |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Offshore Leaks|296719  |UBS AG (HK)                        |NULL  |NULL       |NULL                                                                                                                                         |Hong Kong  |HKG          |Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|165928           |235608         |registered_address|registered address|NULL  |NULL      |NULL    |Offshore Leaks|235608 |Zurich.  UBS AG of, 52/F, Two International Finance Centre, 8 Finance Street, Central, Hong Kong.|NULL|Hong Kong|HKG          |Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|
    |10000007|KENT DEVELOPMENT LIMITED                    |KENT DEVELOPMENT LIMITED                    |NULL       |SAM         |Samoa                   |NULL                              |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000022    |26-JAN-2004       |03-MAY-2006      |15-FEB-2006    |NULL     |Defaulted                      |Mossack Fonseca    |15757  |HKG          |Hong Kong                       |Panama Papers |The Panama Papers data is current through 2015 |NULL|12203548       |10000007      |officer_of|shareholder of|NULL  |12-OCT-2004|NULL       |Panama Papers |12203548|PING FENG                     |China      |CHN          |Panama Papers |The Panama Papers data is current through 2015 |NULL|11001746            |10000007          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11001746|ORION HOUSE SERVICES (HK) LIMITED  |ACTIVE|11987      |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|Hong Kong  |HKG          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10000007|KENT DEVELOPMENT LIMITED                    |KENT DEVELOPMENT LIMITED                    |NULL       |SAM         |Samoa                   |NULL                              |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000022    |26-JAN-2004       |03-MAY-2006      |15-FEB-2006    |NULL     |Defaulted                      |Mossack Fonseca    |15757  |HKG          |Hong Kong                       |Panama Papers |The Panama Papers data is current through 2015 |NULL|12160432       |10000007      |officer_of|shareholder of|NULL  |26-JAN-2004|NULL       |Panama Papers |12160432|MOSSFON SUBSCRIBERS LTD.      |Samoa      |WSM          |Panama Papers |The Panama Papers data is current through 2015 |NULL|11001746            |10000007          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11001746|ORION HOUSE SERVICES (HK) LIMITED  |ACTIVE|11987      |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|Hong Kong  |HKG          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10000016|NINGBO RAPID INTERNATIONAL TRADING CO., LTD.|NINGBO RAPID INTERNATIONAL TRADING CO., LTD.|NULL       |SAM         |Samoa                   |NULL                              |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|1000944    |12-JAN-2006       |27-FEB-2014      |15-FEB-2014    |NULL     |Defaulted                      |Mossack Fonseca    |24181  |HKG          |Hong Kong                       |Panama Papers |The Panama Papers data is current through 2015 |NULL|12160432       |10000016      |officer_of|shareholder of|NULL  |12-JAN-2006|NULL       |Panama Papers |12160432|MOSSFON SUBSCRIBERS LTD.      |Samoa      |WSM          |Panama Papers |The Panama Papers data is current through 2015 |NULL|11001746            |10000016          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11001746|ORION HOUSE SERVICES (HK) LIMITED  |ACTIVE|11987      |ORION HOUSE SERVICES (HK) LIMITED ROOM 1401; 14/F.; WORLD COMMERCE  CENTRE; HARBOUR CITY; 7-11 CANTON ROAD; TSIM SHA TSUI; KOWLOON; HONG KONG|Hong Kong  |HKG          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10000021|FORTUNE PALACE LIMITED                      |FORTUNE PALACE LIMITED                      |NULL       |SAM         |Samoa                   |NULL                              |AFOR LAW FIRM, SICHUAN CHENGDU SHUANGNAN PIK WAN ROAD NO. 60 ATTACHED CHENGDU PEOPLE'S REPUBLIC OF CHINA                                     |1000087    |29-MAR-2004       |03-MAY-2006      |15-FEB-2006    |NULL     |Defaulted                      |Mossack Fonseca    |16408  |CHN          |China                           |Panama Papers |The Panama Papers data is current through 2015 |NULL|12160432       |10000021      |officer_of|shareholder of|NULL  |29-MAR-2004|NULL       |Panama Papers |12160432|MOSSFON SUBSCRIBERS LTD.      |Samoa      |WSM          |Panama Papers |The Panama Papers data is current through 2015 |NULL|11005766            |10000021          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11005766|AFOR LAW FIRM, SICHUAN             |ACTIVE|27544      |AFOR LAW FIRM, SICHUAN CHENGDU SHUANGNAN PIK WAN ROAD NO. 60 ATTACHED CHENGDU PEOPLE'S REPUBLIC OF CHINA                                     |China      |CHN          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10000021|FORTUNE PALACE LIMITED                      |FORTUNE PALACE LIMITED                      |NULL       |SAM         |Samoa                   |NULL                              |AFOR LAW FIRM, SICHUAN CHENGDU SHUANGNAN PIK WAN ROAD NO. 60 ATTACHED CHENGDU PEOPLE'S REPUBLIC OF CHINA                                     |1000087    |29-MAR-2004       |03-MAY-2006      |15-FEB-2006    |NULL     |Defaulted                      |Mossack Fonseca    |16408  |CHN          |China                           |Panama Papers |The Panama Papers data is current through 2015 |NULL|12133697       |10000021      |officer_of|shareholder of|NULL  |02-APR-2004|02-APR-2004|Panama Papers |12133697|BING CHEN                     |China      |CHN          |Panama Papers |The Panama Papers data is current through 2015 |NULL|11005766            |10000021          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11005766|AFOR LAW FIRM, SICHUAN             |ACTIVE|27544      |AFOR LAW FIRM, SICHUAN CHENGDU SHUANGNAN PIK WAN ROAD NO. 60 ATTACHED CHENGDU PEOPLE'S REPUBLIC OF CHINA                                     |China      |CHN          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10053227|GREENTRADE ECUADOR OVERSEAS INC.            |GREENTRADE ECUADOR OVERSEAS INC.            |NULL       |PMA         |Panama                  |NULL                              |ANDRADE VELOZ & ASOCIADOS AV. REPUBLICA 696  Y  DIEGO DE ALMAGRO  EDIF. FORUM 300 OFIC. 504 QUITO - ECUADOR                                  |42347      |04-APR-2007       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |10     |ECU          |Ecuador                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|12063455       |10053227      |officer_of|shareholder of|NULL  |05-APR-2007|18-FEB-2008|Panama Papers |12063455|EL PORTADOR                   |NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11003847            |10053227          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11003847|ANDRADE VELOZ & ASOCIADOS          |ACTIVE|23079      |NULL                                                                                                                                         |Ecuador    |ECU          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10053227|GREENTRADE ECUADOR OVERSEAS INC.            |GREENTRADE ECUADOR OVERSEAS INC.            |NULL       |PMA         |Panama                  |NULL                              |ANDRADE VELOZ & ASOCIADOS AV. REPUBLICA 696  Y  DIEGO DE ALMAGRO  EDIF. FORUM 300 OFIC. 504 QUITO - ECUADOR                                  |42347      |04-APR-2007       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |10     |ECU          |Ecuador                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|12010711       |10053227      |officer_of|shareholder of|NULL  |18-FEB-2008|NULL       |Panama Papers |12010711|EMPIRE SUN INVESTMENTS LIMITED|NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11003847            |10053227          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11003847|ANDRADE VELOZ & ASOCIADOS          |ACTIVE|23079      |NULL                                                                                                                                         |Ecuador    |ECU          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10053227|GREENTRADE ECUADOR OVERSEAS INC.            |GREENTRADE ECUADOR OVERSEAS INC.            |NULL       |PMA         |Panama                  |NULL                              |ANDRADE VELOZ & ASOCIADOS AV. REPUBLICA 696  Y  DIEGO DE ALMAGRO  EDIF. FORUM 300 OFIC. 504 QUITO - ECUADOR                                  |42347      |04-APR-2007       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |10     |ECU          |Ecuador                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|12063457       |10053227      |officer_of|shareholder of|NULL  |05-APR-2007|18-FEB-2008|Panama Papers |12063457|EL PORTADOR                   |NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11003847            |10053227          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11003847|ANDRADE VELOZ & ASOCIADOS          |ACTIVE|23079      |NULL                                                                                                                                         |Ecuador    |ECU          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10053227|GREENTRADE ECUADOR OVERSEAS INC.            |GREENTRADE ECUADOR OVERSEAS INC.            |NULL       |PMA         |Panama                  |NULL                              |ANDRADE VELOZ & ASOCIADOS AV. REPUBLICA 696  Y  DIEGO DE ALMAGRO  EDIF. FORUM 300 OFIC. 504 QUITO - ECUADOR                                  |42347      |04-APR-2007       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |10     |ECU          |Ecuador                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|12063453       |10053227      |officer_of|shareholder of|NULL  |05-APR-2007|18-FEB-2008|Panama Papers |12063453|EL PORTADOR                   |NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11003847            |10053227          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11003847|ANDRADE VELOZ & ASOCIADOS          |ACTIVE|23079      |NULL                                                                                                                                         |Ecuador    |ECU          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10053227|GREENTRADE ECUADOR OVERSEAS INC.            |GREENTRADE ECUADOR OVERSEAS INC.            |NULL       |PMA         |Panama                  |NULL                              |ANDRADE VELOZ & ASOCIADOS AV. REPUBLICA 696  Y  DIEGO DE ALMAGRO  EDIF. FORUM 300 OFIC. 504 QUITO - ECUADOR                                  |42347      |04-APR-2007       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |10     |ECU          |Ecuador                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|12063454       |10053227      |officer_of|shareholder of|NULL  |21-DEC-2007|18-FEB-2008|Panama Papers |12063454|EL PORTADOR                   |NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11003847            |10053227          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11003847|ANDRADE VELOZ & ASOCIADOS          |ACTIVE|23079      |NULL                                                                                                                                         |Ecuador    |ECU          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10053227|GREENTRADE ECUADOR OVERSEAS INC.            |GREENTRADE ECUADOR OVERSEAS INC.            |NULL       |PMA         |Panama                  |NULL                              |ANDRADE VELOZ & ASOCIADOS AV. REPUBLICA 696  Y  DIEGO DE ALMAGRO  EDIF. FORUM 300 OFIC. 504 QUITO - ECUADOR                                  |42347      |04-APR-2007       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |10     |ECU          |Ecuador                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|12063458       |10053227      |officer_of|shareholder of|NULL  |21-DEC-2007|18-FEB-2008|Panama Papers |12063458|EL PORTADOR                   |NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11003847            |10053227          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11003847|ANDRADE VELOZ & ASOCIADOS          |ACTIVE|23079      |NULL                                                                                                                                         |Ecuador    |ECU          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10053227|GREENTRADE ECUADOR OVERSEAS INC.            |GREENTRADE ECUADOR OVERSEAS INC.            |NULL       |PMA         |Panama                  |NULL                              |ANDRADE VELOZ & ASOCIADOS AV. REPUBLICA 696  Y  DIEGO DE ALMAGRO  EDIF. FORUM 300 OFIC. 504 QUITO - ECUADOR                                  |42347      |04-APR-2007       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |10     |ECU          |Ecuador                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|12063456       |10053227      |officer_of|shareholder of|NULL  |21-DEC-2007|18-FEB-2008|Panama Papers |12063456|EL PORTADOR                   |NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11003847            |10053227          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11003847|ANDRADE VELOZ & ASOCIADOS          |ACTIVE|23079      |NULL                                                                                                                                         |Ecuador    |ECU          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10053236|ONE PUT LTD.                                |ONE PUT LTD.                                |NULL       |BVI         |British Virgin Islands  |NULL                              |MOSSACK FONSECA & CO. (GENEVA) S.A. 4, RUE MICHELI-DU-CREST 1205 GENEVA SWITZERLAND                                                          |503629     |11-JUN-1991       |05-JAN-1995      |31-OCT-1994    |NULL     |Dissolved                      |Mossack Fonseca    |45378  |CHE          |Switzerland                     |Panama Papers |The Panama Papers data is current through 2015 |NULL|NULL           |NULL          |NULL      |NULL          |NULL  |NULL       |NULL       |NULL          |NULL    |NULL                          |NULL       |NULL         |NULL          |NULL                                           |NULL|11007372            |10053236          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11007372|MOSSACK FONSECA & CO. (GENEVA) S.A.|ACTIVE|3044       |NULL                                                                                                                                         |Switzerland|CHE          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10151582|SILVERTON INTERNATIONAL INDUSTRIES S.A.     |SILVERTON INTERNATIONAL INDUSTRIES S.A.     |NULL       |PMA         |Panama                  |NULL                              |J.P.D. ASOCIADOS S.A. RUTA 8 KM. 17500 ED. 100 OF. 134A; MONTEVIDEO; URUGUAY MONTEVIDEO URUGUAY                                              |60297      |01-NOV-2010       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |5      |URY          |Uruguay                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|12072259       |10151582      |officer_of|shareholder of|NULL  |02-NOV-2010|NULL       |Panama Papers |12072259|EL PORTADOR                   |NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11009412            |10151582          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11009412|J. P. DAMIANI & ASOCIADOS          |ACTIVE|8815       |J.P.D. ASOCIADOS S.A. RUTA 8 KM. 17500 ED. 100 OF. 134A; MONTEVIDEO; URUGUAY MONTEVIDEO URUGUAY                                              |Uruguay    |URY          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10151582|SILVERTON INTERNATIONAL INDUSTRIES S.A.     |SILVERTON INTERNATIONAL INDUSTRIES S.A.     |NULL       |PMA         |Panama                  |NULL                              |J.P.D. ASOCIADOS S.A. RUTA 8 KM. 17500 ED. 100 OF. 134A; MONTEVIDEO; URUGUAY MONTEVIDEO URUGUAY                                              |60297      |01-NOV-2010       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |5      |URY          |Uruguay                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|13009472       |10151582      |officer_of|beneficiary of|NULL  |NULL       |NULL       |Panama Papers |13009472|IVAN MAY                      |NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11009412            |10151582          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11009412|J. P. DAMIANI & ASOCIADOS          |ACTIVE|8815       |J.P.D. ASOCIADOS S.A. RUTA 8 KM. 17500 ED. 100 OF. 134A; MONTEVIDEO; URUGUAY MONTEVIDEO URUGUAY                                              |Uruguay    |URY          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10151582|SILVERTON INTERNATIONAL INDUSTRIES S.A.     |SILVERTON INTERNATIONAL INDUSTRIES S.A.     |NULL       |PMA         |Panama                  |NULL                              |J.P.D. ASOCIADOS S.A. RUTA 8 KM. 17500 ED. 100 OF. 134A; MONTEVIDEO; URUGUAY MONTEVIDEO URUGUAY                                              |60297      |01-NOV-2010       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |5      |URY          |Uruguay                         |Panama Papers |The Panama Papers data is current through 2015 |NULL|12072103       |10151582      |officer_of|shareholder of|NULL  |02-NOV-2010|NULL       |Panama Papers |12072103|EL PORTADOR                   |NULL       |NULL         |Panama Papers |The Panama Papers data is current through 2015 |NULL|11009412            |10151582          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11009412|J. P. DAMIANI & ASOCIADOS          |ACTIVE|8815       |J.P.D. ASOCIADOS S.A. RUTA 8 KM. 17500 ED. 100 OF. 134A; MONTEVIDEO; URUGUAY MONTEVIDEO URUGUAY                                              |Uruguay    |URY          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |10205235|FAITH RICH CONSULTANTS LIMITED              |FAITH RICH CONSULTANTS LIMITED              |NULL       |BVI         |British Virgin Islands  |NULL                              |TOPWORLD REGISTRATIONS LTD. 7/F; KIN ON COMMERCIAL BLDG. 49-51 JERVOIS ST; SHEUNG WAN HONG KONG                                              |6018277    |20-JAN-2011       |NULL             |NULL           |NULL     |Active                         |Mossack Fonseca    |NULL   |HKG          |Hong Kong                       |Panama Papers |The Panama Papers data is current through 2015 |NULL|12206300       |10205235      |officer_of|shareholder of|NULL  |20-JUL-2011|NULL       |Panama Papers |12206300|HONG TAO                      |China      |CHN          |Panama Papers |The Panama Papers data is current through 2015 |NULL|11000598            |10205235          |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Panama Papers |11000598|TOPWORLD REGISTRATIONS LTD.        |ACTIVE|11277      |TOPWORLD REGISTRATIONS LTD. 7/F; KIN ON COMMERCIAL BLDG. 49-51 JERVOIS ST; SHEUNG WAN HONG KONG                                              |Hong Kong  |HKG          |Panama Papers |The Panama Papers  data is current through 2015|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    |168473  |Trinity Limited                             |NULL                                        |NULL       |COOK        |Cook Islands            |Standard International Company    |NULL                                                                                                                                         |NULL       |01-FEB-1994       |NULL             |NULL           |NULL     |Struck / Defunct / Deregistered|Portcullis Trustnet|280594 |XXX          |Not identified                  |Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|NULL           |NULL          |NULL      |NULL          |NULL  |NULL       |NULL       |NULL          |NULL    |NULL                          |NULL       |NULL         |NULL          |NULL                                           |NULL|119118              |168473            |intermediary_of|intermediary of|NULL  |NULL      |NULL    |Offshore Leaks|119118  |Arthur Andersen HRM (Tax Services) |NULL  |NULL       |NULL                                                                                                                                         |Malaysia   |MYS          |Offshore Leaks|The Offshore Leaks data is current through 2010|NULL|NULL             |NULL           |NULL              |NULL              |NULL  |NULL      |NULL    |NULL          |NULL   |NULL                                                                                             |NULL|NULL     |NULL         |NULL          |NULL                                           |NULL|
    +--------+--------------------------------------------+--------------------------------------------+-----------+------------+------------------------+----------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+------------------+-----------------+---------------+---------+-------------------------------+-------------------+-------+-------------+--------------------------------+--------------+-----------------------------------------------+----+---------------+--------------+----------+--------------+------+-----------+-----------+--------------+--------+------------------------------+-----------+-------------+--------------+-----------------------------------------------+----+--------------------+------------------+---------------+---------------+------+----------+--------+--------------+--------+-----------------------------------+------+-----------+---------------------------------------------------------------------------------------------------------------------------------------------+-----------+-------------+--------------+-----------------------------------------------+----+-----------------+---------------+------------------+------------------+------+----------+--------+--------------+-------+-------------------------------------------------------------------------------------------------+----+---------+-------------+--------------+-----------------------------------------------+----+
    only showing top 20 rows
    


2.2 Officer network: Find all entities connected to the same officer: Officer network analysis (finding entities sharing officers)


```scala
val officerEntityNetwork = relationshipNodeDS
  .filter(col("rel_type").contains("officer"))
  .alias("rel1")
  .join(
    relationshipNodeDS.filter(col("rel_type").contains("officer")).alias("rel2"),
    col("rel1.node_id_start") === col("rel2.node_id_start") && 
    col("rel1.node_id_end") =!= col("rel2.node_id_end"),
    "inner"
  )
  .join(
    officerNodeDS,
    col("rel1.node_id_start") === officerNodeDS("node_id"),
    "inner"
  )
  .join(
    entityNodeDS.alias("entity1"),
    col("rel1.node_id_end") === col("entity1.node_id"),
    "inner"
  )
  .join(
    entityNodeDS.alias("entity2"),
    col("rel2.node_id_end") === col("entity2.node_id"),
    "inner"
  )
  .select(
    officerNodeDS("node_id").as("officer_id"),
    officerNodeDS("name").as("officer_name"),
    col("entity1.node_id").as("entity1_id"),
    col("entity1.name").as("entity1_name"),
    col("entity2.node_id").as("entity2_id"),
    col("entity2.name").as("entity2_name")
  )
```




    officerEntityNetwork: DataFrame = [officer_id: string, officer_name: string ... 4 more fields]




```scala
officerEntityNetwork.show()
```

























    +----------+--------------------+----------+--------------------+----------+-------------+
    |officer_id|        officer_name|entity1_id|        entity1_name|entity2_id| entity2_name|
    +----------+--------------------+----------+--------------------+----------+-------------+
    |  12160432|MOSSFON SUBSCRIBE...|  10000172|     FAR WAY LIMITED|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10000304|CHAMPLE INVESTMEN...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10000454|NEW SILK ROAD SHI...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10000472|ECOPACK INDUSTRIA...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10000528|        OPAQ LIMITED|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10000720|SILVER INTERNATIO...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10000835|AMASINO CEMENTOS LTD|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10000989|     Matchpoint Inc.|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10002011|CAPITAL BASE LIMITED|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10002280|IDEAL INTERNATION...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10002674|    GOLDEN ASIA LTD.|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10003360|Silver Mercury In...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10003366|DUPLEX LAND INTER...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10003840|SUNNY DIAMOND INV...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10004662|SILVERIDGE CHEMIC...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10005898|Polymount Company...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10008866|   CARANDALE LIMITED|  10000108|ENCHANTE S.A.|
    |  12020827|WILLOW TRUSTEES L...|  10008866|   CARANDALE LIMITED|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10009004|WOODRUFF ENTERPRI...|  10000108|ENCHANTE S.A.|
    |  12160432|MOSSFON SUBSCRIBE...|  10185907|OCEANIA GREEN TRE...|  10000108|ENCHANTE S.A.|
    +----------+--------------------+----------+--------------------+----------+-------------+
    only showing top 20 rows
    


## 3. ANALYTICAL JOINS - FRAUD DETECTION PATTERNS

Shared address analysis: Identifies potential shell companies at the same address.

3.1 Shared address analysis: Entities at the same address (potential shell companies)


```scala
val entitiesSharedAddress = relationshipNodeDS
  .filter(col("rel_type") === "registered_address")
  .alias("rel1")
  .join(
    relationshipNodeDS.filter(col("rel_type") === "registered_address").alias("rel2"),
    col("rel1.node_id_end") === col("rel2.node_id_end") && 
    col("rel1.node_id_start") =!= col("rel2.node_id_start"),
    "inner"
  )
  .join(
    addressNodeDS,
    col("rel1.node_id_end") === addressNodeDS("node_id"),
    "inner"
  )
  .join(
    entityNodeDS.alias("entity1"),
    col("rel1.node_id_start") === col("entity1.node_id"),
    "inner"
  )
  .join(
    entityNodeDS.alias("entity2"),
    col("rel2.node_id_start") === col("entity2.node_id"),
    "inner"
  )
  .select(
    addressNodeDS("node_id").as("address_id"),
    addressNodeDS("address"),
    col("entity1.node_id").as("entity1_id"),
    col("entity1.name").as("entity1_name"),
    col("entity1.jurisdiction").as("entity1_jurisdiction"),
    col("entity2.node_id").as("entity2_id"),
    col("entity2.name").as("entity2_name"),
    col("entity2.jurisdiction").as("entity2_jurisdiction")
  )

```




    entitiesSharedAddress: DataFrame = [address_id: string, address: string ... 6 more fields]




```scala
entitiesSharedAddress.show(false)
```














<div><code>show</code> at <code>cmd29.sc:1</code> (92% of 13 tasks, 1 on-going)</div>


To get meaningful insights, we cannot simply join tables on a common foreign key like a standard relational database. Instead, we must follow the graph path: **Node A → Relationship (Edge) → Node B**

### Proposed Solution: The "Beneficial Owner & Location" Join

I recommend creating a **Master Entity View**. This involves joining the `EntityNode` to its **Officers** (Directors/Shareholders) and its **Registered Address**.

Here is the logic for the join directionality based on ICIJ standards:

1.  **Officers → Entities:** Officers (Start) usually have a relationship _to_ the Entity (End).
2.  **Entities → Addresses:** Entities (Start) usually have a relationship _to_ an Address (End).

### Scala Spark Implementation

Here is the complete code block to perform this complex join. This code uses the DataSets you have already defined (`entityNodeDS`, `officerNodeDS`, `addressNodeDS`, `relationshipNodeDS`).


```scala
// Import necessary functions for easier column handling
import org.apache.spark.sql.functions._

// 1. Alias the Datasets to avoid column name ambiguity (all have "node_id")
val entities = entityNodeDS.as("e")
val relationships = relationshipNodeDS.as("rel")
val officers = officerNodeDS.as("o")
val addresses = addressNodeDS.as("addr")
```


```scala
// 2. Perform the Join: Entity <- [officer_of] - Officer
// We use a LEFT OUTER JOIN so we don't lose Entities that have no listed officers
val entityOfficerJoin = entities
  .join(relationships, col("e.node_id") === col("rel.node_id_end"), "left_outer")
  .join(officers, col("rel.node_id_start") === col("o.node_id"), "left_outer")
  .select(
    col("e.node_id").as("entity_id"),
    col("e.name").as("entity_name"),
    col("e.jurisdiction").as("entity_jurisdiction"),
    col("rel.rel_type").as("officer_role"),
    col("o.name").as("officer_name"),
    col("o.countries").as("officer_country")
  )
```


```scala
entityOfficerJoin.count()
```


```scala
// 3. Perform the Join: Entity - [registered_address] -> Address
// Note: We rejoin with relationships again (aliased as 'rel2') for the address direction
val relAddress = relationshipNodeDS.as("rel2")

val fullEntityProfile = entityOfficerJoin.as("eo")
  .join(relAddress, col("eo.entity_id") === col("rel2.node_id_start"), "left_outer")
  .join(addresses, col("rel2.node_id_end") === col("addr.node_id"), "left_outer")
  .filter(col("rel2.rel_type").isNull || col("rel2.rel_type") === "registered_address") // Optional: specific link type
  .select(
    col("eo.entity_id"),
    col("eo.entity_name"),
    col("eo.entity_jurisdiction"),
    col("eo.officer_name"),
    col("eo.officer_role"),
    col("eo.officer_country"),
    col("addr.address").as("registered_address"),
    col("addr.countries").as("address_country")
  )
```


```scala
fullEntityProfile.show(false)
```


```scala
import scala.sys.process._

val script = """
ls -al /home/jovyan/work/blogs/full-oldb.LATEST
"""

// Run using bash -c
Seq("bash", "-c", script).!
```


```scala
scala.util.Properties.versionNumberString
```


```scala
spark.stop()
```
