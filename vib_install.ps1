# Credential VMware Center Administration (VCA)
$vca_cred = Get-Credential
Connect-VIServer vca01.example.com -Credential $vca_cred

# get status of TSM-SSH service and enable it if disabled previously
foreach ($vmhost in (Get-Cluster -Name 'micro_cluster_a' | Get-VMHost | sort name)) {
    $esxcli = Get-EsxCli -VMHost $vmhost
    if ($esxcli -ne $null) {
        $esxcli.software.vib.list() | ft 
    }
}
