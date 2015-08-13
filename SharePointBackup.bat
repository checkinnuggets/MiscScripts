REM Setup Variables (no trailing \)
SET todaysDate=%DATE:~-4%%DATE:~3,2%%DATE:~0,2%
SET backupPath="D:\MSSQL\sharepoint_data\backup\"
SET stsAdmExe="%CommonProgramFiles%\Microsoft Shared\Web Server Extensions\12\bin\stsadm.exe"
SET addUsersExe="C:\digexadmin\addusers.exe"
SET pkZipExe="C:\digexadmin\pkzip25.exe"
SET twelveHivePath="%CommonProgramFiles%\Microsoft Shared\web server extensions\12"
SET webRootPath="C:\inetpub\wwwroot"
SET metaBackPath="C:\WINNT\system32\inetsrv\MetaBack"

REM IIS Backup

iisback /backup /b WSS_%todaysDate%
xcopy %metaBackPath% %backupPath%\%todaysDate%_IIS\ /E /H

REM WSS Backup
mkdir %backupPath%\%todaysDate%_wss
%stsAdmExe% -o backup -directory %backupPath%\%todaysDate%_wss -backupmethod full -overwrite

REM 12 Hive Backup
xcopy %twelveHivePath% %backupPath%\%todaysDate%_12\ /E /H

REM WebRoot Backup
xcopy %webRootPath% %backupPath%\%todaysDate%_wwwroot\ /E /H

REM Users/Groups Backup
%addUsersExe% dowc384241 /d %backupPath%\%todaysDate%_UsersAndGroups.txt


REM Zip Backup (-max -move)
%pkZipExe% -add -max -move -rec -dir=relative %backupPath%\%todaysDate%_IIS.zip %backupPath%\%todaysDate%_IIS\*
%pkZipExe% -add -max -move -rec -dir=relative %backupPath%\%todaysDate%_wwwroot.zip %backupPath%\%todaysDate%_wwwroot\*
%pkZipExe% -add -max -move -rec -dir=relative %backupPath%\%todaysDate%_12.zip %backupPath%\%todaysDate%_12\*
REM  ** pkzip seems to truncate the stsadm backup

REM Cleanup
REM forfiles -p "D:\MSSQL\sharepoint_data\backup" /s /d -1 /c "cmd /c echo @path"
forfiles /p "D:\MSSQL\sharepoint_data\backup" /s /d -1 /c "cmd /c del @path /q"
forfiles /p "D:\MSSQL\sharepoint_data\backup" /d -1 /c "cmd /c if @isdir==TRUE rmdir @path /s /q"
