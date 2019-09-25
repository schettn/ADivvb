$CSVFile = "..\CSV\ous.csv"
$OUs = Import-Csv $CSVFile -Delimiter ";"

foreach($OU in $OUs){

    try{

    $OUName = $OU.name
    $OUPath = $OU.path


    #print the OU'sname and the path
    Write-Host -ForegroundColor Blue $OUName $OUPath

    #create OU
    New-ADOrganizationalUnit -Name $OUName -Path $OUPath -ProtectedFromAccidentalDeletion $false

    #display confirmation
    Write-Host -ForegroundColor Green "Successfuly create OU $OUName"
    }catch{
        Write-Host -ForegroundColor red $error[0].Exception.Message
    }
}