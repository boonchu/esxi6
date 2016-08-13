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


# attach vmnic0 to management Traffic
foreach ($esx in $esx_hosts) {
    $dvportgroup = Get-VDPortgroup -name $pgManagement -VDSwitch $vds
    $vmk = Get-VMHostNetworkAdapter -name vmk0 -VMHost $esx
    Set-VMHostNetworkAdapter -PortGroup $dvportgroup -VirtualNic $vmk -Confirm:$false
}

# list host network apdater and enable Management Traffic and vMotion and disable vSAN
Get-VMHostNetworkAdapter | where { $_.PortGroupName -eq $pgManagement } | Set-VMHostNetworkAdapter -VMotionEnabled $true -VsanTrafficEnabled $false -ManagementTrafficEnabled $true


# enable vmware HA cluster mode to enable High availability
Set-Cluster $(get-cluster micro_cluster_a) -HAEnabled:$true -Confirm:$false
# enable vmware DRS mode
Set-Cluster $(get-cluster micro_cluster_a) -DRSEnabled:$true -DRSAutomationLevel "Manual" -Confirm:$false




####### Use this instruction when you have different network topology ########
####### vMotion in vmnic1 #######

$vmotion_net = @{
    'esxi-a-01.example.com'='192.168.1.10';
    'esxi-a-02.example.com'='192.168.1.11';
}


$vmotion_net.GetEnumerator() | % {
    Write-Host "Add VMHost Esx Host is : $($_.Key) = $($_.Value)"
    New-VMhostNetworkAdapter -vmhost $_.Key -ip $_.Value -portgroup vMotion -virtualswitch $vds -subnetmask 255.255.255.0
}

# get VMhost info
$hosts = Get-VMHost esxi-a-01.example.com, esxi-a-02.example.com
echo $hosts

# attach vmnic1 to vMotion Traffic
foreach ($esx in $esx_hosts) {
    $pNic = Get-VMHostNetworkAdapter -VMHost $esx -Physical -name vmnic1
    $vNicManagement = Get-VMHostNetworkAdapter -VMHost $esx -Name vmk1

    $pNic
    $vNicManagement

    Add-VDSwitchPhysicalNetworkAdapter -DistributedSwitch $vds -VMHostPhysicalNic $pNic -VMHostVirtualNic $vNicManagement -VirtualNicPortgroup $pgvMotion -Confirm:$false

}


# list host network apdater and enable vMotion Traffic
Get-VMHostNetworkAdapter | where { $_.PortGroupName -eq $pgvMotion } | Set-VMHostNetworkAdapter -VMotionEnabled $true

