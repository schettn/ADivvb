try
{
    $fs = Get-WindowsFeature *FS-Resource-Manager* 
    if ($fs.Installed -eq $false)
    {
        Install-WindowsFeature -Name FS-Resource-Manager -IncludeManagementTools
    }
    $QuotasList = Import-Csv -Path "$PSScriptRoot\..\Lightbulb\Quotas.csv" -Delimiter ";"

    ForEach ($Quota in $QuotasList)
    {
        $Path = $Quota.Path
        $Size = $Quota.Size
        $Description = "limit usage to $Size"

        Write-Host -ForegroundColor Yellow "Creating: $Path $Description"
        New-FsrmQuota -Path $Path -Description $Description -Size ($Size / 1)
        Write-Host -ForegroundColor Green "Created: $Path $Description"
    }
    
}
catch
{
    Write-Host -ForegroundColor Red $error[0].Exception.Message
}