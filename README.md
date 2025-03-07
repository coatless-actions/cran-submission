# R Package CRAN Submission Action

This GitHub Action automates the process of checking and submitting R packages to CRAN (The Comprehensive R Archive Network). 
It performs all necessary checks to ensure your package complies with CRAN policies and then submits it, creating an issue to track the submission status.

You can see a demo of this action in action [here][submit-cran-demo]. 

## Usage

Add this to your repository's workflow:

```yaml
name: Submit to CRAN

on:
  workflow_dispatch: {}   # Allow manual triggering
  release:
    types: [prereleased]   # Or trigger on publish

jobs:
  cran-submission:
    runs-on: ubuntu-latest
    name: Submit package to CRAN
    permissions:
      contents: read
      issues: write                # Needed to create issues
    steps:
      - uses: actions/checkout@v4
      
      - name: Submit R package to CRAN
        uses: coatless-actions/cran-submission@v1
        with:
          pkg-directory: '.'       # Directory containing the package
          check-directory: 'check' # Directory for check outputs
          error-on: 'warning'      # Fail on warnings
          create-issue: true       # Create issues to track submissions
```

## Inputs

| Name               | Description                                       | Required | Default   |
|--------------------|---------------------------------------------------|----------|-----------|
| `pkg-directory`    | Directory containing the R package                | No       | `.`       |
| `check-directory`  | Directory for check outputs                       | No       | `check`   |
| `error-on`         | Stop on warnings or errors ("warning" or "error") | No       | `warning` |
| `upload-snapshots` | Whether to upload snapshots of failing tests      | No       | `true`    |
| `create-issue`     | Create a GitHub issue for the submission          | No       | `true`    |
| `r-version`        | R version to use                                  | No       | `release` |


## Outputs

| Name                | Description                           |
|---------------------|---------------------------------------|
| `pkg-name`          | Package name                          |
| `pkg-version`       | Package version                       |
| `maintainer-name`   | Maintainer name                       |
| `maintainer-email`  | Maintainer email                      |
| `submission-status` | Submission status (success or failed) |
| `tarball-path`      | Path to the package tarball           |

## License

[MIT](LICENSE)

[submit-cran-demo]: https://github.com/coatless-r-n-d/submit-cran-gh-action-check