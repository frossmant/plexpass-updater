#/bin/bash

PLEX_TOKEN=xxxxxxxxxxxxxxxxxxxxx

wget -q "https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=redhat&X-Plex-Token=${PLEX_TOKEN}" -O /tmp/pms_latest.rpm

PACKAGE_INSTALLED=`rpm -qa|grep plexmediaserver`
VERSION_INSTALLED=`rpm -qi ${PACKAGE_INSTALLED}|grep Version|awk '{ print $3 }'`
VERSION_DOWNLOADED=`rpm -qip /tmp/pms_latest.rpm 2>/dev/null|grep Version|awk '{ print $3 }'`

if [[ "${VERSION_INSTALLED}" = "${VERSION_DOWNLOADED}" ]]
then
	logger "Plex Media Server Update Service: no new version found"
else
	if [[ `curl -s localhost:32400/status/sessions?X-Plex-Token=${PLEX_TOKEN}|grep Player|wc -l` -eq 0 ]]
	then
	        sudo service plexmediaserver stop
		rpm -Uvh /tmp/pms_latest.rpm
		sudo service plexmediaserver start
		logger "Plex Media Server Update Service: updating plex with version ${VERSION_DOWNLOADED}"
	else
		logger "Plex Media Server Update Service: Active running sessions, skipping update"
	fi
fi

rm /tmp/pms_latest.rpm
exit 0
