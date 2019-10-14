try
{
    $ShareList = Import-Csv -Path "$PSScriptRoot\..\Lightbulb\Shares.csv" -Delimiter ";"

    ForEach ($Share in $ShareList)
    {
        $Name = $Share.Name
        $Path = $Share.Path
        $FullAccess = $Share.FullAccess
        $ChangeAccess = $Share.ChangeAccess

        Write-Host -ForegroundColor Yellow "Creating: $Name $Path $FullAccess $ChangeAccess"
        New-SmbShare -name $Name -path $Path -FullAccess 'Domänen-Admins' -ChangeAccess 'InternUsers' 
        Write-Host -ForegroundColor Green "Created: $Name $Path"
    }
}
catch
{
    Write-Host -ForegroundColor Red $error[0].Exception.Message
}