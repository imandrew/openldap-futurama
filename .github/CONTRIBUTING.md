# Contributing to Futurama LDAP Test Server

## Commit Message Format

We use [Conventional Commits](https://conventionalcommits.org/) for automated changelog generation.

### Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `test:` - Adding or updating tests
- `build:` - Build system changes
- `ci:` - CI/CD changes
- `chore:` - Other changes (dependencies, etc.)

### Examples
```bash
feat: add memberOf overlay support
fix: resolve schema loading issue
docs: update README with new features
refactor: move config to bootstrap directory
ci: add multi-architecture container builds
```

### Breaking Changes
For breaking changes, add `!` after type or add `BREAKING CHANGE:` in footer:

```bash
feat!: change default admin password format
```

### Scopes (Optional)
- `container` - Container/Docker related
- `ldap` - LDAP configuration
- `schema` - LDAP schema changes
- `docs` - Documentation
- `ci` - GitHub Actions/CI

### Labels for PR Categorization

Add these labels to PRs for proper changelog categorization:

- `breaking` or `breaking-change` - Breaking changes
- `feature` or `enhancement` - New features
- `bug` or `fix` - Bug fixes
- `improvement` or `refactor` - Code improvements
- `documentation` or `docs` - Documentation updates
- `security` - Security fixes
- `dependencies` - Dependency updates
- `test` - Testing improvements
- `ci` - CI/CD improvements

## Release Process

Releases are automated using the `release.sh` script:

```bash
./release.sh v1.0.0
```

The script will:
1. Validate version format (must be v1.2.3 format)
2. Create and push git tag
3. Trigger automated GitHub Actions workflow that:
   - Generates changelog from commits/PRs
   - Creates GitHub release with changelog
   - Builds multi-arch containers (AMD64/ARM64)
   - Pushes to GitHub Container Registry as:
     - `ghcr.io/imandrew/openldap-futurama:v1.0.0`
     - `ghcr.io/imandrew/openldap-futurama:latest`
   - Tests container functionality

After running the script, monitor progress at:
- **GitHub Actions**: https://github.com/imandrew/openldap-futurama/actions
- **Release Page**: https://github.com/imandrew/openldap-futurama/releases

### Alternative Methods
```bash
# Manual tag creation
git tag v1.0.0 && git push origin v1.0.0

# Use GitHub CLI
gh release create v1.0.0 --generate-notes
```
