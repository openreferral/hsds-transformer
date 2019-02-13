# Open Referral Transformer
## Overview
This app allows you to convert data into an HSDS-compliant [datapackage](https://frictionlessdata.io/specs/data-package/).

The [Human Services Data Specification (HSDS)](https://openreferral.readthedocs.io/en/latest/hsds/) is a data model that describes health and human services. 

This transformer currently transforms data into HSDS version 1.1.

### Problem statement
Lots of people have health and human services data, but it's all in different structures and formats. Many groups want to share their data, or use data that's shared with them, but the lack of standardized data or an easy way to standardize the data presents a major barrier.

### Solution
Using [Open Referral](https://openreferral.org/)'s HSDS, groups can share data using a common format. This tool enables a group or person to transform data into an HSDS-compliant data package, so that it can then be combined with other data or used in any number of applications. 

### Case Study: Illinois Legal Aid Online (ILAO)
The real-world case that's motivating this project is [Illinois Legal Aid Online (ILAO)](https://www.illinoislegalaid.org/), an organization that helps individuals in Illinois find legal help or resources online. ILAO has a resource directory of community services data, and they'd like to update this data to be formatted in compliance with HSDS version 1.1. They also are looking to incorporate other data sets in disparate formats and structures into their own database in order to better serve Illinois residents with more extensive and more accurate information.

This project uses ILAO's resource database in the form of three CSVs as the test case. The data was pulled in January 2019, with some records not having been updated since 2017, and therefore some of the data may not be accurate or up-to-date. The data is located in `spec/fixtures/input`.

### Ideas for expansion
* Automate uploading to Airtable in the [Open Referral Human Services Template](https://airtable.com/universe/expTMdQFD5r9G6V9Y/open-referral-human-services-template)
* Incorporate the [OpenReferral Validator](https://github.com/spilio/openreferral-validator) to automatically validate data input/output
* Plug into [API-in-a-Box](https://github.com/switzersc/api-in-a-box) to automatically create a hypermedia API on top of the created datapackage
* Create a client library to generate a search UI on top of the created datapackage.


## How to use this tool
First, double check whether your data is already HSDS-compliant with the [OpenReferral Validator](https://github.com/spilio/openreferral-validator).

If it is, voila!

If it's not, proceed:

1. Make sure your data is saved locally as CSVs.

```
```

## Installing
