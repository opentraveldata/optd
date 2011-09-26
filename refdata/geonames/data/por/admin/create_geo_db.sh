#!/bin/sh

DB_NAME="geo_geonames"
DB_HOST="localhost"
DB_PORT="3306"

if [ "$1" != "" ]; then
	DB_NAME=$1
fi

if [ "$2" != "" ]; then
	DB_HOST=$2
fi 

if [ "$3" != "" ]; then
	DB_PORT=$3
fi


if [ "$1" = "--help" -o  "$1" = "-h" ]; then
	echo "Usage: $0 [ <Name of Database> <Host> <Port> ]"
	echo ""
	exit -1
fi

#
echo "Accessing MySQL database hosted on $DB_HOST:$DB_PORT to create database '${DB_NAME}'."
echo "To create a database, username and password of an administrator-like MySQL account"
echo "are required. On most of MySQL databases, the 'root' MySQL account has all"
echo "the administrative rights, but you may want to use a less-privileged MySQL"
echo "administrator account. Type the username of administrator followed by "
echo "[Enter]. To discontinue, type CTRL-C."
read userinput_adminname

echo "Type $userinput_adminname's password followed by [Enter]"
read -s userinput_pw

#
SQL_STATEMENT="create database if not exists ${DB_NAME} default character set utf8 collate utf8_unicode_ci"

#
echo "The database '${DB_NAME}' will be created:"
mysql -u ${userinput_adminname} --password=${userinput_pw} -P ${DB_PORT} -h ${DB_HOST} mysql -e "${SQL_STATEMENT}"
