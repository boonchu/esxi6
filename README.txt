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

                  