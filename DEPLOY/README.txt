============================================
   ADVENSYS CONSEIL - OVH DEPLOYMENT PACKAGE
============================================

CONTENTS OF THIS FOLDER:
------------------------
1. DEPLOYMENT_OVH.md   - Full deployment guide (read this first!)
2. deploy-ovh.bat      - Windows batch script for deployment
3. deploy-ovh.ps1      - PowerShell script for deployment
4. .htaccess           - Apache configuration (copy to website root)
5. 404.html            - Custom error page (copy to website root)


QUICK START (5 STEPS):
----------------------

STEP 1: Get OVH Credentials
   - Login to https://www.ovh.com/manager/
   - Go to: Web Cloud > Hosting > FTP-SSH tab
   - Copy: FTP Server, Username, Password

STEP 2: Edit deploy-ovh.bat
   - Open deploy-ovh.bat in Notepad
   - Replace these lines with your credentials:

     set FTP_SERVER=ftp.clusterXXX.hosting.ovh.net
     set FTP_USER=YOUR_FTP_USERNAME
     set FTP_PASS=YOUR_FTP_PASSWORD

STEP 3: Install WinSCP
   - Download from: https://winscp.net/
   - Install with default options

STEP 4: Run Deployment
   - Double-click deploy-ovh.bat
   - Wait for upload to complete

STEP 5: Verify
   - Open your website in browser
   - Check all pages work correctly
   - Enable SSL in OVH Manager


FILES TO UPLOAD:
----------------
The website files are in:
   C:\Users\Toufi\AndroidStudioProjects\cloningk\advensys-conseil.lu\

Upload the CONTENTS of this folder to /www on OVH server.

IMPORTANT: Also copy .htaccess and 404.html to the advensys-conseil.lu
folder before uploading (already done).


SUPPORT:
--------
- OVH Documentation: https://help.ovhcloud.com/
- OVH Status: https://www.ovhcloud.com/en/about-us/status/


============================================
