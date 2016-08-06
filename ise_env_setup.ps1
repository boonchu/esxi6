function Load-PowerCLI
{
    Add-PSSnapin VMware.VimAutomation.Core
    Add-PSSnapin VMware.VimAutomation.Vds
    Add-PSSnapin VMware.VumAutomation
    . "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

function Unload-PowerCLI
{
    Remove-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
    Remove-PSSnapin VMware.VimAutomation.Vds -ErrorAction SilentlyContinue
    Remove-PSSnapin VMware.VumAutomation -ErrorAction SilentlyContinue
}

