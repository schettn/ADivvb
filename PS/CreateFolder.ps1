try
{
    $FolderList = Import-Csv -Path "$PSScriptRoot\..\Lightbulb\Folder.csv" -Delimiter ";"

    ForEach ($Folder in $FolderList)
    {
        $Path = $Folder.Path
        $Type = $Folder.Type

        Write-Host -ForegroundColor Yellow "Creating: $Type $Path"
        New-Item -Path $Path -Type $Type
        Write-Host -ForegroundColor Green "Created: $Type $Path"
    }
}
catch
{
    Write-Host -ForegroundColor Red $error[0].Exception.Message
}