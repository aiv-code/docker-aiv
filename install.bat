@echo off
setlocal enabledelayedexpansion

:: Set the variables
set aiv_port=8080
set aiv_db_url=jdbc:postgresql://localhost:5432/postgres
set aiv_db_user=postgres
set aiv_db_password=postgres
set security_db_url=jdbc:postgresql://localhost:5432/postgres?currentSchema=security
set security_db_user=postgres
set security_db_password=postgres
set aiv_logs=%CD%\logs
set aiv_logs=%aiv_logs:\=/%
set aiv_base=%CD%

:: Set file paths
set "original_file=%CD%\config\application.template"
set "aiv_logback_file=%CD%\config\logback.template"

set "new_file=%CD%\repository\econfig\application.yml"
set "aiv_logback_new_file=%CD%\repository\econfig\logback.xml"

set "aiv_base=%aiv_base:\=/%"

:: Create a temporary file for processing
set "temp_file=%CD%\config\temp.yml"

:: Read the application.yml file and replace placeholders
(for /f "delims=" %%i in ('type "%original_file%"') do (
    set "line=%%i"
    set "line=!line:${aiv_port}=%aiv_port%!"
    set "line=!line:${aiv_db_url}=%aiv_db_url%!"
    set "line=!line:${aiv_db_user}=%aiv_db_user%!"
    set "line=!line:${aiv_db_password}=%aiv_db_password%!"
    set "line=!line:${security_db_url}=%security_db_url%!"
    set "line=!line:${security_db_user}=%security_db_user%!"
    set "line=!line:${security_db_password}=%security_db_password%!"
    set "line=!line:${aiv_base}=%aiv_base%!"
    echo !line!
)) > "%temp_file%"


:: Move the temporary file to the new file
move /y "%temp_file%" "%new_file%"

:: Create a temporary file for processing
set "temp_file1=%CD%\config\temp1.xml"
:: Read the application.yml file and replace placeholders
(for /f "delims=" %%i in ('type "%aiv_logback_file%"') do (
    set "line=%%i"
    set "line=!line:${aiv_base}=%aiv_base%!"
    echo !line!
)) > "%temp_file1%"

:: Move the temporary file to the new file
move /y "%temp_file1%" "%aiv_logback_new_file%"

echo Variables replaced and written to %new_file% and %aiv_logback_new_file% 
