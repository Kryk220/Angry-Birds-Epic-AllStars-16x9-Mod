@echo off
rem Portable apktool wrapper.
rem Looks for apktool.jar next to this file, then in ..\Soft\apktool.jar.
setlocal

set "JAR=%~dp0apktool.jar"
if not exist "%JAR%" set "JAR=%~dp0..\Soft\apktool.jar"

set "JAVA_EXE=java.exe"
if defined JAVA_HOME set "JAVA_EXE=%JAVA_HOME%\bin\java.exe"
if exist "%~dp0..\Soft\jdk\bin\java.exe" set "JAVA_EXE=%~dp0..\Soft\jdk\bin\java.exe"

if not exist "%JAR%" (
    echo apktool.jar was not found.
    echo Run: powershell -ExecutionPolicy Bypass -File "%~dp0download_tools.ps1"
    exit /b 1
)

"%JAVA_EXE%" -jar -Xmx1024M -Duser.language=en -Dfile.encoding=UTF8 "%JAR%" %*
exit /b %ERRORLEVEL%
