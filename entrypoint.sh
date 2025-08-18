#!/bin/sh
set -e

echo "Good news, everyone! Initializing OpenLDAP Planet Express server..."

# Bootstrap LDAP data on first run
if [ ! -f /var/lib/openldap/.futurama-initialized ]; then
    echo "Setting up OpenLDAP configuration..."
    
    # Initialize the MDB database directory
    mkdir -p /etc/openldap/slapd.d /var/lib/openldap/openldap-data
    
    # Convert slapd.conf to cn=config format
    slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
    
    # Start slapd temporarily to configure database
    echo "Configuring database and overlays..."
    slapd -F /etc/openldap/slapd.d -h "ldapi:///" -d 0 &
    SLAPD_PID=$!
    
    # Wait for socket to be ready
    for i in 1 2 3 4 5; do
        if [ -S /var/run/openldap/ldapi ]; then
            break
        fi
        echo "Waiting for slapd to start..."
        sleep 1
    done
    
    # Add database configuration with AD compatibility
    ldapadd -x -D "cn=admin,cn=config" -w GoodNewsEveryone -H ldapi:/// -f /usr/share/openldap-futurama/00-mdb-overlay.ldif
    
    # Load all data in one batch
    echo "Loading Planet Express directory data..."
    cat /usr/share/openldap-futurama/01-base-structure.ldif \
        /usr/share/openldap-futurama/02-users.ldif \
        /usr/share/openldap-futurama/03-groups.ldif | \
        ldapadd -x -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone -H ldapi:///
    
    # Stop temporary slapd
    kill -TERM $SLAPD_PID 2>/dev/null || true
    wait $SLAPD_PID 2>/dev/null || true
    
    # Mark as initialized
    touch /var/lib/openldap/.futurama-initialized
    echo "Initialization complete!"
fi

echo "Starting OpenLDAP server..."
exec slapd -F /etc/openldap/slapd.d -h "ldap://0.0.0.0:389/ ldapi:///" -d "${LDAP_LOG_LEVEL:-256}"