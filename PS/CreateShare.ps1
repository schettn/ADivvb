try
{
    $ShareList = Import-Csv -Path "$PSScriptRoot\..\Lightbulb\Shares.csv" -Delimiter ";"
    
    #Specify the remote computer
    $c = New-CimSession -ComputerName Fileshare

    ForEach ($Share in $ShareList)
    {
        $Name = $Share.Name
        $Path = $Share.Path
        $FullAccess = $Share.FullAccess
        $ChangeAccess = $Share.ChangeAccess

        Write-Host -ForegroundColor Yellow "Creating: $Name $Path $ChangeAccess"
        New-SmbShare -name $Name -path $Path -FullAccess $FullAccess -ChangeAccess $ChangeAccess -CimSession $c
        Write-Host -ForegroundColor Green "Created: $Name $Path"
    }
}
catch
{
    Write-Host -ForegroundColor Red $error[0].Exception.Message
}