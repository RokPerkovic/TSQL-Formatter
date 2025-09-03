@echo off
:: Set source and output directories
set SRC_DIR=src
set OBJ_DIR=bin\obj\
set BIN_DIR=bin

:: Ensure the output directory exists
if not exist %BIN_DIR% (
    mkdir %BIN_DIR%
)

if not exist %OBJ_DIR% (
    mkdir %OBJ_DIR%
)

:: Compile all Pascal files in the src directory
fpc -Fu%SRC_DIR% -op%OBJ_DIR% -o%BIN_DIR%\SQLFormatter.exe %SRC_DIR%\Main.pas

:: Check if the compilation was successful
if %errorlevel% == 0 (
    echo Compilation successful! Executable is located in %BIN_DIR%.
) else (
    echo Compilation failed.
)

:: pause
:: cd C:\Users\Rok\Documents\GitHub\RokPerkovic\TSQL-Formatter
:: C:\Users\Rok\Documents\GitHub\RokPerkovic\TSQL-Formatter\bin>SQLFormatter.exe ../data/input/test.sql
