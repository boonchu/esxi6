# Credential VMware Center Administration (VCA)
$vca_cred = Get-Credential
Connect-VIServer vca01.example.com -Credential $vca_cred

$datacenter = new-datacenter -location $(get-folder -norecursion) -name "sjc_sub_a"
$cluster = new-cluster -name "micro_cluster_a" -location "sjc_sub_a"

$esx_hosts = @(
    'esxi-a-01.example.com',
    'esxi-a-02.example.com'
)

# Credential ESX
$esx_cred = Get-Credential

# Adding Esx hosts to cluster folder
foreach ($esx in $esx_hosts) {
    Write-Host "Adding ESX host $esx to $(get-cluster micro_cluster_a)" -foregroundcolor green
    Add-VMhost -name $esx -Location $(get-cluster micro_cluster_a) -Credential $esx_cred -RunAsync -Confirm:$false -Force:$true
}

Write-Host "Done!" -foregroundcolor green

# enable vmware HA cluster mode
Set-Cluster $(get-cluster micro_cluster_a) -HAEnabled:$true -Confirm:$false
