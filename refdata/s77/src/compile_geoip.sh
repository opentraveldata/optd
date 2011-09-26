#!/bin/sh

SOURCES="IPBlockRecord.cpp DbaIPBlockRecord.cpp locateIP.cpp"
EXEC=`basename ${SOURCE} .cpp`

CC=g++
CFLAGS="-g -Wall -I."
LDFLAGS="-L/usr/lib64 -lboost_date_time -lsoci_core -lsoci_mysql"

${CC} ${CFLAGS} ${SOURCES} -o ${EXEC} ${LDFLAGS}
