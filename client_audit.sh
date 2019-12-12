#!/bin/bash

set_env () {
    url_api="http://localhost:5000/post"
    cron_client_audit='/home/vagrant/NURE/audit-user-client/cron-client.sh 2>&1 | systemd-cat -t cron-client'
    echo "id_mb:" ; read id_mb #id_mb=`dmidecode | grep UUID | cut -d" " -f2`
    echo "ipv4:" ; read ipv4 #ipv4="192.168.111.201" #`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
    echo "mac-address" ; read mac_address  #"mac_address="`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`"
    timestamp=`date +"%H:%M:%S %d.%m.%Y"`
    echo "hostname" ; read hostname #hostname=a-trushchenkova-pc.adminforum.online #"`hostname`"
    echo "users"; read users #users="yurii-aleshchenko" #"`who | cut -d' ' -f1 | sort | uniq`"
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
    pkill -9 -u $1
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
    if [[ "${response}" -eq "Ok" ]]; then
        echo "Ok"
    else
        kill_users $( echo "${response}" | jq '.name' )
    fi
}

main () {
    check_cron
    set_env
    post_to_api
    check_cron
}

main

