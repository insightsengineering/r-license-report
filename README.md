# R Package Github Actions

This is a suite of GitHub Actions to make R package development more effective.

GitHub Actions are a way to make automated workflows that trigger when events occur on your GitHub repository, using a YAML file that lives in your repo. These actions can be used to easily perform routine tasks as part of your package development workflow.

## Actions

See the documentation for the available actions:

* [generate-news](generate-news)
* [generate-sticker](generate-sticker)
* [goodpractice](goodpractice)
* [license-report](license-report)
* [multiversion-docs](multiversion-docs)
* [package-release](package-release)
* [version-bump](version-bump)
* [vulnerability-report](vulnerability-report)

## Usage

These actions can be added as steps to your own workflow files. GitHub reads workflow files from `.github/workflows/` within your repository. See the [Github Actions workflow documentation](https://docs.github.com/en/actions/learn-github-actions#about-workflows) for details on writing workflows.

Here are some examples of how these actions can be used in workflows.

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE).
