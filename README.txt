#### ESXI 6 Powershell ####

 * Follow this instruction to have Powershell ISE to work with PowerCLI

    https://sandfeld.net/powershell-add-vmware-powercli-to-powershell-ise-on-demand/
 
 * How-to access Datastore from PowerCLI

    http://kunaludapi.blogspot.in/2015/09/powercli-copy-files-from-your-computer.html
    http://kunaludapi.blogspot.com/2015/09/powercli-get-esxcli-install-vib-files.html

```
vmstore:\sjc_sub_a> cd .\NFSVVOL
vmstore:\sjc_sub_a\NFSVVOL> dir

Name                           Type                 Id             
----                           ----                 --             
node1.example.com              DatastoreFolder                     
node2.example.com              DatastoreFolder                     
.dvsData                       DatastoreFolder                     
.iorm.sf                       DatastoreFolder                     
centos7_template               DatastoreFolder                     
.vSphere-HA                    DatastoreFolder

vmstore:\sjc_sub_a\NFSVVOL> mkdir vib

Name                           Type                 Id             
----                           ----                 --             
vib                            DatastoreFolder
```

 * How to install vib with fabric

```
$ fab -f ./esxi_fabric.py e:esxi install_vib
customize environment from fabfile_local.py (if any)
Setting environment esxi
[esxi-a-01.example.com] Executing task 'install_vib'
[esxi-a-01.example.com] put: esxui-signed-4215448.vib -> /tmp/esxui-signed-4215448.vib
[esxi-a-01.example.com] run: esxcli software vib install -v /tmp/esxui-signed-4215448.vib
[esxi-a-01.example.com] out: Installation Result
[esxi-a-01.example.com] out:    Message: Operation finished successfully.
[esxi-a-01.example.com] out:    Reboot Required: false
[esxi-a-01.example.com] out:    VIBs Installed: VMware_bootbank_esx-ui_1.7.1-4215448
[esxi-a-01.example.com] out:    VIBs Removed: VMware_bootbank_esx-ui_1.0.0-3617585
[esxi-a-01.example.com] out:    VIBs Skipped:
[esxi-a-01.example.com] out:

[esxi-a-02.example.com] Executing task 'install_vib'
[esxi-a-02.example.com] put: esxui-signed-4215448.vib -> /tmp/esxui-signed-4215448.vib
[esxi-a-02.example.com] run: esxcli software vib install -v /tmp/esxui-signed-4215448.vib
[esxi-a-02.example.com] out: Installation Result
[esxi-a-02.example.com] out:    Message: Operation finished successfully.
[esxi-a-02.example.com] out:    Reboot Required: false
[esxi-a-02.example.com] out:    VIBs Installed: VMware_bootbank_esx-ui_1.7.1-4215448
[esxi-a-02.example.com] out:    VIBs Removed: VMware_bootbank_esx-ui_1.0.0-3617585
[esxi-a-02.example.com] out:    VIBs Skipped:
[esxi-a-02.example.com] out:


Done.
```
