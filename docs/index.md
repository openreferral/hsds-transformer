---
layout: default
title: HSDS Transformer
---

# Why use the HSDS Transformer?
The Human Services Data Spec (HSDS) is a data format that enables you to share community resource information in a standardized, interoperable way, so that other users, organizations, or systems can easily use or share your data, ultimately to help more people in need.

If you have community resource data that you want to convert to the HSDS format, you can use the HSDS Transformer.

## Who made the HSDS Transformer?
The HSDS Transformer is a tool built by the [Open Referral](https://openreferral.org/) initiative. Open Referral's mission is to develop data standards and open source tools that make it easier to share, find and use information about health, human, and social services.

# What do you need to use the HSDS Transformer?

From a skills perspective, if you want to use the HSDS Transformer as a Ruby library, you will need familiarity with the Ruby programming language. 

If you are not a Rubyist and/or you want to use the HSDS Transformer as an HTTP API (so that you can interact with it using HTTP requests), you will need to be familiar with Docker so that you can build and serve the API locally or in the cloud. Check out the [README](https://github.com/openreferral/hsds-transformer/blob/master/README.md) for more info on getting started.

From a data and file perspective, you need your data available as CSVs in a single directory and you will need to create a mapping file.

### The Mapping

You will need to create a mapping.yaml file. This file should be written in [YAML](https://yaml.org/) and should map your data fields to HSDS data fields. Your mapping file should contain a top level entry for every file name in the source data directory that you wish to convert. Then, each file section should have a `columns` section that lists the headers in that source CSV that you wish to map to HSDS fields.

For example, a mapping for a source CSV that is named organizations.csv might look like this:

```
organizations.csv:
  columns:
    Organization ID:
      - model: organizations
        field: id
        required: true
      - model: phones
        field: organization_id
    Title:
      model: organizations
      field: name
    Phone number:
      model: phones
      field: number
```

In this case, the source CSV has three columns: `Organization ID`, `Title`, and `Phone number`.

The `Organization ID` corresponds directly to the `id` field in the HSDS `organizations` model.

Because this CSV also has a phone number and in HSDS, phone numbers are stored in a separate model and therefore CSV file, we need to specify that the phone number and the reference to the organization it belongs to should populate the `phones` model. Therefore, we include a mapping under `Organization ID` to the `phones` model and corresponding field `organization_id`. We also map the `Phone number` field in the source CSV to the HSDS `phones` model and `number` field.

In this example, the `Title` column in the source CSV has only one mapping and it is pretty straightforward: it maps to the `name` field in the HSDS `organizations` model.

When the transformer is run with this source CSV and this mapping, the output will be a datapackage with two CSVs (phones.csv and organizations.csv) and a datapackage.json describing the two CSVs: `organizations.csv` with two fields, `organization_id` and `name`, and `phones.csv` with two fields, `number` and `organization_id`.

See this [example](https://github.com/openreferral/hsds-transformer/blob/master/spec/fixtures/base_transformer/mapping.yaml) for a more complex mapping with multiple source CSVs and HSDS models.

# Get Involved

Want to get involved with this tool or other projects by Open Referral? Find out how to get in touch [here](https://openreferral.org/get-involved/).

Begin contributing to this tool today by submitting a pull request on Github. Check out our [Contributing guidelines](https://github.com/openreferral/hsds-transformer/blob/master/CONTRIBUTING.md) to get started.