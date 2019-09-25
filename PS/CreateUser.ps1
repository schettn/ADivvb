$CSVFile = "$PSScriptRoot\..\CSV\users.csv"
$UserList = Import-Csv $CSVFile -Delimiter ";"

ForEach ($User in $UserList)
{
    try{
        $Username = $User.Username
        $Password = $User.Password
        $Firstname = $User.Firstname
        $Lastname = $User.Lastname
        $Department = $User.Department
        $Path = $User.Path
        $Group = $User.Group

        Write-Host -ForegroundColor Yellow "Creating: $Username"
        New-ADUser -Name "$Firstname $Lastname" -SamAccountName $Username -UserPrincipalName "$Username@nwtk.local" -GivenName $Firstname -Surname $Lastname -Enabled $true -ChangePasswordAtLogon $true -DisplayName "$Lastname $Firstname" -Department $Department -Path $Path -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force)
        if ($Group)
        {
        Add-ADGroupMember -Identity $Group -Members $Username
        }
        Write-Host -ForegroundColor Green "Created: $Username"

    }catch{
        Write-Host -ForegroundColor red $error[0].Exception.Message
    }
}
