# HSDS Transformer
[![Build Status](https://travis-ci.com/openreferral/hsds-transformer.svg?branch=master)](https://travis-ci.com/openreferral/hsds-transformer)
## Overview
This app allows you to convert data into an HSDS-compliant [datapackage](https://frictionlessdata.io/specs/data-package/).

The [Human Services Data Specification (HSDS)](https://openreferral.readthedocs.io/en/latest/hsds/) is a data model that describes health and human services. 

This transformer currently transforms data into HSDS version 2.0.1.

### Problem statement
Lots of people have health and human services data, but it's all in different structures and formats. Many groups want to share their data, or use data that's shared with them, but the lack of standardized data or an easy way to standardize the data presents a major barrier.

### Solution
[Open Referral](https://openreferral.org/) provides a Human Services Data Specification that groups can use to share data via a common format. The HSDS Transformer tool (this project) enables a group or person to transform data into an HSDS-compliant data package, so that it can then be combined with other data or used in any number of applications.

### Case Study: Illinois Legal Aid Online (ILAO)
The real-world case that's motivating this project is [Illinois Legal Aid Online (ILAO)](https://www.illinoislegalaid.org/), an organization that helps individuals in Illinois find legal help or resources online. ILAO has a resource directory of community services data, and they'd like to update this data to be formatted in compliance with HSDS version 1.1. They also are looking to incorporate other data sets in disparate formats and structures into their own database in order to better serve Illinois residents with more extensive and more accurate information.

This project uses ILAO's resource database in the form of three CSVs as the test case. The data was pulled in January 2019, with some records not having been updated since 2017, and therefore some of the data may not be accurate or up-to-date. The data is located in `spec/fixtures/input`.

### Ideas for expansion
* Automate uploading to Airtable in the [Open Referral Human Services Template](https://airtable.com/universe/expwt9yr65lFGUJAr/social-services-directory-v20)
* Incorporate the [OpenReferral Validator](https://github.com/spilio/openreferral-validator) to automatically validate data input/output
* Plug into [API-in-a-Box](https://github.com/switzersc/api-in-a-box) to automatically create a hypermedia API on top of the created datapackage
* Create a client library to generate a search UI on top of the created datapackage.


## How to use this tool
First, double check whether your data is already HSDS-compliant with the [OpenReferral Validator](https://github.com/spilio/openreferral-validator).

If it is, voila!

If it's not, proceed.

Note: Your source data must live in a single directory and be stored as CSVs.

### Using this as a gem
Make sure you have `bundler` installed, and then run:
```
gem install hsds_transformer
```
or add `hsds_transformer` to your Gemfile.

Then you will be able to use the Transformer as documented below in "Transforming using the Ruby library". Instead of setting the `ROOT_PATH` env as the HSDS Transformer project directory, however, you will need to set this env variable as the path to the directory your source data is stored in. 

### Installing locally (not using as a gem)
1. Clone this repo locally.
2. In terminal, `cd` into the root of the hsds_transformer directory.
3. Create a new file called `.env`. Copy the contents of `.env.example` into the new `.env` file and update `Users/your_user/dev/hsds_transformer` to be the correct path to this directory on your local environment (you can run `pwd` in terminal to find this out).
4. Install all the gems by running `bundle install`


### Transforming using the Ruby library
If you're familiar with Ruby and you want to use this tool in the command line, you can open an IRB shell and require the library, and begin transforming data:

1. Make sure your data is saved locally as CSVs in the transformer directory (or whatever directory you set `ROOT_PATH` env variable to in step 3 above).
2. Create a mapping.yaml file and save it locally in the same directory. This is what tells the transformer how to map fields from one set of CSVs into the HSDS format. See [spec/fixtures/mapping.yaml](https://github.com/openreferral/hsds-transformer/blob/master/spec/fixtures/base_transformer/mapping.yaml) for an example.
3. Open up an interactive Ruby session in terminal by running `irb` (or `pry` - up to you!)
4. Require the class: `require "./lib/hsds_transformer"`
5. Run the transformer: 
```
HsdsTransformer::Runner.run(input_dir: "/path/to/input/", mapping: "/path/to/mapping.yaml", output_dir: "/path/to/output/")
```
6. Now check the `tmp` directory for your newly created HSDS files!

You can also pass two additional arguments to the `.run` command: `include_custom` and `zip_output`. The output is by default not zipped, but if you want it to be, you can pass `true` as the value of this argument:
```
HsdsTransformer::Runner.run(input_dir: "/path/to/input/", mapping: "/path/to/mapping.yaml", output_dir: "/path/to/output/", zip_output: true)
```

If your input data includes non-HSDS fields you want to see in the output files as well, you can pass `true` for `include_custom`.
```
HsdsTransformer::Runner.run(input_dir: "/path/to/input/", mapping: "/path/to/mapping.yaml", output_dir: "/path/to/output/", include_custom: true)
```

### Using the API without Docker

If you don't want to use this as a Ruby library, you can use it as an HTTP API. Start the API from the root of the project directory:

`rackup -p 4567`

Make a POST request with params: input_path, mapping, include_custom. Each of thse should contain a path to a CSV file and a mapping file (for mapping).

E.g.
```
curl -X POST -F "input_path=/Users/gwalchmai/Dev/hsds_transformer/spec/fixtures/input" -F "mapping=/Users/gwalchmai/Dev/hsds_transformer/spec/fixtures/mapping.yaml" http://localhost:4567/transform
```

The response will be a zip file of the transformed data. You can also pass add `-F "include_custom=true"` if your input data has custom non-HSDS columns you wish to include. 

The API then streams a zip file back with the properly transformed data. The zip is also saved locally on the API server (maybe your local env) at `data.zip` in the root directory

### Using the API with Docker
Before anything else, make sure you have docker installed and running.

First, build the image locally:

`docker build . -t transformer_api`

Now, run it:

`docker run -p 4567:4567 transformer_api`

You should now be able to interact with the API at `http://localhost:4567`.

### Custom Transformers
The BaseTransformer maps data from the input directory to compliant HSDS datapackage and CSVs using the mapping.yaml, and it requires a pretty one-to-one and straightforward mapping. You may need additional cleanup, parsing, or mapping, such as parsing out schedule text. If so, you can create a custom transformer and specify it when running the script or using the API. Check out the `lib/hsds_transformer/custom` directory for examples.

1. Write your custom transformation code.
1. Save it as a class in `lib/hsds_transformer/custom` following the naming conventions already there.
1. Add the class name to the array of valid custom transformers in the `HsdsTransformer::Runner` class.
1. Specify this custom transformer when invoking the transformer:

```
HsdsTransformer::Runner.run(custom_transformer: "Open211MiamiTransformer", input_dir: "/path/to/input/", mapping: "/path/to/mapping.yaml", output_dir: "/path/to/output/")
```

or when making a request to the API:

```
curl -X POST -F "custom_transformer=Open211MiamiTransformer" -F "input_path=/Users/gwalchmai/Dev/hsds_transformer/spec/fixtures/input" -F "mapping=/Users/gwalchmai/Dev/hsds_transformer/spec/fixtures/mapping.yaml" http://localhost:4567/transform
```

## Examples
You can find examples of data and mappings in the `examples` directory.

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

