#!/bin/bash
set -e

# Logging functions
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }
die() { log "ERROR: $*" >&2; exit 1; }

# Configuration
CONFIG_DIR="/etc/openldap/slapd.d"
DATA_DIR="/var/lib/openldap"

# Hardcoded configuration
LDAP_ADMIN_DN="cn=admin,dc=planetexpress,dc=com"
LDAP_ADMIN_PASSWORD="GoodNewsEveryone"

log "Starting OpenLDAP development server"

# Configuration setup function
setup_config() {
    log "Using hardcoded bootstrap config"
    if [ -f "/bootstrap/config/slapd.conf" ]; then
        cp /bootstrap/config/slapd.conf /tmp/config-only.conf
    else
        die "Bootstrap config not found at /bootstrap/config/slapd.conf"
    fi

    log "Converting config-only setup to cn=config format"
    slaptest -f /tmp/config-only.conf -F "$CONFIG_DIR" >/dev/null 2>&1 || die "Config conversion failed"
}

# MDB database setup function
setup_mdb_database() {
    log "Starting slapd in background to add MDB database"
    slapd -h "ldap:///" -F "$CONFIG_DIR" -d 0 &
    SLAPD_PID=$!
    sleep 5

    # Add MDB database
    if [ -f "/bootstrap/config/add-mdb.ldif" ]; then
        log "Adding MDB database via LDAP"
        ldapadd -x -H ldap://localhost:389 -D "cn=admin,cn=config" -w "$LDAP_ADMIN_PASSWORD" -f /bootstrap/config/add-mdb.ldif || die "Failed to add MDB database"
        log "MDB database added successfully"
    fi

    # Add memberOf overlay
    if [ -f "/bootstrap/config/add-memberof-overlay.ldif" ]; then
        log "Adding memberOf and refint overlays"
        ldapadd -x -H ldap://localhost:389 -D "cn=admin,cn=config" -w "$LDAP_ADMIN_PASSWORD" -f /bootstrap/config/add-memberof-overlay.ldif || log "Warning: MemberOf overlay failed"
        log "MemberOf overlay added successfully"
    fi
}

# Bootstrap data loading function
load_bootstrap_data() {
    log "Adding base DN"
    if [ -f "/bootstrap/config/base-dn.ldif" ]; then
        ldapadd -x -H ldap://localhost:389 -D "$LDAP_ADMIN_DN" -w "$LDAP_ADMIN_PASSWORD" -f /bootstrap/config/base-dn.ldif || log "Warning: Could not add base DN"
    fi

    # Load bootstrap data if available
    if [ -d "/bootstrap/data" ]; then
        log "Loading Futurama test data..."
        for ldif in /bootstrap/data/*.ldif; do
            [ -f "$ldif" ] || continue

            # Skip the base DN file since we already added it
            if [ "$(basename "$ldif")" = "00-base-dn.ldif" ]; then
                log "Skipping $(basename "$ldif") - already loaded"
                continue
            fi

            log "Loading $(basename "$ldif")..."

            # Add to database
            ldapadd -x -H ldap://localhost:389 -D "$LDAP_ADMIN_DN" -w "$LDAP_ADMIN_PASSWORD" -f "$ldif" || \
            log "Warning: Failed to load $(basename "$ldif")"
        done
    fi

    # Stop background slapd
    kill $SLAPD_PID 2>/dev/null || true
    wait $SLAPD_PID 2>/dev/null || true
}

# Initialize database function
initialize_database() {
    log "No existing database found, performing fresh initialization"

    # Clean slate for fresh install
    rm -rf "$CONFIG_DIR"/* "$DATA_DIR"/*

    # Bootstrap configuration
    setup_config

    # Setup MDB database
    setup_mdb_database

    # Load bootstrap data
    load_bootstrap_data
}

# Check if this is a fresh install or restart
if [ -f "$CONFIG_DIR/cn=config.ldif" ] && [ -f "$DATA_DIR/data.mdb" ]; then
    log "Existing database found, skipping initialization"
else
    initialize_database
fi

log "Starting slapd in foreground with MDB database and Futurama data"
exec slapd -h "ldap:///" -F "$CONFIG_DIR" -d 256
