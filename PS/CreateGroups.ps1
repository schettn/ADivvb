$CSVFile = "..\CSV\groups.csv"
$Groups = Import-Csv $CSVFile -Delimiter ";"

foreach($Group in $Groups){

    try{

    $GroupName = $Group.name
    $GroupPath = $Group.path
    $GroupMembers = $Group.members


    #print the OU'sname and the path
    Write-Host -ForegroundColor Blue $GroupName $GroupPath $GroupMembers

    New-ADGroup -name $GroupName -GroupScope Global -Path $GroupPath
    
    #add group members 
    if ($GroupMembers){
    foreach($group in $GroupMembers.split(',')){
         
        Add-ADGroupMember -Identity "$GroupName" -Members $group
        #display confirmation
        Write-Host -ForegroundColor Green "Group $GroupName successfuly create with users: $group"
        }
    }else{
        #display confirmation
        Write-Host -ForegroundColor Green "Group $GroupName successfuly created"
    }
   
    }catch{
        Write-Host -ForegroundColor red $error[0].Exception.Message
    }
}