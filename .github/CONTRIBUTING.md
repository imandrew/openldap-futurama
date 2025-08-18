# Contributing to OpenLDAP Futurama Test Server

## Development Setup

1. Clone the repository
2. Make sure Docker is installed
3. Run `make build` to build the container
4. Run `make test` to run tests

## Making Changes

1. Create a feature branch
2. Make your changes
3. Test locally with `make test`
4. Submit a pull request

## Release Process

Releases are created by tagging:

```bash
# Tag a new version
git tag v1.0.0
git push origin v1.0.0
```

This will trigger the GitHub Actions workflow that:
1. Builds the Docker image
2. Pushes to GitHub Container Registry as:
   - `ghcr.io/[owner]/openldap-futurama:v1.0.0`
   - `ghcr.io/[owner]/openldap-futurama:latest`
3. Creates a GitHub release

### Manual Release
You can also trigger a release manually from the GitHub Actions tab by running the "Release" workflow and specifying a version.
