# Credential VMware Center Administration (VCA)
$vca_cred = Get-Credential
Connect-VIServer vca01.example.com -Credential $vca_cred

$esx_hosts = @(
    'esxi-a-01.example.com',
    'esxi-a-02.example.com'
)

# Credential ESX
$esx_cred = Get-Credential

# list all hosts
get-vmhost | format-table name, manufacturer, model, numcpu, version, build -autosize
# list all VMs
get-vmhost -name esxi* | get-vm

# get status of TSM-SSH service and enable it if disabled previously
foreach ($vmhost in (Get-Cluster -Name 'micro_cluster_a' | Get-VMHost | sort name)) {
    write-host "Configuring SSH on host $($vmhost.Name)" -ForegroundColor Yellow
    if ((Get-VMHostService $vmhost | where {$_.key -eq "TSM-SSH"}).Policy -ne "on") {
        write-host "[Setting] SSH service policy to automatic on $($vmhost.Name)"
        Get-VMHostService -VMHost $vmhost | where {$_.Key -eq "TSM-SSH"} | Set-VMHostService -Policy On -Confirm:$false -ea 1 | Out-null
    }
    else {
        write-host "[Setting] SSH service policy has already enabled at $($vmhost.Name)"
    }

    if ((Get-VMHostService $vmhost | where {$_.key -eq "TSM-SSH"}).Running -ne $true) {
        write-host "[Setting] SSH service is starting on $($vmhost.Name)"
        Start-VMHostService -HostService (Get-VMHost $vmhost | Get-VMHostService | Where {$_.Key -eq "TSM-SSH"}) | Out-Null
    }
    else {
        write-host "[Setting] SSH service has already running at $($vmhost.Name)"
    }
}

# show firewall policy on VMHosts
foreach ($vmhost in (Get-Cluster -Name 'micro_cluster_a' | Get-VMHost | sort name)) {
    $esxcli = Get-EsxCli -VMHost $vmhost
    if ($esxcli -ne $null) {
        $esxcli.network.firewall.ruleset.allowedip.list("sshServer")
    }
}

# change firewall policy on VMHosts
foreach ($vmhost in (Get-Cluster -Name 'micro_cluster_a' | Get-VMHost | sort name)) {
    $esxcli = Get-EsxCli -VMHost $vmhost
    if ($esxcli -ne $null) {
        if ( ($esxcli.network.firewall.ruleset.allowedip.list("sshServer") | select AllowedIPAddresses).AllowedIPAddresses -eq "All" ) {
            Write-Host "[Setting] Firewall access on $($vmhost.Name)"
            $esxcli.network.firewall.ruleset.set($false, $true, "sshServer")
            $esxcli.network.firewall.ruleset.allowedip.add("192.168.0.101", "sshServer")
            $esxcli.network.firewall.ruleset.allowedip.add("192.168.0.102", "sshServer")
            $esxcli.network.firewall.refresh()
        }
    }
}

