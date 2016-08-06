$cluster_name = 'micro_cluster_a'
$dc_name = 'sjc_sub_a'

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

# enable vmware HA cluster mode to enable High availability
Set-Cluster $(get-cluster micro_cluster_a) -HAEnabled:$true -Confirm:$false

# enable vmware DRS mode
Set-Cluster $(get-cluster micro_cluster_a) -DRSEnabled:$true -DRSAutomationLevel "Manual" -Confirm:$false

# create a new virtual distributed switch "VDS-cluster_a"
$vds = New-VDSwitch -name "VDS-cluster_a" -Location $(get-datacenter sjc_sub_a)
echo $vds

# adding ESX host to VDS
foreach ($esx in $esx_hosts) {
    Add-VDSwitchVMHost -VDSwitch $vds -VMHost $esx
}

# get which ESX hosts are inside distributed switch
Get-VMHost -DistributedSwitch $vds

# Create VDS portgroups
$pgManagement = New-VDPortgroup $vds -Name "management"
$pgvMotion = New-VDPortgroup $vds -Name "vMotion"
$pgStorage = New-VDPortgroup $vds -Name "storage"
$pgVM = New-VDPortgroup $vds -Name "VM"

# Scanning to have virtual nics on each IP
foreach ($esx in $esx_hosts) {
    Get-VMHostNetworkAdapter -VMKernel -VirtualSwitch vSwitch0 -VMHost $esx | select "ip","subnetmask","devicename"
}

# Get a list of portgroups
Get-VDPortgroup -VDSwitch $vds

# Adding physical adapters vmnic1 for vMotion
foreach ($esx in $esx_hosts) {
    $nic = get-vmhost $esx | Get-VMHostNetworkAdapter -Physical -Name vmnic1
    Get-VDSwitch $vds | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $nic -Confirm:$false
}


