# Actions

Reusable actions monorepo.

Check the workflows on this repository for examples on how to use each of these images.
A stub service is always deployed by the `feature-preview`, `staging` and `production` workflows, as shown on the [Deployments Page](https://github.com/modustack/actions/deployments).

## Contributing

Pre-requisites:
- [Taskfile](https://taskfile.dev/#/installation)
- [pre-commit](https://pre-commit.com/#install)
- [GitHub CLI](https://cli.github.com/)

To get started, run the following command:

```bash
task init
```

This will setup the pre-commit hooks and install the necessary dependencies.

The project uses [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/#summary), and they're enforced by pre-commit hooks. Ensure you familiarize yourself with its concepts.

You can run all the repo's tests via

```bash
task test

# example for specific action
# all bash tests must be under a <action-folder>/test folder
task test -- get-release-pr
```
