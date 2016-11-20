#!/bin/bash

build()
{
	CONFIG='config.sh'
	if [ -s $CONFIG ]; then
	    source $CONFIG
	    echo $GREEN "Start build $CONTAINER container" $ENDC
	    docker build -t $CONTAINER web
	else
		docker build -t `whoami`/lamp web
	fi  
}

build