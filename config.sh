#!/bin/sh
init() 
{
	ENDC=`tput setaf 7`
	RED=`tput setaf 1`
	GREEN=`tput setaf 2`
	BLUE=`tput setaf 3`
	NORMAL=`tput sgr0`
	BOLD=`tput bold`

	if [[ $UID != 0 ]]; then
	    echo $RED "Please run this as root" $ENDC
	    echo $GREEN "sudo $0 $*" $ENDC
	    exit 0
	fi
}

config()
{
	# all
	CONTAINER="ducdh/lamp"
	PROJECT="mylocal"

	# mysql.sh
	MYDB="mysql"
	USER="root"
	PASSWORD="password"	

	# run.sh
	SCRIPT=$(readlink -f "$0")
	BASEDIR=$(dirname "$SCRIPT")
	MYWEBDIR=$BASEDIR"/web/public_html"
	MYSQLDIR=$HOME"/data/mysql"
	MYCNF=$BASEDIR"/web/conf/my.cnf"

	MYSQL_ROOT_PASSWORD="root"
	MYSQL_USER="root"
	MYSQL_PASSWORD="root"
	MYSQL_DATABASE="test_docker"
}

init
config
