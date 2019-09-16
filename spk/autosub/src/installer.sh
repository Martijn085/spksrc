#!/bin/sh

# Package
PACKAGE="autosub"
DNAME="AutoSub"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
SSS="/var/packages/${PACKAGE}/scripts/start-stop-status"
PYTHON_DIR="/usr/local/python"
PATH="${INSTALL_DIR}/sbin:${PYTHON_DIR}/bin:/bin:/usr/bin:/usr/syno/bin"
VIRTUALENV="${PYTHON_DIR}/bin/virtualenv"
TMP_DIR="${SYNOPKG_PKGDEST}/../../@tmp"
SERVICETOOL="/usr/syno/bin/servicetool"
BUILDNUMBER="$(/bin/get_key_value /etc.defaults/VERSION buildnumber)"
FWPORTS="/var/packages/${PACKAGE}/conf/${PACKAGE}.sc"

DSM6_UPGRADE="${INSTALL_DIR}/.dsm6_upgrade"
SC_USER="sc-autosub"
SC_GROUP="sc-download"
SC_GROUP_DESC="SynoCommunity Package Group"
LEGACY_USER="autosub"
LEGACY_GROUP="users"
USER="$([ "${BUILDNUMBER}" -ge "7321" ] && echo -n ${SC_USER} || echo -n ${LEGACY_USER})"

CFG_FILE="${INSTALL_DIR}/config.properties"
CFG_FILES="/var/packages/${PACKAGE}/target"


syno_group_create ()
{
    # Create syno group
    synogroup --add ${SC_GROUP} ${USER} > /dev/null
    # Set description of the syno group
    synogroup --descset ${SC_GROUP} "${SC_GROUP_DESC}"
    # Add user to syno group
    addgroup ${USER} ${SC_GROUP}
}

syno_group_remove ()
{
    # Remove user from syno group
    delgroup ${USER} ${SC_GROUP}
    # Check if syno group is empty
    if ! synogroup --get ${SC_GROUP} | grep -q "0:"; then
        # Remove syno group
        synogroup --del ${SC_GROUP} > /dev/null
    fi
}


preinst ()
{
	exit 0
}

postinst ()
{
    # Link
    ln -s ${SYNOPKG_PKGDEST} ${INSTALL_DIR}

    # Create a Python virtualenv
    ${VIRTUALENV} --system-site-packages ${INSTALL_DIR}/env > /dev/null

    # Create legacy user
    if [ "${BUILDNUMBER}" -lt "7321" ]; then
        adduser -h ${INSTALL_DIR} -g "${DNAME} User" -G ${LEGACY_GROUP} -s /bin/sh -S -D ${LEGACY_USER}
    fi

    syno_group_create

    # Correct the files ownership
    chown -R ${USER}:root ${SYNOPKG_PKGDEST}

    # Add firewall config
    ${SERVICETOOL} --install-configure-file --package ${FWPORTS} >> /dev/null

    exit 0
}

preuninst ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    if [ "${SYNOPKG_PKG_STATUS}" != "UPGRADE" ]; then
        # Remove the user (if not upgrading)
        syno_group_remove
        delgroup ${LEGACY_USER} ${LEGACY_GROUP}
        deluser ${USER}

        # Remove firewall configuration
        ${SERVICETOOL} --remove-configure-file --package ${PACKAGE}.sc >> /dev/null
    fi

    exit 0
}


postuninst ()
{
	# Remove link
	rm -f ${INSTALL_DIR}

	exit 0
}

preupgrade ()
{
    # Stop the package
    ${SSS} stop > /dev/null

    # DSM6 Upgrade handling
    if [ "${BUILDNUMBER}" -ge "7321" ] && [ ! -f ${DSM6_UPGRADE} ]; then
        echo "Deleting legacy user" > ${DSM6_UPGRADE}
        delgroup ${LEGACY_USER} ${LEGACY_GROUP}
        deluser ${LEGACY_USER}
    fi

	# Backup the config file to a save location
	if [ -f ${CFG_FILES}/config.properties ]
	then
		mv ${CFG_FILES}/config.properties ${TMP_DIR}
	fi

	# Backup the database to a save location
	if [ -f ${CFG_FILES}/database.db ]
	then
		mv ${CFG_FILES}/database.db ${TMP_DIR}
	fi
	
	# Backup the ExamplePostProcess file to a save location
	if [ -f ${CFG_FILES}/ExamplePostProcess.py ]
	then
		mv ${CFG_FILES}/ExamplePostProcess.py ${TMP_DIR}
	fi
	
	exit $?
}

postupgrade ()
{
	# Restore the config file
	if [ -f ${TMP_DIR}/config.properties ]
	then
		mv ${TMP_DIR}/config.properties ${INSTALL_DIR}/config.properties
	fi

	# Restore the database
	if [ -f ${TMP_DIR}/database.db ]
	then
		mv ${TMP_DIR}/database.db ${INSTALL_DIR}/database.db
	fi
	
	# Restore the ExamplePostProcess file
	if [ -f ${TMP_DIR}/ExamplePostProcess.py ]
	then
		mv ${TMP_DIR}/ExamplePostProcess.py ${INSTALL_DIR}/ExamplePostProcess.py
	fi

	# Correct the files ownership
	chown -R ${USER}:root ${SYNOPKG_PKGDEST}

	# Add firewall config
	${SERVICETOOL} --install-configure-file --package ${FWPORTS} >> /dev/null

	exit 0
}
