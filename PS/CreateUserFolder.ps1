try
{
    $Users = Get-ADUser -Filter * -SearchBase "OU=Intern,OU=Gespetto,DC=pinterid,DC=local"
    ForEach ($User in $Users)
    {
        $Path = "\\10.0.1.10\Homes17\$($User.SamAccountName)17"
        Write-Host -ForegroundColor Yellow "Creating: $Path"
        New-Item -Type Directory -Path $Path
        
        $fs = Get-WindowsFeature *FS-Resource-Manager* 
        if ($fs.Installed -eq $false)
        {
            Install-WindowsFeature -Name FS-Resource-Manager -IncludeManagementTools
        }
	    
        
        $Acl = Get-Acl $Path
        $AccessRule = New-Object system.Security.AccessControl.FileSystemAccessRule("Domänen-Admins", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
        $Acl.SetAccessRule($AccessRule)
        $AccessRule = New-Object system.Security.AccessControl.FileSystemAccessRule("$($User.SamAccountName)", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
        $Acl.SetAccessRule($AccessRule)
        $Acl.SetAccessRuleProtection($true,$false)
        $Acl | Set-Acl $Path
        Write-Host -ForegroundColor Green "Created: $Path"
    }
}
catch
{
    Write-Host -ForegroundColor Red $error[0].Exception.Message
}