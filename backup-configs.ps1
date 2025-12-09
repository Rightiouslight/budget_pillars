# Backup Configuration Files Script
Write-Host "Backing up sensitive configuration files..." -ForegroundColor Cyan

$backupDir = ".backup\backup_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"
New-Item -ItemType Directory -Force -Path "$backupDir\firebase" | Out-Null
New-Item -ItemType Directory -Force -Path "$backupDir\configs" | Out-Null

# Backup Firebase configs
Write-Host "Backing up Firebase configurations..."
Copy-Item "android\app\google-services.json" "$backupDir\firebase\" -Force -ErrorAction SilentlyContinue
Copy-Item "android\app\google-services.dev.json" "$backupDir\firebase\" -Force -ErrorAction SilentlyContinue
Copy-Item "android\app\google-services.prod.json" "$backupDir\firebase\" -Force -ErrorAction SilentlyContinue
Copy-Item "lib\firebase_options_dev.dart" "$backupDir\firebase\" -Force -ErrorAction SilentlyContinue
Copy-Item "lib\firebase_options_prod.dart" "$backupDir\firebase\" -Force -ErrorAction SilentlyContinue
Copy-Item "firebase.json" "$backupDir\configs\" -Force -ErrorAction SilentlyContinue

# Backup Android configs
Write-Host "Backing up Android configurations..."
Copy-Item "android\local.properties" "$backupDir\configs\" -Force -ErrorAction SilentlyContinue
Copy-Item "android\gradle.properties" "$backupDir\configs\" -Force -ErrorAction SilentlyContinue

# Backup keystores
if (Test-Path "android\app\*.jks") {
    New-Item -ItemType Directory -Force -Path "$backupDir\keystores" | Out-Null
    Copy-Item "android\app\*.jks" "$backupDir\keystores\" -Force -ErrorAction SilentlyContinue
}

# Backup .gitignore
Copy-Item ".gitignore" "$backupDir\configs\gitignore.backup" -Force -ErrorAction SilentlyContinue

Write-Host "Backup complete: $backupDir" -ForegroundColor Green
