@ECHO OFF

IF EXIST data\sentosa.db (
  ECHO Removing old sentosa.db ...
  DEL data\sentosa.db
)

ECHO Importing sentosa.sql ...
sqlite3 -batch data\sentosa.db < db\sentosa.sql

IF EXIST db\sentosa.custom.sql (
  ECHO Importing sentosa.custom.sql ...
  sqlite3 -batch data\sentosa.db < db\sentosa.custom.sql
)

rem IF EXIST data\chinook.db (
rem  ECHO Removing old chinook.db ...
rem  DEL data\chinook.db
rem )

rem ECHO Importing chinook.sql ...
rem sqlite3 -batch data\chinook.db < db\chinook.sql

ECHO Done!
