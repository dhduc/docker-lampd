#!/bin/bash

mysql_load()
{
	CONFIG='config.sh'
	if [ -s $CONFIG ]; then
	    source $CONFIG
	else
		echo "`tput setaf 1` $CONFIG not found!"
		exit
	fi
}  

mysql_run()
{
	if [ -n "$1" ]; then
    	MYDB=$1
	fi

	if [ -n "$2" ]; then
	    USER=$2
	fi

	if [ -n "$3" ]; then
	    PASSWORD=$3
	fi

	docker exec -it $MYDB mysql -u$USER -p$PASSWORD
}

mysql_load
mysql_run