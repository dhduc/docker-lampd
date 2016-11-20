#!/bin/bash

destroy_load()
{
	CONFIG='config.sh'
	if [ -s $CONFIG ]; then
	    source $CONFIG
	else
		echo "`tput setaf 1` $CONFIG not found!"
		exit
	fi
}

destroy_run()
{
	if [ -n "$1" ]; then
	    PROJECT=$1
	fi

	docker stop $PROJECT
	docker rm $PROJECT
}

destroy_load
destroy_run