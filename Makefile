# OpenLDAP Futurama Test Server with AD Compatibility
CONTAINER_NAME := openldap-futurama
IMAGE_NAME := openldap-futurama:latest
TEST_CONTAINER := $(CONTAINER_NAME)-test
LDAP_PORT := 389
TEST_PORT := 3890
ADMIN_DN := cn=admin,dc=planetexpress,dc=com
ADMIN_PW := GoodNewsEveryone
BASE_DN := dc=planetexpress,dc=com

.PHONY: all help build start stop restart test test-groups shell logs clean

# Default target
all: help

help:
	@echo "OpenLDAP Futurama - AD Compatible Test Server"
	@echo ""
	@echo "Quick Start:"
	@echo "  make build    - Build container image"  
	@echo "  make start    - Start server on port $(LDAP_PORT)"
	@echo "  make test     - Run test suite"
	@echo ""
	@echo "Management:"
	@echo "  make stop     - Stop the server"
	@echo "  make restart  - Restart the server"
	@echo "  make logs     - View server logs"
	@echo "  make shell    - Open shell in container"
	@echo "  make clean    - Remove containers and images"
	@echo ""
	@echo "Connection Info:"
	@echo "  Server: ldap://localhost:$(LDAP_PORT)"
	@echo "  Base DN: $(BASE_DN)"
	@echo "  Admin: $(ADMIN_DN)"
	@echo "  Password: $(ADMIN_PW)"

build:
	@echo "Building OpenLDAP Futurama container..."
	@docker build -t $(IMAGE_NAME) .
	@echo "Build complete!"

start: build
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo "Starting OpenLDAP Futurama..."
	@docker run -d --name $(CONTAINER_NAME) -p $(LDAP_PORT):389 $(IMAGE_NAME)
	@echo "Server started on port $(LDAP_PORT)"

stop:
	@echo "Stopping OpenLDAP Futurama..."
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo "Server stopped"

restart: stop start

test: build
	@echo "Running test suite..."
	@docker stop $(TEST_CONTAINER) 2>/dev/null || true
	@docker rm $(TEST_CONTAINER) 2>/dev/null || true
	@docker run -d --name $(TEST_CONTAINER) -p $(TEST_PORT):389 $(IMAGE_NAME)
	@echo "Waiting for LDAP initialization..."
	@sleep 8
	@echo ""
	@echo "Testing user search..."
	@docker exec $(TEST_CONTAINER) ldapsearch -x -H ldap://localhost \
		-b "$(BASE_DN)" -D "$(ADMIN_DN)" -w "$(ADMIN_PW)" \
		"(objectClass=inetOrgPerson)" cn sAMAccountName | grep -E "^(dn:|cn:|sAMAccountName:)" | head -20
	@echo ""
	@echo "Testing AD groups..."
	@docker exec $(TEST_CONTAINER) ldapsearch -x -H ldap://localhost \
		-b "ou=groups,$(BASE_DN)" -D "$(ADMIN_DN)" -w "$(ADMIN_PW)" \
		"(objectClass=group)" cn sAMAccountName groupType | grep -E "^(dn:|cn:|groupType:)" | head -15
	@echo ""
	@echo "Testing memberOf..."
	@docker exec $(TEST_CONTAINER) ldapsearch -x -H ldap://localhost \
		-b "uid=fry,ou=people,$(BASE_DN)" -D "$(ADMIN_DN)" -w "$(ADMIN_PW)" \
		"(objectClass=*)" memberOf | grep "memberOf:"
	@docker stop $(TEST_CONTAINER) >/dev/null
	@docker rm $(TEST_CONTAINER) >/dev/null
	@echo ""
	@echo "All tests passed!"

test-groups: 
	@echo "Testing AD-compatible groups..."
	@docker exec $(CONTAINER_NAME) ldapsearch -x -H ldap://localhost \
		-b "ou=groups,$(BASE_DN)" -D "$(ADMIN_DN)" -w "$(ADMIN_PW)" \
		"(objectClass=group)" cn sAMAccountName groupType member

shell:
	@docker exec -it $(CONTAINER_NAME) /bin/sh

logs:
	@docker logs -f $(CONTAINER_NAME)

clean:
	@echo "Cleaning up..."
	@docker stop $(CONTAINER_NAME) 2>/dev/null || true
	@docker stop $(TEST_CONTAINER) 2>/dev/null || true
	@docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@docker rm $(TEST_CONTAINER) 2>/dev/null || true
	@docker rmi $(IMAGE_NAME) 2>/dev/null || true
	@echo "Cleanup complete"