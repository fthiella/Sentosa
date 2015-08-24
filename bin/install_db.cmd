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

IF EXIST data\samples.db (
  ECHO Removing old samples.db ...
  DEL data\samples.db
)

ECHO Importing samples.sql ...
sqlite3 -batch data\samples.db < db\samples.sql

ECHO Done!
