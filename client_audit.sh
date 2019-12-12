#!/bin/bash

set_env () {
    url_api="http://192.168.13.13:5000/post"
    cron_client_audit='/srv/audit-user-client/cron-client.sh 2>&1 | systemd-cat -t cron-client'
    id_mb=`dmidecode | grep UUID | cut -d" " -f2`
    ipv4=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
    mac_address="`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`"
    timestamp=`date +"%H:%M:%S %d.%m.%Y"`
    hostname="`hostname`"
    users="`who | cut -d' ' -f1 | sort | uniq`"
}

check_cron () {
    mathing="`crontab -l | grep -o "${cron_client_audit}"`"
    echo ${mathing}
    echo ${cron_client_audit}
    if [ "${mathing}" == "${cron_client_audit}" ] ; then
        echo "Cron client-audit.service - OK"
    else
        echo "* * * * * ${cron_client_audit}" > /tmp/cron-client
        crontab /tmp/cron-client
    fi
}

kill_users () {
    echo $1 "============================================================================"   
    pkill -9 -u `echo $1 | grep -e "[a-z\.]*"`
}

post_to_api () {
    response=`curl -d "{\"id_mb\": \"${id_mb}\", 
                        \"timestamp\": \"${timestamp}\",
                        \"hostname\": \"${hostname}\", 
                        \"mac\": \"${mac_address}\",
                        \"ipv4\": \"${ipv4}\", 
                        \"users\": \"${users}\"}" \
   	      -H "Content-Type: application/json" \
	      ${url_api}`
    echo "RESPONSE ============================================== ${response}"
    if [ "${response}" == "Ok" ]; then
        echo "Ok"
    else
        kill_users ${response}
    fi
}

main () {
    check_cron
    set_env
    post_to_api
    check_cron
}

main

