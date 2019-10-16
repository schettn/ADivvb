try
{
    $NTFSList = Import-Csv -Path "$PSScriptRoot\..\Lightbulb\NTFS.csv" -Delimiter ";"

    ForEach ($NTFS in $NTFSList)
    {
        $Path = $NTFS.Path
        $Group = $NTFS.Group
        $Permissions = $NTFS.Permissions
        $Inheritance = $NTFS.Inheritance
        
        Write-Host -ForegroundColor Yellow "Creating: $Path $Group $Permissions "
        $Acl = Get-Acl $Path
        $AccessRule = New-Object system.Security.AccessControl.FileSystemAccessRule(${Group}, ${Permissions}, "ContainerInherit, ObjectInherit", "None", "Allow")
        $Acl.SetAccessRule($AccessRule)
        if ($Inheritance -eq "False")
        {
            $Acl.SetAccessRuleProtection($True,$false)
        }
        $Acl | Set-Acl $Path
        Write-Host -ForegroundColor Green "Created: $Path $Group $Permissions "
    }
}
catch
{
    Write-Host -ForegroundColor Red $error[0].Exception.Message
}