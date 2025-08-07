FROM cgr.dev/chainguard/wolfi-base:latest

# Install OpenLDAP packages including backends and overlays
RUN apk update && apk add --no-cache \
    openldap \
    openldap-clients \
    openldap-back-mdb \
    openldap-overlay-memberof \
    openldap-overlay-refint \
    bash

# Create openldap user and directories
RUN addgroup -g 389 openldap && \
    adduser -u 389 -G openldap -h /var/lib/openldap -s /bin/bash -D openldap && \
    mkdir -p /var/lib/openldap /etc/openldap/slapd.d /run/openldap && \
    chmod 700 /var/lib/openldap && \
    chmod 750 /etc/openldap/slapd.d && \
    chown -R openldap:openldap /var/lib/openldap /etc/openldap /run/openldap

# Copy bootstrap files and entrypoint with proper ownership
COPY --chown=openldap:openldap bootstrap/ /bootstrap/
COPY --chown=openldap:openldap bootstrap/schema/*.schema /etc/openldap/schema/
COPY --chown=openldap:openldap --chmod=755 entrypoint.sh ./entrypoint.sh

# Switch to non-root user
USER openldap

EXPOSE 389
ENTRYPOINT ["./entrypoint.sh"]
