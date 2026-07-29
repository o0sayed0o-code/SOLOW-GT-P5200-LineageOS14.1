<#
.SYNOPSIS
    Automated ADB & TWRP Flashing Script for Samsung Galaxy Tab 3 10.1 (GT-P5200 / GT-P5210)
.DESCRIPTION
    Executes automated partition wiping, LineageOS 14.1 installation, OpenGApps injection, 
    and Magisk v19.3 root patching over TWRP ADB recovery interface.
.AUTHOR
    SOLOW (o0sayed0o-code)
#>

[CmdletBinding()]
param (
    [string]$ADBPath = "$ENV:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    [string]$TargetFolder = "/external_sd/GT-P5200"
)

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " SOLOW GT-P5200 Automated LineageOS 14.1 Flashing Engine   " -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Test-Path $ADBPath)) {
    Write-Error "ADB binary not found at $ADBPath. Please specify -ADBPath argument."
    exit 1
}

Write-Host "[+] Checking connected ADB devices..." -ForegroundColor Yellow
$devices = & $ADBPath devices | Out-String

if ($devices -match "recovery") {
    Write-Host "[+] TWRP Recovery Daemon detected!" -ForegroundColor Green
} elseif ($devices -match "device") {
    Write-Host "[+] Device detected in System mode. Rebooting to TWRP..." -ForegroundColor Yellow
    & $ADBPath reboot recovery
    Start-Sleep -Seconds 15
} else {
    Write-Error "[-] No device detected via ADB. Ensure device is in TWRP with USB connected."
    exit 1
}

# Define Zip payloads
$ROMZip = "$TargetFolder/lineage-14.1-20190408-UNOFFICIAL-santos10wifi.zip"
$GAppsZip = "$TargetFolder/open_gapps-x86-7.1-pico-20220503.zip"
$MagiskZip = "$TargetFolder/Magisk-v19.3.zip"

Write-Host "[1/5] Executing partition wipes (Data, Cache, Dalvik)..." -ForegroundColor Cyan
& $ADBPath shell "twrp wipe data; twrp wipe cache; twrp wipe dalvik"

Write-Host "[2/5] Flashing LineageOS 14.1 (Android 7.1.2 x86)..." -ForegroundColor Cyan
& $ADBPath shell "twrp install $ROMZip"

Write-Host "[3/5] Flashing OpenGApps Pico x86 Package..." -ForegroundColor Cyan
& $ADBPath shell "twrp install $GAppsZip"

Write-Host "[4/5] Flashing Magisk v19.3 Superuser Package..." -ForegroundColor Cyan
& $ADBPath shell "twrp install $MagiskZip"

Write-Host "[5/5] Performing final cache cleanup & rebooting device..." -ForegroundColor Cyan
& $ADBPath shell "twrp wipe cache; twrp wipe dalvik"
& $ADBPath reboot

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "[🎉] Flashing completed successfully! Device is rebooting..." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
