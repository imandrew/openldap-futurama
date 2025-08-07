.PHONY: start stop down test test-user shell logs help

help:
	@echo "OpenLDAP Futurama Test Server"
	@echo "Available targets:"
	@echo "  make start    - Build and start the container with docker-compose"
	@echo "  make stop     - Stop the container"
	@echo "  make down     - Stop and remove containers and volumes"
	@echo "  make test     - Test LDAP connectivity and search users"
	@echo "  make test-user - Test specific user with AD attributes"
	@echo "  make shell    - Open shell in running container"
	@echo "  make logs     - View container logs"

# Build and start the container using docker-compose
start:
	@echo "Starting OpenLDAP Futurama server..."
	docker-compose up -d --build
	@echo ""
	@echo "Good news, everyone! LDAP is running:"
	@echo "  LDAP Server: ldap://localhost:389"
	@echo "  phpLDAPadmin: http://localhost:8080"
	@echo "  Base DN: dc=planetexpress,dc=com"
	@echo "  Admin: cn=admin,dc=planetexpress,dc=com"
	@echo "  Password: GoodNewsEveryone"

# Stop the container
stop:
	@echo "Shutting down Futurama LDAP..."
	docker-compose down

# Stop and remove containers and volumes
down:
	@echo "Stopping and removing containers and volumes..."
	docker-compose down -v

# Test LDAP connectivity and search for Futurama characters
test:
	@echo "Testing LDAP connectivity..."
	@echo ""
	@echo "Searching for all users:"
	@docker exec openldap-futurama ldapsearch -x -H ldap://localhost \
		-b "dc=planetexpress,dc=com" \
		-D "cn=admin,dc=planetexpress,dc=com" \
		-w "GoodNewsEveryone" \
		"(objectClass=inetOrgPerson)" cn mail sAMAccountName || echo "Test failed - is the container running?"
	@echo ""
	@echo "Searching for ship crew members:"
	@docker exec openldap-futurama ldapsearch -x -H ldap://localhost \
		-b "cn=ship_crew,ou=groups,dc=planetexpress,dc=com" \
		-D "cn=admin,dc=planetexpress,dc=com" \
		-w "GoodNewsEveryone" \
		"(objectClass=*)" || echo "Group search failed"

# Test specific user with memberOf
test-user:
	@echo "Testing Bender's account and group membership:"
	@docker exec openldap-futurama ldapsearch -x -H ldap://localhost \
		-b "uid=bender,ou=robots,dc=planetexpress,dc=com" \
		-D "cn=admin,dc=planetexpress,dc=com" \
		-w "GoodNewsEveryone" \
		"(objectClass=*)" cn mail sAMAccountName memberOf || echo "User test failed"

# Open shell in the running container
shell:
	@echo "Opening shell in OpenLDAP Futurama container..."
	docker exec -it openldap-futurama /bin/bash

# View container logs
logs:
	docker-compose logs -f openldap-futurama
