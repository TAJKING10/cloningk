# OVH Cloud Deployment Guide - Advensys Conseil Website

## Pre-Deployment Checklist

### 1. Files to Upload
The main website folder to deploy is:
```
advensys-conseil.lu/
```

### 2. Required OVH Services
- **OVH Web Hosting** (Performance or Pro plan recommended) OR
- **OVH VPS** with web server OR
- **OVH Object Storage** (for static hosting)

---

## Option A: OVH Web Hosting (Recommended for Static Sites)

### Step 1: Access OVH Manager
1. Go to https://www.ovh.com/manager/
2. Login to your account
3. Navigate to **Web Cloud** > **Hosting plans**

### Step 2: Get FTP Credentials
In OVH Manager:
- Go to your hosting plan
- Click **FTP - SSH** tab
- Note down:
  - **FTP Server**: ftp.cluster0XX.hosting.ovh.net
  - **FTP Login**: your-login
  - **FTP Password**: (reset if needed)

### Step 3: Upload via FTP
Using FileZilla or WinSCP:

```
Host: ftp.cluster0XX.hosting.ovh.net
Username: your-ftp-login
Password: your-ftp-password
Port: 21 (FTP) or 22 (SFTP)
```

**Upload the contents of `advensys-conseil.lu/` to the `www/` folder on the server.**

### Step 4: Configure Domain
1. In OVH Manager > **Domains**
2. Point your domain DNS to OVH hosting
3. Add SSL certificate (free Let's Encrypt available)

---

## Option B: Deploy via Command Line (PowerShell/CMD)

### Using WinSCP Command Line
```powershell
# Install WinSCP if not installed
# Download from: https://winscp.net/

# Upload command
winscp.com /command ^
    "open ftp://username:password@ftp.clusterXXX.hosting.ovh.net/" ^
    "synchronize remote C:\Users\Toufi\AndroidStudioProjects\cloningk\advensys-conseil.lu /www" ^
    "exit"
```

### Using lftp (if available)
```bash
lftp -u username,password ftp.clusterXXX.hosting.ovh.net -e "mirror -R ./advensys-conseil.lu /www; quit"
```

---

## Option C: OVH Object Storage (S3-Compatible)

### Step 1: Create Container
1. OVH Manager > **Public Cloud** > **Object Storage**
2. Create a new container with **Static Hosting** enabled
3. Set container to **Public**

### Step 2: Configure AWS CLI
```powershell
# Install AWS CLI
# Configure with OVH credentials

aws configure
# Access Key: your-ovh-access-key
# Secret Key: your-ovh-secret-key
# Region: gra (or your region)
# Output: json
```

### Step 3: Upload Files
```powershell
aws s3 sync ./advensys-conseil.lu s3://your-bucket-name --endpoint-url https://s3.gra.cloud.ovh.net
```

---

## Post-Deployment Configuration

### 1. SSL Certificate Setup
In OVH Manager:
1. Go to **Hosting** > **SSL Certificates**
2. Click **Order an SSL certificate**
3. Select **Free Let's Encrypt certificate**
4. Wait for activation (up to 24 hours)

### 2. Domain Configuration
Add these DNS records in OVH DNS Zone:

```
Type    Name              Value
A       @                 your-hosting-ip
A       www               your-hosting-ip
CNAME   www               your-domain.com.
```

### 3. .htaccess File (Apache)
Create this file in the root of your upload:

```apache
# Force HTTPS
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Remove .html extension
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME}.html -f
RewriteRule ^(.*)$ $1.html [L]

# Custom error pages
ErrorDocument 404 /404.html

# Enable compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css
    AddOutputFilterByType DEFLATE application/javascript application/json
</IfModule>

# Browser caching
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>

# Security headers
<IfModule mod_headers.c>
    Header set X-Content-Type-Options "nosniff"
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-XSS-Protection "1; mode=block"
</IfModule>
```

---

## File Structure to Upload

```
www/                              (OVH root folder)
├── index.html                    (main entry point)
├── .htaccess                     (Apache config)
├── en/                           (English pages)
│   ├── about/
│   ├── main-page/
│   │   └── services/
│   │       ├── accounting/
│   │       ├── for-private-people-luxembourg/
│   │       └── tax-advice/
│   ├── contact/
│   └── category/
├── main-page/                    (French pages)
│   └── services/
├── wp-content/                   (Assets)
│   ├── uploads/
│   ├── themes/
│   └── plugins/
└── modern-style.css
```

---

## Verification Checklist

After deployment, verify:

- [ ] Homepage loads correctly
- [ ] All navigation links work
- [ ] Images load properly
- [ ] Contact forms work (if backend configured)
- [ ] SSL certificate is active (https://)
- [ ] Mobile responsive design works
- [ ] French and English versions accessible
- [ ] No 404 errors on main pages

### Test URLs:
- https://advensys-conseil.lu/
- https://advensys-conseil.lu/en/about/
- https://advensys-conseil.lu/en/main-page/services/accounting/
- https://advensys-conseil.lu/en/main-page/services/for-private-people-luxembourg/
- https://advensys-conseil.lu/en/contact/

---

## Troubleshooting

### Issue: 404 Not Found
- Check file paths are correct
- Ensure .htaccess is uploaded
- Verify index.html exists in root

### Issue: CSS/Images not loading
- Check relative paths in HTML files
- Ensure wp-content folder is uploaded
- Clear browser cache

### Issue: SSL not working
- Wait 24 hours for Let's Encrypt propagation
- Check DNS records are correct
- Regenerate certificate in OVH Manager

---

## Support Contacts

- **OVH Support**: https://help.ovhcloud.com/
- **OVH Status**: https://www.ovhcloud.com/en/about-us/status/

---

## Quick Deploy Script (PowerShell)

Save as `deploy.ps1`:

```powershell
# OVH FTP Deployment Script
$ftpServer = "ftp://ftp.clusterXXX.hosting.ovh.net"
$ftpUser = "YOUR_FTP_USER"
$ftpPass = "YOUR_FTP_PASSWORD"
$localPath = "C:\Users\Toufi\AndroidStudioProjects\cloningk\advensys-conseil.lu"
$remotePath = "/www"

# Using WinSCP
& "C:\Program Files (x86)\WinSCP\WinSCP.com" /command `
    "open ftp://${ftpUser}:${ftpPass}@ftp.clusterXXX.hosting.ovh.net/" `
    "synchronize remote `"$localPath`" $remotePath" `
    "exit"

Write-Host "Deployment complete!" -ForegroundColor Green
```

Run with: `.\deploy.ps1`
