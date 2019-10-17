try
{
    $NTFSList = Import-Csv -Path "$PSScriptRoot\..\Lightbulb\NTFS.csv" -Delimiter ";"

    ForEach ($NTFS in $NTFSList)
    {
        $Path = $NTFS.Path
        $Group = $NTFS.Group
        $Permissions = $NTFS.Permissions
        $Inheritance = $NTFS.Inheritance
        $Type = $NTFS.Type
        $Operation = $NTFS.Operation
        
        Write-Host -ForegroundColor Yellow "Creating: $Operation $Path $Group $Permissions $Type"
        $Acl = Get-Acl $Path
        $AccessRule = New-Object system.Security.AccessControl.FileSystemAccessRule(${Group}, ${Permissions}, "ContainerInherit, ObjectInherit", "None", ${Type})
        if ($Operation -eq "Set")
        {
            $Acl.SetAccessRule($AccessRule)
        }
        else
        {
            $Acl.RemoveAccessRule($AccessRule)
        }
        if ($Inheritance -eq "False")
        {
            $Acl.SetAccessRuleProtection($true,$false)
        }
        $Acl | Set-Acl $Path
        Write-Host -ForegroundColor Gre "Created: $Path $Group $Permissions $Type"
    }
}
catch
{
    Write-Host -ForegroundColor Red $error[0].Exception.Message
}