#Make sure to use Install-AzureAD and then Connect-AzureAD
#You can verify a successful connection if Get-AzureADUser works (Cancel if necessary)

try
{
    #CSV File Path. Change this location accordingly
    $filePath = "C:\...\CreateBulkSecurityGroups.csv"

    #read the input file
    $loadFile = Import-Csv -Path $filePath 

    foreach ($row in $loadFile)
    {
        #read file
        $displayname = $row.displayname
        $description = $row.description
        $enrollmentname = $row.enrollmentname

        #Write-Host "Item: "$displayname $description $enrollmentname

                        
        #create AzureAD Groups, but check if it exists first
        if($createdgroup = Get-AzureADGroup -Filter "DisplayName eq '$displayname'")
        {
        Write-Host "Group exists, Description and Memebership Rules are being updated..."
        } 
        else 
        {
            Write-Host "Group does not exist, Creating Group..."
            $createdgroup = New-AzureADGroup -Displayname $displayname -Description $description -SecurityEnabled $true -MailEnabled $false -MailNickName "NotSet"
            Write-Host "Group: " $createdgroup.objectid " with Name: " $createdgroup.displayname " is created."

            #Waiting for Group Creation
            Do
            {
            #Get-AzureADGroup -Filter "DisplayName eq '$displayname'"
            #Write-Host "not found"
            Start-Sleep -Seconds 5
            } until (Get-AzureADGroup -Filter "DisplayName eq '$displayname'")
            
               
        }
                
        #Set Dynamic Memebership for new groups
        Write-Host "Setting Dynamic Membership and Rule for Group: " $createdgroup.displayname
        Set-AzureADMSGroup -Id $createdgroup.ObjectId -GroupTypes “DynamicMembership” -MembershipRule “(device.enrollmentProfileName -eq ""$enrollmentname"")” -MembershipRuleProcessingState “On” -Description $description
        Write-Host $createdgroup.DisplayName "done." -ForegroundColor Green  
           
     
    }

    Write-Host "-------------------------------------------"
    Write-Host "All" $loadFile.Count "Security Groups were created/updated." -ForegroundColor Green -BackgroundColor Black

}

catch
{
      Write-Host "An error occurred:"
      Write-Host $_
      Write-Host "------------------------------------------"
      Write-Host "Last Item started: " $displayname -BackgroundColor Green
}