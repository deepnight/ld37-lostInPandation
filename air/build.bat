@echo off

set client="lostInPandation"
rmdir /S/Q data
rmdir /S/Q %client%
mkdir data

:copy
echo Using existing SWF: %1...
copy ..\bin\client.swf data\
goto build

:build
echo Building...
call adt -package -storetype pkcs12 -keystore certificate.p12 -storepass d -tsa none -target bundle %client% manifest.xml data

rmdir /S/Q data
copy README.txt %client%

echo Done.
pause