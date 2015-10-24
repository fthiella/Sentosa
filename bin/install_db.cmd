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

IF EXIST data\chinook.db (
  ECHO Removing old chinook.db ...
  DEL data\chinook.db
)

ECHO Importing chinook.sql ...
sqlite3 -batch data\chinook.db < db\chinook.sql

ECHO Done!
