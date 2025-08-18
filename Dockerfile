FROM cgr.dev/chainguard/wolfi-base:latest

RUN apk add --no-cache \
    openldap \
    openldap-clients \
    openldap-back-mdb \
    openldap-overlay-memberof \
    openldap-overlay-refint \
    busybox \
    && mkdir -p /etc/openldap/schema \
               /var/lib/openldap/openldap-data \
               /var/lib/openldap/run \
               /var/run/openldap \
               /usr/share/openldap-futurama \
    && chown -R nonroot:nonroot /etc/openldap \
                                /var/lib/openldap \
                                /var/run/openldap \
                                /usr/share/openldap-futurama \
    && chmod 700 /var/lib/openldap/openldap-data \
    && chmod 755 /etc/openldap/schema \
                 /var/run/openldap \
                 /usr/share/openldap-futurama

COPY --chown=nonroot:nonroot --chmod=644 config/slapd.conf /etc/openldap/slapd.conf
COPY --chown=nonroot:nonroot --chmod=644 config/ad-compat.schema /etc/openldap/schema/
COPY --chown=nonroot:nonroot --chmod=644 ldif/*.ldif /usr/share/openldap-futurama/
COPY --chown=root:root --chmod=755 entrypoint.sh /entrypoint.sh

ENV LDAP_LOG_LEVEL=256

USER nonroot

EXPOSE 389

ENTRYPOINT ["/entrypoint.sh"]