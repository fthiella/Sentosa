@ECHO OFF

ECHO Importing sentosa.sql ...
perl bin\sqlbuild.pl -s db\sentosa.sql

IF EXIST db\sentosa.custom.sql (
  ECHO Importing sentosa.custom.sql ...
  perl bin\sqlbuild.pl -s db\sentosa.custom.sql
)

ECHO Importing samples
del db\samples.sqlite
perl bin\samples.pl

ECHO Done!
