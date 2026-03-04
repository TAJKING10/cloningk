# ============================================
# OVH Cloud Deployment Script for Advensys Conseil
# ============================================
#
# INSTRUCTIONS:
# 1. Edit the configuration below with your OVH credentials
# 2. Run: powershell -ExecutionPolicy Bypass -File deploy-ovh.ps1
#
# ============================================

# Configuration - EDIT THESE VALUES
$CONFIG = @{
    # OVH FTP Settings
    FtpServer   = "ftp.clusterXXX.hosting.ovh.net"  # Get from OVH Manager
    FtpUser     = "YOUR_FTP_USERNAME"                # Your FTP username
    FtpPassword = "YOUR_FTP_PASSWORD"                # Your FTP password

    # Paths
    LocalPath   = "C:\Users\Toufi\AndroidStudioProjects\cloningk\advensys-conseil.lu"
    RemotePath  = "/www"
}

# ============================================
# DO NOT EDIT BELOW THIS LINE
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Advensys Conseil - OVH Deployment    " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if WinSCP is installed
$winscp = "C:\Program Files (x86)\WinSCP\WinSCP.com"
if (-not (Test-Path $winscp)) {
    $winscp = "C:\Program Files\WinSCP\WinSCP.com"
}

if (Test-Path $winscp) {
    Write-Host "[INFO] Using WinSCP for deployment..." -ForegroundColor Yellow

    & $winscp /command `
        "open ftp://$($CONFIG.FtpUser):$($CONFIG.FtpPassword)@$($CONFIG.FtpServer)/" `
        "synchronize remote `"$($CONFIG.LocalPath)`" $($CONFIG.RemotePath)" `
        "exit"

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[SUCCESS] Deployment completed successfully!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[ERROR] Deployment failed. Check your credentials and try again." -ForegroundColor Red
    }
} else {
    Write-Host "[WARNING] WinSCP not found. Using built-in FTP..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "For better deployment, install WinSCP from: https://winscp.net/" -ForegroundColor Gray
    Write-Host ""

    # Create FTP script
    $ftpScript = @"
open $($CONFIG.FtpServer)
$($CONFIG.FtpUser)
$($CONFIG.FtpPassword)
binary
cd $($CONFIG.RemotePath)
lcd "$($CONFIG.LocalPath)"
prompt
mput *
bye
"@

    $ftpScript | Out-File -FilePath "$env:TEMP\ftp_deploy.txt" -Encoding ASCII

    Write-Host "[INFO] Starting FTP upload..." -ForegroundColor Yellow
    ftp -s:"$env:TEMP\ftp_deploy.txt"

    Remove-Item "$env:TEMP\ftp_deploy.txt" -Force

    Write-Host ""
    Write-Host "[INFO] Basic FTP upload completed." -ForegroundColor Yellow
    Write-Host "[NOTE] For folder sync, please use WinSCP or FileZilla." -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Post-Deployment Checklist            " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. [ ] Verify homepage loads: https://advensys-conseil.lu/" -ForegroundColor White
Write-Host "2. [ ] Check SSL certificate is active" -ForegroundColor White
Write-Host "3. [ ] Test all navigation links" -ForegroundColor White
Write-Host "4. [ ] Verify images load correctly" -ForegroundColor White
Write-Host "5. [ ] Test contact form" -ForegroundColor White
Write-Host "6. [ ] Check mobile responsiveness" -ForegroundColor White
Write-Host ""
