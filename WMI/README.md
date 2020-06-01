# Token Monitoring via WMI by un4gi                           
twitter.com/un4gii | hackerone.com/un4gi | github.com/un4gi 
                                                           
WMI Event Subscriptions require three pieces: An event filter, an event consumer, and a filter to consumer binding.
These can be made to execute various tasks, but in this example we are using WMI to monitor a file for token changes.

This was thrown together in a rush effort to prevent our tokens from being overwritten during SANS Netwars.
With this being the case, there is still much room for improvement so feel free to modify as you see fit.

## Set-up
The following commands will need to be used to build each WMI object in powershell. Be sure to replace the file paths for each object you create.
Note that a powershell script will need to be created to be executed in the WMI Event Consumer. Three of these have been pre-made for SMB, FTP, and OHSDB.

### This builds the query string to be used when creating the WMI Event Filter
```
$Query = @"
Select * from __InstanceCreationEvent within 1 where targetInstance isa 'Cim_DirectoryContainsFile' and targetInstance.GroupComponent = 'Win32_Directory.Name="C:\\\\share\\tokens"'
"@
```

### This builds the WMI Event Filter.
```
$WMIEventFilter = Set-WmiInstance -Class __EventFilter -NameSpace "root\subscription" -Arguments @{Name="WatchSMB";
EventNameSpace="root\cimv2";
QueryLanguage="WQL";
Query=$Query
}
```

### This builds the WMI Event Consumer
```
$WMIEventConsumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\subscription" -Arguments @{Name="WatchSMB";
ExecutablePath = "C:\\Windows\\System32\\WindowsPowershell\\v1.0\\powershell.exe";
CommandLineTemplate = "C:\\Windows\\System32\\WindowsPowershell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -File C:\\smb.ps1"
}
```

### This binds the WMI Event Filter to the WMI Event Consumer
```
Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\subscription" -Arguments @{Filter=$WMIEventFilter;
Consumer=$WMIEventConsumer
}
```

### To remove the WMI objects, the following commands can be used:
`Get-WmiObject __EventFilter -namespace root\subscription -filter "name='WatchSMB'" | Remove-WmiObject`

`Get-WmiObject CommandLineEventConsumer -namespace root\subscription -filter "name='WatchSMB'" | Remove-WmiObject`

`Get-WmiObject __FilterToConsumerBinding -Namespace root\subscription -filter "Filter = ""__eventfilter.name='WatchSMB'""" | Remove-WmiObject`
