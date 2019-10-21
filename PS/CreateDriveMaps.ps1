$drives = Import-Csv -Path "$PSScriptRoot\..\csv\maps.csv" -Delimiter ";"

function New-Linked-GPO
{
    param([string]$Name, [string]$Target)
    $G = $null
    try{
        New-GPO -name $Name -ErrorAction Stop | New-GPLink -Target $Target -LinkEnabled Yes
        $G = Get-GPO -name $Name
    }
    catch{
        $G = Get-GPO -name $Name
    }
    return $G
 
}

forEach($drive in $drives){
    Write-Host $drive
    $gpo = New-Linked-GPO -Name $drive.GPOName -Target $drive.Target
    Map -GUID $gpo.id -DNSDomainName $drive.DNSDomainName -Target $drive.Target -Letter $drive.Letter -SharePath $drive.SharePath -Label $drive.Label -allDrivesVisibility $drive.allDrivesVisibility -thisDriveVisibility $drive.thisDriveVisibility -action $drive.action -persistent $drive.persistent
}

function Map
{
    param([string]$GUID, [string]$DNSDomainName, [string]$Target, [string]$Letter, [string]$SharePath, [string]$Label,[string]$allDrivesVisibility,[string]$thisDriveVisibility,[string]$action, [string]$persistent)

    $pathToDrives = "\\$DNSDomainName\Sysvol\$DNSDomainName\Policies\{$GUID}\User\Preferences\Drives"
    $pathToDrivesXML = "$pathToDrives\Drives.xml"
    if(Test-Path -Path $pathToDrivesXML){
        [xml]$drivesXml = (Get-Content $pathToDrivesXML)

        [System.Xml.XmlElement]$Drive = $drivesXml.CreateElement("Drive")
        $Drive.SetAttribute("clsid","{935D1B74-9CB8-4e3c-9914-7DD559B7A417}")
        $Drive.SetAttribute("name",$Letter+":")
        $Drive.SetAttribute("status",$Letter+":")
        $Drive.SetAttribute("image","1")
        $today = (Get-Date).ToString('yyyy-MM-dd hh:mm:ss')
        $Drive.SetAttribute("changed","$today")
        $uid = New-Guid
        $Drive.SetAttribute("uid","{$uid}")

        [System.Xml.XmlElement]$DriveProperty = $Drive.AppendChild($drivesXml.CreateElement("Properties"))
        $DriveProperty.SetAttribute("action",$action)
        $DriveProperty.SetAttribute("thisDrive",$thisDriveVisibility)
        $DriveProperty.SetAttribute("allDrives",$allDrivesVisibility)
        $DriveProperty.SetAttribute("userName","")
        $DriveProperty.SetAttribute("path",$SharePath)
        $DriveProperty.SetAttribute("label",$Label)
        $DriveProperty.SetAttribute("persistent",$persistent)
        $DriveProperty.SetAttribute("useLetter","1")
        $DriveProperty.SetAttribute("letter",$Letter)

        $drivesXml.DocumentElement.AppendChild($Drive)
        $drivesXml.save($pathToDrivesXML)
        
    }else{
        [System.Xml.XmlDocument]$drivesXml = New-Object System.Xml.XmlDocument

        $dec = $drivesXml.CreateXmlDeclaration("1.0", "UTF-8", $null)
        $drivesXml.AppendChild($dec)

        [System.Xml.XmlElement]$Root = $drivesXml.CreateElement("Drives")
        $Root.SetAttribute("clsid", "{8FDDCC1A-0C3C-43cd-A6B4-71A6DF20DA8C}")
        
        [System.Xml.XmlElement]$Drive = $Root.AppendChild($drivesXml.CreateElement("Drive"))
        $Drive.SetAttribute("clsid","{935D1B74-9CB8-4e3c-9914-7DD559B7A417}")
        $Drive.SetAttribute("name",$Letter+":")
        $Drive.SetAttribute("status",$Letter+":")
        $Drive.SetAttribute("image","1")
        $today = (Get-Date).ToString('yyyy-MM-dd hh:mm:ss')
        $Drive.SetAttribute("changed","$today")
        $uid = New-Guid
        $Drive.SetAttribute("uid","{$uid}")

        [System.Xml.XmlElement]$DriveProperty = $Drive.AppendChild($drivesXml.CreateElement("Properties"))
        $DriveProperty.SetAttribute("action",$action)
        $DriveProperty.SetAttribute("thisDrive",$thisDriveVisibility)
        $DriveProperty.SetAttribute("allDrives",$allDrivesVisibility)
        $DriveProperty.SetAttribute("userName","")
        $DriveProperty.SetAttribute("path",$SharePath)
        $DriveProperty.SetAttribute("label",$Label)
        $DriveProperty.SetAttribute("persistent",$persistent)
        $DriveProperty.SetAttribute("useLetter","1")
        $DriveProperty.SetAttribute("letter",$Letter)

        $drivesXml.AppendChild($Root)
        Write-Host $pathToDrives
        New-Item -Path "$pathToDrives" -ItemType Directory
        $drivesXml.save($pathToDrivesXML)
    
    }
    $gptinifilename = "\\$DNSDomainName\Sysvol\$DNSDomainName\Policies\{$GUID}\GPT.ini"
    $gptini | Out-File $gptinifilename -Encoding utf8

    $gpCMachineExtensionNames = "[{5794DAFD-BE60-433f-88A2-1A31939AC01F}{2EA1A81B-48E5-45E9-8BB7-A6E3AC170006}]"
    $adgpo = ([adsisearcher]"(&(objectCategory=groupPolicyContainer)(name={$guid}))").FindAll().Item(0)
    $gpoentry = $adgpo.GetDirectoryEntry()
    $gpoentry.Properties["gPCMachineExtensionNames"].Value = $gPCMachineExtensionNames
    $gpoentry.Properties["versionNumber"].Value = "131072"
    $gpoentry.CommitChanges()
    
}
