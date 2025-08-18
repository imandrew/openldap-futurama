# OpenLDAP Futurama Test Server

An OpenLDAP container pre-populated with Futurama characters for testing LDAP integrations. Includes Active Directory compatibility features.

**⚠️ Test/development only - hardcoded credentials**

## Quick Start

```bash
# Using Docker
docker run -d -p 389:389 ghcr.io/imandrew/openldap-futurama:latest

# Using local build
make start
```

## Connection Details

- **Server**: `ldap://localhost:389`
- **Base DN**: `dc=planetexpress,dc=com`
- **Admin DN**: `cn=admin,dc=planetexpress,dc=com`
- **Admin Password**: `GoodNewsEveryone`

## Test Users

All users have password matching their username (e.g., username: `fry`, password: `fry`):

| Username | Email | Groups |
|----------|-------|--------|
| fry | fry@planetexpress.com | ship_crew, delivery_crew |
| leela | leela@planetexpress.com | ship_crew, delivery_crew, management |
| bender | bender@planetexpress.com | ship_crew, delivery_crew |
| professor | professor@planetexpress.com | scientists, management |
| amy | amy@planetexpress.com | scientists, interns |
| hermes | hermes@planetexpress.com | management, bureaucrats |
| zoidberg | zoidberg@planetexpress.com | - |
| scruffy | scruffy@planetexpress.com | - |
| nibbler | nibbler@planetexpress.com | ship_crew |

## Groups

| Group Name | Members | Description |
|------------|---------|-------------|
| ship_crew | fry, leela, bender, nibbler | Planet Express Ship Crew |
| delivery_crew | fry, leela, bender | Delivery Crew Members |
| scientists | professor, amy | Scientific Personnel |
| management | professor, hermes, leela | Management Team |
| interns | amy | Unpaid Interns |
| bureaucrats | hermes | Central Bureaucracy |

## Usage Examples

### Test User Authentication
```bash
ldapsearch -x -H ldap://localhost \
  -D "uid=fry,ou=people,dc=planetexpress,dc=com" \
  -w "fry" \
  -b "dc=planetexpress,dc=com" "(uid=fry)"
```

### Search by Email
```bash
ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w "GoodNewsEveryone" \
  -b "dc=planetexpress,dc=com" "(mail=leela@planetexpress.com)"
```

### List Group Members
```bash
ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w "GoodNewsEveryone" \
  -b "cn=ship_crew,ou=groups,dc=planetexpress,dc=com" member
```

### Check User's Groups (AD-style)
```bash
ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w "GoodNewsEveryone" \
  -b "dc=planetexpress,dc=com" "(sAMAccountName=fry)" memberOf
```

## AD Compatibility Features

- `sAMAccountName` attribute for all users
- `memberOf` overlay for automatic group membership
- AD-compatible `group` objectClass
- Standard AD group types

## Docker Image

```bash
docker pull ghcr.io/imandrew/openldap-futurama:latest
```

## Local Commands

```bash
make build    # Build container
make start    # Start server
make stop     # Stop server
make test     # Run tests
make logs     # View logs
make shell    # Container shell
```

## License

MIT