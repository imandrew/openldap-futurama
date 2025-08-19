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

| Username | Title | Department | Manager | Groups |
|----------|-------|------------|---------|--------|
| fry | Delivery Boy | Delivery | leela | ship_crew, delivery_crew |
| leela | Ship Captain | Command | hermes | ship_crew, delivery_crew, management |
| bender | Ship Cook | Ship Operations | leela | ship_crew, delivery_crew |
| professor | CEO and Founder | Executive | - | scientists, management |
| amy | Intern | Engineering | leela | scientists, interns |
| hermes | Bureaucrat Grade 34 | Administration | professor | management, bureaucrats |
| zoidberg | Staff Doctor | Medical | professor | - |
| scruffy | Janitor | Maintenance | professor | - |
| nibbler | Ship Mascot | Operations | - | ship_crew |

## Organizational Hierarchy

```
Professor Farnsworth (CEO)
├── Hermes Conrad (Operations Manager)
│   └── Leela (Ship Captain)
│       ├── Fry (Delivery Boy)
│       ├── Bender (Ship Cook)
│       └── Amy Wong (Intern)
├── Dr. Zoidberg (Staff Doctor)
└── Scruffy (Janitor)

Nibbler (Independent - Ship Mascot/Secret Agent)
```

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

### Check User's Manager
```bash
ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w "GoodNewsEveryone" \
  -b "dc=planetexpress,dc=com" "(uid=fry)" manager
```

### Find Direct Reports
```bash
ldapsearch -x -H ldap://localhost \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w "GoodNewsEveryone" \
  -b "dc=planetexpress,dc=com" "(manager=uid=leela,ou=mutants,dc=planetexpress,dc=com)" uid cn title
```

## AD Compatibility Features

- `sAMAccountName` attribute for all users
- `memberOf` overlay for automatic group membership
- AD-compatible `group` objectClass
- Standard AD group types
- `manager` attribute for organizational hierarchy
- `userPrincipalName` in user@domain format

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