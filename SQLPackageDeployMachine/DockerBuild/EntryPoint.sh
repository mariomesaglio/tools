#!/bin/sh

$(wget --user $1 --password $2 $3)
cd SQL*
./SQL_EXECUTOR.sh $4 $5 $6 $7 $8
