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

If it's not, proceed.

### Installing
1. Clone this repo locally.
2. In terminal, `cd` into the root of the open_referral_transformer directory.
3. Create a new file called `.env`. Copy the contents of `.env.example` into the new `.env` file and update `Users/your_user/dev/open_referral_transformer` to be the correct path to this directory on your local environment (you can run `pwd` in terminal to find this out).
4. Install all the gems by running `bundle install`

### Transforming

1. Make sure your data is saved locally as CSVs in this directory.
2. Create a mapping.yaml file and store it locally in this directory. This is what tells the transformer how to map fields from one set of CSVs into the HSDS format. See [spec/fixtures/mapping.yaml](https://github.com/switzersc/open_referral_transformer/blob/master/spec/fixtures/mapping.yaml) for an example. 
3. Open up an interactive Ruby session in terminal by running `irb` (or `pry` - up to you!)
4. Require the class: `require "./lib/open_referral_transformer"`
5. Run the transformer: 
```
OpenReferralTransformer.run(organizations: "path/to/organizations.csv", locations: "path/to/locations.csv", services: "path/to/services.csv", mapping: "path/to/mapping.yaml")
```
6. Now check the `tmp` directory for your newly created HSDS files!

## Related Projects

Open Referral Playground App
- Playground with various tools and code for working with Open Referral data
- [Github](https://github.com/spilio/openreferral-playground)

Open Referral Drupal
- [Info](https://openreferral.org/implementing-openreferral-drupal-wordpress/)
- [Github](https://github.com/openadvocate/openreferral-drupal)

Open Referral Wordpress
- [Github](https://github.com/openadvocate/openreferral-wordpress)

Open Referral Laravel Services
- Laravel/MySQL/Vue.js app
- [Github](https://github.com/sarapis/orservices)

Open Referral Validator
- [Docs](https://spilio.github.io/openreferral-validator/)
- [Github](https://github.com/spilio/openreferral-validator)

Open Referral datapackage code
- Repo containing some code exploring creating Open Referral Datapackages
- [Github](https://github.com/timgdavies/OpenReferralTests)

Open Referral Sample Data
- Repo of sample data for use in projects
- [Github](https://github.com/openreferral/sample-data)

Open Referral Gem
- This doesn't seem to have any actual code yet, but maybe the maintainer will update!
- [Github](https://github.com/omnilord/open-referral-gem)

Open Referral OpenAPI Specification
- [Docs](https://openreferral.readthedocs.io/en/latest/hsda/)
- [Githbu](https://github.com/openreferral/api-specification)

