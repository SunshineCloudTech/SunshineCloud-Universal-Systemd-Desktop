
# Micromamba

Installs micromamba, a fast cross-platform package manager for conda environments.

## Usage

```json
"features": {
    "ghcr.io/mamba-org/devcontainer-features/micromamba:1": {}
}
```

## Options

| Option | Description | Type | Default |
|--------|-------------|------|---------|
| version | Exact version to install (X.Y.Z format) | string | latest |
| allowReinstall | Reinstall if already exists | boolean | false |
| autoActivate | Auto activate base environment | boolean | true |
| channels | Space-separated list of conda channels | string | - |
| packages | Space-separated list of packages to install | string | - |
| envFile | Path to environment file in container | string | - |
| envName | Environment name for envFile | string | - |

## Channel Configuration

Default channel configuration:

```json
"features": {
  "ghcr.io/mamba-org/devcontainer-features/micromamba:1": {
    "channels": "conda-forge"
  }
}
```

## Package Installation

Install packages during build:

Specify package names separated by **spaces** in the `packages` option.

For example, specify like the following installs `python>=3.11,<3.12` and `r-base`.

```json
"features": {
  "ghcr.io/mamba-org/devcontainer-features/micromamba:1": {
    "channels": "conda-forge",
```json
"features": {
  "ghcr.io/mamba-org/devcontainer-features/micromamba:1": {
    "packages": "python>=3.11,<3.12 r-base jupyter"
  }
}
```

## Environment File Support

Create environments from specification files:

```json
"features": {
  "micromamba": {
    "envFile": "/tmp/environment.yml",
    "envName": "myenv"
  }
}
```

Example environment.yml:

```yaml
name: myenv
channels:
  - conda-forge
dependencies:
  - python=3.11
  - numpy
  - pandas
  - jupyter
```

## Version Requirements

Version must be specified in full X.Y.Z format. Partial versions like "1" or "1.0" are not supported.

## Notes

This feature integrates with the SunshineCloud Universal Desktop environment to provide conda package management capabilities for AI/ML and data science workflows.
