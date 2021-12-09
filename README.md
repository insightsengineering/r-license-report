[![SuperLinter](https://github.com/insightsengineering/r-license-report/actions/workflows/lint.yaml/badge.svg)](https://github.com/insightsengineering/r-license-report/actions/workflows/lint.yaml)
[![License report action test](https://github.com/insightsengineering/r-license-report/actions/workflows/test-license-report.yaml/badge.svg)](https://github.com/insightsengineering/r-license-report/actions/workflows/test-license-report.yaml)

<!-- BEGIN_ACTION_DOC -->
# R Dependency License Report

### Description
A Github Action that generates a license report of an R package's dependencies for continuous compliance.

### Action Type
Docker

### Author
Insights Engineering

### Inputs
* `path`:

  _Description_: Path to package's root

  _Required_: `false`

  _Default_: `.`

* `regex`:

  _Description_: Regex used for flagging packages with non-compliant licenses

  _Required_: `false`

  _Default_: `""`

* `fail`:

  _Description_: Fail with a non-zero exit code if one or more dependencies are flagged by the regex

  _Required_: `false`

  _Default_: `True`

* `rspm_snapshot_date`:

  _Description_: RSPM snapshot date (in the YYYY-MM-DD format) for package metadata retrieval. Defaults to current date

  _Required_: `false`

  _Default_: `""`

* `bioc_release`:

  _Description_: BioConductor release version for package metadata retrieval

  _Required_: `false`

  _Default_: `release`

### Outputs
None
<!-- END_ACTION_DOC -->

## How to use

To use this GitHub Action you will need to complete the following:

* Create a new file in your repository called `.github/workflows/r-license-report.yml`
* Copy the quickstart workflow from below into that new file, no extra configuration required
* Commit that file to a new branch
* Open up a pull request and observe the action working
* Review the output of the action as needed

### Quickstart

In your repository you should have a `.github/workflows/r-license-report.yml` folder with GitHub Action similar to below:

```yaml
---
name: License Report

on:
  push:
    branches-ignore: [main]
  pull_request:
    branches: [main]

jobs:
  license-report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: License Report
        uses: insightsengineering/r-license-report@main
```

### Complete example

The following workflow is a complete example that highlights the available options in this Action:

```yaml
---
name: License Compliance Check

on:
  push:
    branches-ignore: [main]
  pull_request:
    branches: [main]

jobs:
  license-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: License Report
        uses: insightsengineering/r-license-report@main
        with:
          # R package root path, in case your R package is within a subdirectory of the repo
          path: "."
          # A regular expression that can be used for matching and flagging non-compliant licenses
          regex: "^GPL.*"
          # Fail the action if 1 or more matching non-compliant licenses are found
          fail: true
          # Select an RSPM snapshot date for CRAN dependency metadata retrieval
          rspm_snapshot_date: "2021-06-28"
          # Select a Bioconductor release version for BioC dependency metadata retrieval
          bioc_release: "3.14"
```
