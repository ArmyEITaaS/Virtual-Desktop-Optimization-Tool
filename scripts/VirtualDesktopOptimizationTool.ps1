$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

###########################################
## Run Virtual Desktop Optimization Tool ##
###########################################

Write-Output "Starting Script - Virtual Desktop Optimization Tool"

$VdotDirectoryPath = "C:\virtual-desktop-optimization-tool\"
if (-not (Test-Path $VdotDirectoryPath)) {
    throw "Failed to find certificates temporary directory."
}

$VdotScript = Get-ChildItem -Path $VdotDirectoryPath -Recurse -File -Filter "Windows_VDOT.ps1"
if (($VdotScript.Count -eq 0) -or ($null -eq $VdotScript)) {
    throw "Failed to find virtual desktop optimization tool script 'Windows_VDOT.ps1' within directory '$VdotDirectoryPath'"
}

Write-Output "Starting virtual desktop optimization tool"
& $VdotScript.FullName -Optimizations "All" -AdvancedOptimizations "Edge" -AcceptEULA

Write-Output "Completed Script - Virtual Desktop Optimization Tool"
