$FolderNameToRemove = "C:\RMM\"
if (Test-Path $FolderNameToRemove) {
 
    Write-Host "This folder exists"
    Remove-Item $FolderNameToRemove -Recurse -Force
} else {
    Write-Host "This folder doesn't exists!"
}

$FolderNameToRemove = "C:\RMM2\"
if (Test-Path $FolderNameToRemove) {
 
    Write-Host "This folder exists"
    Remove-Item $FolderNameToRemove -Recurse -Force
} else {
    Write-Host "This folder doesn't exists!"
}

$FolderNameToRemove = "C:\RMM3\"
if (Test-Path $FolderNameToRemove) {
 
    Write-Host "This folder exists"
    Remove-Item $FolderNameToRemove -Recurse -Force
} else {
    Write-Host "This folder doesn't exists!"
}

$FolderNameToRemove = "C:\RMM4\"
if (Test-Path $FolderNameToRemove) {
 
    Write-Host "This folder exists"
    Remove-Item $FolderNameToRemove -Recurse -Force
} else {
    Write-Host "This folder doesn't exists!"
}

$FolderNameToRemove = "C:\RMMCC\"
if (Test-Path $FolderNameToRemove) {
 
    Write-Host "This folder exists"
    Remove-Item $FolderNameToRemove -Recurse -Force
} else {
    Write-Host "This folder doesn't exists!"
}

$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "ScreenConnect Client (b178b8426e650de6)"}
$MyApp.Uninstall()

