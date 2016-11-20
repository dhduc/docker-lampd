# docker-lamp

This is my personal development LAMP stack on Docker. It can help you to quickly run multiple websites on your local environment without conflicts. Instead of using reverse proxy, pipe network or forwarding ports like common Docker practices, I am using shell scripts to update automatically the host's HOSTS files. Then we can access those local websites with different hostnames on the same port 80.

This approach is trying to keep your local setup as light-weight and as simple as possible.

**WARNING: no love for Windows developers here**

**REQUIREMENT: installed Docker**

## build.sh

This script will create a Docker image **tuhoang/web** which has ubuntu 14.04, apache 2, php 5.5 and my typical configurations for local development. The detailed steps are in **web/Dockerfile**. You can skip this step because I published that image to Docker Hub.

## run.sh

This script will create and start a new container from image **tuhoang/web**, or restart a stopped one. After the web container start, this script will automatically grab the new IP of the web container and attempt to update your host's HOSTS file with the new IP address.

Our web containers will connect and share only one database container **mysql**. This script will automatically setup a mysql container or re-use one if it has been already available.

The database container **mysql** has root password is "password". And it stores the persistent data on the host at "home/youraccount/data/mysql" by default. You also can customize its startup configuration by editing the file **web/conf/my.cnf**.

Usage:
```
$ chmod 755 web/conf/my.cnf
$ chmod -R 755 web/public_html

$ ./run.sh [PROJECT_NAME] [/PATH/TO/HTML] [/PATH/TO/MYSQL/DATA]
```
All arguments are optional. Their default values are:
- *PROJECT_NAME* = "mylocal"
- */PATH/TO/HTML* = "/path/to/current/dir/web/public_html" - you should set its permission to 755
- */PATH/TO/MYSQL/DATA* = "home/youraccount/data/mysql"

Example:
```
$ ./run.sh mysite.loc /home/youraccount/www/mysite
$ ./run.sh myblog.loc /home/youraccount/www/myblog

$ ping mysite.loc
$ ping myblog.loc
```

## Interact with MySQL

Connect to MySQL container from host.

Usage:
```
$ ./mysql.sh [MYSQL_CONTAINER_NAME] [USERNAME] [PASSWORD]

# OR

$ docker exec -it [MYSQL_CONTAINER_NAME] mysql -u[USERNAME] -p[PASSWORD]
```
Their default values are:
- *MYSQL_CONTAINER_NAME* = "mysql"
- *USERNAME* = "root"
- *PASSWORD* = "password"

Import a SQL dump directly from host into MySQL container:
```
$ docker exec -i [MYSQL_CONTAINER_NAME] mysql -uroot -ppassword dbname < dump.sql
```

Export a database from MySQL container to a dump file on host:
```
$ docker exec -i [MYSQL_CONTAINER_NAME] mysqldump -uroot -ppassword dbname > dump.sql
```

## destroy.sh

This script will stop and remove your containers. It won't remove the container's IP address from your HOSTS file because that action is not usual and I prefer to remove that entry by hands.

Usage:
```
$ ./destroy.sh [PROJECT_NAME]
```
All arguments are optional. Their default values are:
- *PROJECT_NAME* = "mylocal"

# Make those scripts as system commands

```
sudo ln -s /home/youraccount/docker-lamp/run.sh /usr/local/bin/dl-run
sudo ln -s /home/youraccount/docker-lamp/mysql.sh /usr/local/bin/dl-mysql
sudo ln -s /home/youraccount/docker-lamp/destroy.sh /usr/local/bin/dl-destroy
```
