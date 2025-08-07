# OpenLDAP Futurama Test Server

A Wolfi-based OpenLDAP container pre-populated with Futurama characters for testing LDAP integrations. Built on Chainguard's secure Wolfi base image with Active Directory compatibility.

**⚠️ Development/testing container with hardcoded credentials - not for production use.**

## Quick Start

```bash
# Run from GitHub Container Registry
docker run -d -p 389:389 --name openldap-futurama ghcr.io/imandrew/openldap-futurama:latest

# Test connectivity
ldapsearch -x -H ldap://localhost -D "cn=admin,dc=planetexpress,dc=com" -w "GoodNewsEveryone" -b "dc=planetexpress,dc=com" "(uid=fry)" cn
```

**Server Details:**
- **LDAP**: `ldap://localhost:389`
- **Base DN**: `dc=planetexpress,dc=com`
- **Admin**: `cn=admin,dc=planetexpress,dc=com`
- **Password**: `GoodNewsEveryone`

### Local Development (with phpLDAPadmin)

```bash
# Build and start with docker-compose (includes web UI)
make start

# phpLDAPadmin available at http://localhost:8080
make test  # Run tests
```

## Features

- **🛡️ Secure**: Wolfi-based minimal container with automatic security scanning
- **🔄 AD Compatible**: `sAMAccountName`, `userPrincipalName`, `memberOf` overlay
- **📊 Pre-populated**: Futurama characters, groups, and departments
- **🚀 Testing Ready**: Perfect for LDAP integration testing
- **🏗️ Multi-arch**: AMD64 and ARM64 support

## Test Data

### Users
All users have **password = username** (e.g., `fry`/`fry`):

| Username | Name | Department |
|----------|------|------------|
| fry | Philip J. Fry | Delivery Boy |
| leela | Turanga Leela | Ship Captain |
| bender | Bender Rodriguez | Robot Cook |
| professor | Prof. Farnsworth | CEO/Mad Scientist |
| amy | Amy Wong | Intern |
| hermes | Hermes Conrad | Bureaucrat |
| zoidberg | Dr. Zoidberg | Staff Doctor |
| scruffy | Scruffy Scruffington | Janitor |

### Groups
- `ship_crew` - Fry, Leela, Bender, Nibbler
- `delivery_crew` - Fry, Leela, Bender  
- `scientists` - Professor, Amy
- `management` - Professor, Hermes, Leela

## Usage Examples

### Basic Authentication Test
```bash
# Test user login
ldapsearch -x -H ldap://localhost \
  -D "uid=fry,ou=people,dc=planetexpress,dc=com" \
  -w "fry" "(uid=fry)"
```

### AD-Style Search
```bash
# Search by sAMAccountName with group membership
ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w "GoodNewsEveryone" \
  "(sAMAccountName=bender)" memberOf
```

### Group Members
```bash
# Find all ship crew members
ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w "GoodNewsEveryone" \
  -b "cn=ship_crew,ou=groups,dc=planetexpress,dc=com"
```

## Directory Structure

```
dc=planetexpress,dc=com
├── ou=people      # Human employees
├── ou=robots      # Robot employees  
├── ou=mutants     # Mutant employees
├── ou=groups      # Organizational groups
└── ou=departments # Company departments
```

## Container Registry

**Available Images:**
- `ghcr.io/imandrew/openldap-futurama:latest` (latest release)
- `ghcr.io/imandrew/openldap-futurama:v1.0.0` (specific versions)

Images are automatically built with security scanning and published on releases.

## Development

**Requirements:** Docker, docker-compose

```bash
make start    # Build and start with phpLDAPadmin
make test     # Run LDAP tests
make logs     # View container logs
make shell    # Shell access
make down     # Stop and clean up
```

## Technical Details

**Active Directory Compatibility:**
- `sAMAccountName` - Short login names (indexed)
- `userPrincipalName` - user@domain format (indexed)
- `memberOf` overlay - Automatic group membership
- `refint` overlay - Referential integrity

**Persistence:**
- `/var/lib/openldap` - Database files
- `/etc/openldap/slapd.d` - Configuration

Perfect for testing authentication systems, directory integrations, or anything needing a populated LDAP server with realistic data! 🚀