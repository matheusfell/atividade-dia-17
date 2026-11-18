@echo off
cd /d "%~dp0"
tasklist /FI "IMAGENAME eq mysqld.exe" | find /I "mysqld.exe" >nul || start "" /B C:\xampp\mysql\bin\mysqld.exe --defaults-file=C:\xampp\mysql\bin\my.ini --standalone
timeout /t 4 /nobreak >nul
C:\xampp\mysql\bin\mysql.exe -u root < banco.sql
C:\xampp\php\php.exe -S 0.0.0.0:8000 router.php
