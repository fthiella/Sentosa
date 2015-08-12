@echo off
del data\sentosa.db
sqlite3 -batch data\sentosa.db < db\sentosa.sql