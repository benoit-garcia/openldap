FROM		debian:latest
MAINTAINER 	Benoit <benoit@terra-art.net>

# We communicate on LDAP standard port
EXPOSE		389

# Update package repository and install OpenLDAP 
RUN		LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN		LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
RUN		LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y install slapd

# Remove default configuration
RUN		/bin/rm -rf /etc/ldap/slapd.d/* /etc/ldap/ldap.conf

# Add response file for dpkg-reconfigure
ADD		slapd_config /tmp/slapd_config
RUN		mkdir -p /var/backups/slapd/
RUN		/usr/bin/debconf-set-selections /tmp/slapd_config

# Configure OpenLDAP
RUN		LC_ALL=C DEBIANT_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive slapd

# Create initial directory
ADD		create_private.ldif /tmp/create_private.ldif
RUN		/usr/sbin/slapadd -v -l /tmp/create_private.ldif

# Clean anything
RUN		apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Last but least, unleach the daemon!
CMD		["-d", "255"]
ENTRYPOINT	["/usr/sbin/slapd", "-u", "openldap", "-g", "openldap"]


