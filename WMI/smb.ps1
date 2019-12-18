# This script will be called via the WMI events and is used to monitor the $WatchFolder for changes to the token.
# A separate powershell script will be required for each folder you want to watch (or you can modify as needed to combine into one).
$WatchFolder = "C:\Share\tokens" # Change this directory as necessary
$Files = (Get-ChildItem $WatchFolder).FullName
if ($Files) {
    Remove-Item $Files
    New-Item -Path "C:\Share\tokens" -Name "NetWars{R25TY5}" -ItemType "file" -Value "NetWars{R25TY5}" # Change the file name as necessary. Value should not matter for Netwars purposes.
    # Need to add check to add token if folder is empty
}
