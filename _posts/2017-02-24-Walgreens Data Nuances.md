---
title: "Walgreens Data Nuances"
layout: post
date: 2017-08-18 22:48
image: /assets/images/markdown.jpg
headerImage: false
tag:
- markdown
- components
- extra
category: blog
author: jamesfoster
description: Markdown summary with different options
# jemoji: '<img class="emoji" title=":ramen:" alt=":ramen:" src="https://assets.github.com/images/icons/emoji/unicode/1f35c.png" height="20" width="20" align="absmiddle">'
---

## Walgreens Data Nuances
- [Item Code Hierarchy](#section1)
- [Master Data](#section2)
- [Sales Type 5 Data](#section3)
- [Data and Measure Nuances](#section4)
- [Store Nuances](#section5)
- [Walgreens Supplier Nuances](#section6)

<a name="Section1"></a>
## Item Code Hierarchy
### Control WIC, UPC, and WIC Number
- Control WIC
	- Looks at inventory
	-	WIC number looks at DC data
	-	Multiple Child WICs can be associated with the parent WIC
-	UPC
	-	UPCs contain sales data
	-	UPCs do not contain individual inventory (assigned to highest selling UPC)
	-	Multiple UPCs are associated with a single Control WIC
-	WIC number
	-	WIC number looks at DC data and receipts
	-	Multiple WIC Numbers can be associated to a single Control WIC
-	Relationships
	-	In reports, Walgreens use Control WIC, WIC Number, and UPC
	-	Control WIC is the parent WIC of WIC number
	-	WIC Number and UPC connect at a Control WIC level
	-	Users should not try and connect UPC and WIC Number (WIC Number will not always match Control WIC)

### Common Use Errors: 
-	WIC Numbers will be reassigned in the master file often
	-	Leads customers to believe their data is missing
	-	Reason not to match UPC with WIC Number
-	This literally happens all the time.
-	Walgreens users will think you are wrong
-	Be afraid of the WIC

**Retail Channel strongly suggests that users pull on Control WIC when looking at Store POS, Store Inventory, and Subscribed Store data**
 
<a name="Section2"></a>
## Master Data (DIM file) 
### Data Availability and Nuances:
-	Data Availability 
	-	Metric data is usually received once a week on Wednesday and loaded throughout the course of the week
	-	WAG provided attributes update once a week
	-	Walgreens runs a daily feed for POS data (around 7:30AM EST)
		-	If a Walgreens store misses a day, it will be bundled into the next day
		-	The system will split this data between the current and missing day
		-	If there are fewer sales, they will be bundled into the same day and there will be no data for the missed day.
	-	Walgreens Category and Inventory data is loaded after the daily POS data (Ticket #1029114)
	-	POG_IND data is usually loaded by Saturday
-	Dual Sourcing
	-	We currently load vendor in a two dimension Vendor – Item manner
	-	Walgreens provides data with different vendors depending on Geographic location
	-	We do not pick up data properly for some vendors and UPCs will disappear

### Common Use Cases:
-	Sometimes vendor numbers will change with the new data file and will cause some items to disappear from customer data (no historical data either)
	-	First Question: Is it Wednesday or Thursday?
	-	If Yes: Check the Default Filter and have Prod Ops query the new file to determine if and where these items switched to
	-	If No: Continue troubleshooting normally
-	Sometimes Dual Sourcing will cause vendor numbers to be improperly assigned
	-	Because of this, sometimes we assign an item to a secondary vendor that incorrectly shows the data
-	This is a known issue with the DIM file that is currently being worked on in an Enhancement to pull items from two different levels. The DC-Item-Supplier level and the Store-Item-Supplier level.
-	If the items are being dual sourced, we need to inform that customer that the data cannot be loaded until the enhancement is complete.
-	(Ticket #975961, Jira Issue: RDP-1406)

<a name="Section3"></a>
## Sales Type 5 Data
### Nuance:
-	What is it: 
	-	Rx Counter data that is usually included in Total Sales in reports
	-	For most suppliers, this data is unseen and negligible 
-	Vendor Specific Measures:
	-	On request (Customer Burning Issue), we will give companies access to a series of measure subtypes that will specifically calculate sales data for Sales Type 5 data.
 
-	Abbot Nutrition and Bayer

### Possible Use Case:
-	On occasion, it will overstate drastically and need to be purged from the data for that vendor (makes the data more closely resemble actual)
-	Ticket #501719 is an example of this situation

<a name="Section4"></a>
## Data and Measure Nuances
-	Data is received directly from Walgreens Data Warehouse not Supplier Net

-	POS data is recorded with positive and negative sales
	-	These are aggregated into the total sales measure we receive
	-	Example: 100 units sold - 15 units returned = 85 units in our data
	-	Customer invoices do not follow this logic and our data will be more accurate than invoices provided. (Ticket #1024771)
	-	Possibility of a Sales Without Returns measure being considered.

-	Store On hand Amount is not a core measure provided by Walgreens
	-	Store on Hand Units x Item Cost (DC On Hand amount/DC On Hand Units)
	-	If a customer is familiar with MDX, they can create this formula in RI

-	After 1 month, Store On Hand is aggregated to weekly values to preserve space (Image Created Oct. 19,2016)
 
-	Possible to run a Store On Hand report on a monthly basis to archive OH data
-	Also able to calculate daily values using the “Modeled Daily OH” measure

-	DC On Order Volume Units (104 weeks daily) = Orders placed by Walgreens
	-	Store On Order Volume Units (4 weeks daily) = Order placed by store but not received.

-	POG_IND vs Subscribed Store Count (and other subscribed measures)
	-	Based on Store-Item file received weekly from Walgreens.
	-	of facings ≥ 1, POG = 1
	-	Subscribed should be favored instead of POG_IND
	-	POG_IND is kept at a weekly level in RSi8 and is used to calculate the Subscribed measures
	-	Subscribed Store Count is a daily measure

<a name="Section5"></a>
## Store Caveats
### Miscellaneous Nuances:
-	Online Store ID: 05995 (Comes up frequently)
-	Drugstore.com is different from Online Store
	-	We do not receive data for this site
	-	Sometimes items will appear under this Vendor ID and will not be available in the cube
-	Duane Reade and Walgreens
	-	Some smaller vendors are not contracted for DR data
	-	Sometimes DR stores will appear in the Default Filter
	-	Nextgen Walgreens users need to contract for DR

<a name="Section6"></a>
## Walgreens Supplier Nuances
-	DSD (Direct Store Delivery) does not have a vendor number because it is not run through the Walgreen DC
	-	DSD customers can request to have their UPCs hardcoded into our cubes
-	McLane
	-	A distribution company that handles a number of different supplier deliveries to stores	
	-	We do not receive this data for Walgreens
