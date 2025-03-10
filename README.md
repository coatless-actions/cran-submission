# R Package CRAN Submission Action

This GitHub Action automates the process of checking and submitting R packages to CRAN (The Comprehensive R Archive Network). 
It performs all necessary checks to ensure your package complies with CRAN policies and then submits it, creating an issue to track the submission status.

You can see a demo of this action in action [here][submit-cran-demo]. 

## Usage

Create a new [`submit-cran.yml` workflow](examples/submit-cran.yml) in your repository's  `.github/workflow` directory containing:

```yaml
name: Submit to CRAN

on:
  release:
    types: [prereleased]           # Only trigger on pre-releases

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

This workflow will trigger on pre-releases and submit the package to CRAN.

## Example

To begin, create a new release that is "pre-release" in your repository by selecting the "Draft a new release" button on the repository's "Releases" page ([GitHub Help: Managing releases in a repository](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository#creating-a-release)).

This will trigger the workflow and start the submission process.

For each submission, the action will create a new issue in the repository to track the submission status. The issue will indicate whether the submission was successful or failed and version information about the package.


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