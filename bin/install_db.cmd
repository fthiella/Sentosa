@echo off
del data\sentosa.db
sqlite3 -batch data\sentosa.db < db\sentosa.sql
del data\samples.db
sqlite3 -batch data\samples.db < db\samples.sql