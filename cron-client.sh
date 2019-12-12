#!/bin/bash

set_env () {
    files_systemd=( 
        "client-audit.service"
        "timer-client-audit.timer"
    )
    path_to_systemctl="/etc/systemd/system"
    path_to_backup="/home/vagrant/NURE/audit-user-client/systemd-service/"
}


recover () {
    echo "Recover services - In progress"
    cp -fi ${path_to_backup}/* "${path_to_systemctl}/"
    chmod 660 "${path_to_systemctl}/${files_systemd[0]}" "${path_to_systemctl}/${files_systemd[1]}"
    systemctl daemon-reload && systemctl enable "${files_systemd[0]}"
    systemctl start "${files_systemd[0]}"
    echo "Recover services - success"
}

checker_files () {
    for file_service in "${files_systemd[@]}" ; do
        if [ -f ${path_to_systemctl}/${file_service} ] ; then
            echo "File ${file_service} - 200 Ok"	    
        else  
            recover
        fi	    
    done
}

checker_service () {
    status_timer=`systemctl status "${files_systemd[1]}" &> /dev/null ; echo $?`
    if [ "${status_timer}" -eq "0"  ] ; then echo "Timer ${files_systemd[1]} - Ok"
    else systemctl restart "${files_systemd[1]}"  
    fi
}

main () {
    set_env
    checker_files
    checker_service
}

for ten_s in {0..11}; do 
    main ; sleep 5
done 
