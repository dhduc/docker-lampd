#!/bin/bash

run_load()
{
    CONFIG='config.sh'
    if [ -s $CONFIG ]; then
        source $CONFIG
    else
        echo "`tput setaf 1` $CONFIG not found!"
        exit
    fi
}

run_init()
{
    if [ -n "$1" ]; then
        PROJECT=$1
    fi

    if [ -n "$2" ]; then
        MYWEBDIR=$2
    fi

    if [ -n "$3" ]; then
        MYSQLDIR=$3
    fi
}  

run_mysql()
{
    # find MySQL container
    MYSQL_CONTAINER=$(docker ps | grep $MYDB | awk '{print $1}')
    if [ -z "$MYSQL_CONTAINER" ]; then
        # maybe it was stopped
        MYSQL_CONTAINER=$(docker ps -a | grep $MYDB | awk '{print $1}')
        if [ -z "$MYSQL_CONTAINER" ]; then
            echo Starting MySQL container \"$MYDB\"...
            echo Loading config from: $MYCNF
            echo Loading data from: $MYSQLDIR
            sudo docker run -d --name $MYDB -v ${MYSQLDIR}:/var/lib/mysql \
                -v ${MYCNF}:/etc/my.cnf \
                -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
                -e MYSQL_USER=${MYSQL_USER} \
                -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
                -e MYSQL_DATABASE=${MYSQL_DATABASE} \
                mysql/mysql-server
            if [ "$?" -ne 0 ]; then
                echo ERROR: Could not start MySQL container.
                exit 1
            fi
        else
            echo Stopped MySQL container found. Restarting...
            docker start $MYDB
            if [ "$?" -ne 0 ]; then
                echo ERROR: Could not restart MySQL container.
                exit 1
            fi
        fi
    else
        echo Running MySQL container found!
    fi

    echo
}

run_web()
{
    # find web container
    WEB_CONTAINER=$(docker ps | grep $PROJECT | awk '{print $1}')
    if [ -z "$WEB_CONTAINER" ]; then
        # maybe it was stopped
        WEB_CONTAINER=$(docker ps -a | grep $PROJECT | awk '{print $1}')
        if [ -z "$WEB_CONTAINER" ]; then
            echo Starting web container \"$PROJECT\"...
            echo Mounting $MYWEBDIR
            sudo docker run -d -v ${MYWEBDIR}:/var/www/myweb --name $PROJECT --link $MYDB:mysql $CONTAINER
            if [ "$?" -ne 0 ]; then
                echo ERROR: Could not start web container.
                exit 1
            fi
        else
            echo Found existing web container. Starting \"$PROJECT\" web container...
            docker start $PROJECT
            if [ "$?" -ne 0 ]; then
                echo ERROR: Could not restart web container.
                exit 1
            fi
        fi
    else
        echo Running \"$PROJECT\" web container found!
    fi
}

run_ip()
{
    # find the new dynamic IP address
    CONTAINER_ID=$(docker ps | grep $PROJECT | awk '{print $1}')
    if [ -z "$CONTAINER_ID" ]; then
        echo ERROR: Container \"$PROJECT\" could not be started.
        exit 1
    fi

    IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $PROJECT)
    if [ -z "$IP" ]; then
        echo ERROR: Could not find the IP address of container \"$PROJECT\".
        exit 1
    fi

    echo
    echo \"$PROJECT\" loaded at $IP
    echo
}

run_host()
{
    # update HOSTS file
    echo Attempting to update HOSTS file...
    CONDITION="grep -q '"$PROJECT"' /etc/hosts"
    if eval $CONDITION; then
        CMD="sudo sed -i -r \"s/^ *[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+( +"$PROJECT")/"$IP" "$PROJECT"/\" /etc/hosts";
    else
        CMD="sudo sed -i '\$a\\\\n# added automatically by docker-lamp run.sh\n"$IP" "$PROJECT"\n' /etc/hosts";
    fi

    eval $CMD
    if [ "$?" -ne 0 ]; then
        echo ERROR: Could not update HOSTS file.
        exit 1
    fi
}

finish()
{
    docker ps -a
    echo
    echo $GREEN "All done!" $ENDC
}

run_load
run_init
run_mysql
run_web
run_ip
run_host
finish