@echo off
REM ============================================
REM OVH Cloud Deployment Script for Advensys Conseil
REM ============================================
REM
REM INSTRUCTIONS:
REM 1. Edit the configuration below with your OVH credentials
REM 2. Double-click this file or run from command prompt
REM
REM ============================================

REM Configuration - EDIT THESE VALUES
set FTP_SERVER=ftp.clusterXXX.hosting.ovh.net
set FTP_USER=YOUR_FTP_USERNAME
set FTP_PASS=YOUR_FTP_PASSWORD
set LOCAL_PATH=C:\Users\Toufi\AndroidStudioProjects\cloningk\advensys-conseil.lu
set REMOTE_PATH=/www

REM ============================================
REM DO NOT EDIT BELOW THIS LINE
REM ============================================

echo.
echo ========================================
echo   Advensys Conseil - OVH Deployment
echo ========================================
echo.

REM Check for WinSCP
if exist "C:\Program Files (x86)\WinSCP\WinSCP.com" (
    set WINSCP="C:\Program Files (x86)\WinSCP\WinSCP.com"
    goto :use_winscp
)
if exist "C:\Program Files\WinSCP\WinSCP.com" (
    set WINSCP="C:\Program Files\WinSCP\WinSCP.com"
    goto :use_winscp
)

echo [WARNING] WinSCP not found.
echo.
echo Please install WinSCP from: https://winscp.net/
echo Or use FileZilla for manual upload.
echo.
echo Press any key to open FileZilla download page...
pause >nul
start https://filezilla-project.org/download.php?type=client
goto :end

:use_winscp
echo [INFO] Using WinSCP for deployment...
echo.

%WINSCP% /command ^
    "open ftp://%FTP_USER%:%FTP_PASS%@%FTP_SERVER%/" ^
    "synchronize remote ""%LOCAL_PATH%"" %REMOTE_PATH%" ^
    "exit"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Deployment completed successfully!
) else (
    echo.
    echo [ERROR] Deployment failed. Check your credentials.
)

:end
echo.
echo ========================================
echo   Post-Deployment Checklist
echo ========================================
echo.
echo 1. Verify homepage loads: https://advensys-conseil.lu/
echo 2. Check SSL certificate is active
echo 3. Test all navigation links
echo 4. Verify images load correctly
echo 5. Test contact form
echo.
pause
