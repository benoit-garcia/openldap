FROM		debian:latest
MAINTAINER 	Benoit <benoit@terra-art.net>

# Plain LDAP
EXPOSE		389

# Update package repository and install OpenLDAP 
RUN		LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y update && \
		LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y install slapd && \
		apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Remove default configuration
#RUN		/bin/rm -rf /etc/ldap/slapd.d/* /etc/ldap/ldap.conf

# Add response file for dpkg-reconfigure
ONBUILD		ADD slapd_config /tmp/slapd_config
ONBUILD		RUN mkdir -p /var/backups/slapd/
ONBUILD		RUN /usr/bin/debconf-set-selections /tmp/slapd_config

# Configure OpenLDAP
ONBUILD		RUN LC_ALL=C DEBIANT_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive slapd

# Create initial directory
ONBUILD		ADD create_private.ldif /tmp/create_private.ldif
ONBUILD		RUN /usr/sbin/slapadd -v -l /tmp/create_private.ldif
ONBUILD		RUN /usr/sbin/ldappasswd -xWD cn=admin,dc=exemple,dc=com -S uid=jsmith,ou=people,dc=exemple,dc=com

# Clean everything

# Last but least, unleach the daemon!
ENTRYPOINT	["/usr/sbin/slapd", "-u", "openldap", "-g", "openldap"]
CMD		["-d", "255"]
