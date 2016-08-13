# Load own custom functions at startup
$OwnFunctionsDir = "$env:USERPROFILE\Documents\GitHub\esxi6"
Write-Host "Loading own PowerShell functions from:" -ForegroundColor Green
Write-Host "$OwnFunctionsDir" -ForegroundColor Yellow
Get-ChildItem "$OwnFunctionsDir\ise_env_setup.ps1" | %{.$_}
Write-Host ''

Load-PowerCLI