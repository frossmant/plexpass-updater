#/bin/bash

PLEX_TOKEN=EnterMyPlexPassToken
OS_RELEASE=`cat /etc/os-release|grep -w "ID"|awk -F'=' '{ print $2 }'|tr -d '"'`

if [ "$1" = "force" ]
then
	FORCE=1
else
	FORCE=0
fi

case "${OS_RELEASE}" in
"opensuse"*)
	PKG="rpm"
	;;
"ubuntu"*)
	PKG="dpkg"
	;;
*)
	logger "Plex Media Server Update Service: not running a supported distrubution, exiting script"
	echo "Plex Media Server Update Service: not running a supported distrubution, exiting script"
	exit 1
	;;
esac

function plex_package_inst()
{
        case "${PKG}" in
        "rpm")
                echo `rpm -qa|grep plexmediaserver`
                ;;
        "dpkg")
                echo `dpkg --get-selections | grep "install" | cut -f1|grep plexmediaserver`
                ;;
        esac
}
function plex_package_inst_version()
{
	PLEX_PACKAGE=$(plex_package_inst)

	case "${PKG}" in
	"rpm")
		echo `rpm -qi ${PLEX_PACKAGE}|grep Version|awk '{ print $3 }'`
		;;
	"dpkg")
		echo `dpkg -s ${PLEX_PACKAGE} | grep -i version|awk '{ print $2 }'`
		;;
	esac
} 
function plex_package_down()
{
        case "${PKG}" in
        "rpm")
		wget -q "https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=redhat&X-Plex-Token=${PLEX_TOKEN}" -O /tmp/pms_latest.rpm
                ;;
        "dpkg")
		wget -q "https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu&X-Plex-Token=${PLEX_TOKEN}" -O /tmp/pms_latest.deb
                ;;
        esac
}
function plex_package_down_version()
{
        case "${PKG}" in
        "rpm")
		echo `rpm -qip /tmp/pms_latest.rpm 2>/dev/null|grep Version|awk '{ print $3 }'`
                ;;
        "dpkg")
		echo `dpkg -f /tmp/pms_latest.deb Version`
                ;;
        esac
}
function plex_package_upgrade()
{
        PLEX_VERSION_INST=$(plex_package_inst_version)
        PLEX_VERSION_DOWN=$(plex_package_down_version)

	if ! [ "$(plex_session_active)" = 0 ] && [ ${FORCE} -eq 0 ]
	then
		logger "Plex Media Server Update Service: Active running sessions, skipping update"
		exit 1
	fi
	if [[ "${PLEX_VERSION_INST}" = "${PLEX_VERSION_DOWN}" ]]
	then
		logger "Plex Media Server Update Service: already running latest version ${PLEX_VERSION_INST}"
		exit 0
	fi


	plex_service_stop	
        case "${PKG}" in
        "rpm")
		rpm -Uvh /tmp/pms_latest.rpm
                ;;
        "dpkg")
		dpkg -i /tmp/pms_latest.deb
                ;;
        esac
	plex_service_start
	logger "Plex Media Server Update Service: upgrading from ${PLEX_VERSION_INST} to ${PLEX_VERSION_DOWN}"
}

function plex_session_active()
{
	echo `curl -s localhost:32400/status/sessions?X-Plex-Token=${PLEX_TOKEN}|grep Player|wc -l`
}
function plex_service_stop()
{
	if [ `systemctl is-active plexmediaserver.service` = "active" ]
	then
		echo systemctl stop plexmediaserver
		logger "Plex Media Server Update Service: stopping systemd service"
	fi
}
function plex_service_start()
{
        if ! [ `systemctl is-active plexmediaserver.service` = "active" ]
        then
                echo systemctl start plexmediaserver
		logger "Plex Media Server Update Service: starting systemd service"
        fi
}
function plex_package_down_prune()
{
	rm /tmp/pms_latest.deb
	logger "Plex Media Server Update Service: deleting downloaded plex media server package"
}

plex_package_down
plex_package_upgrade
plex_package_down_prune
exit 0
