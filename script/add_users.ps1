# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv C:\Users\Администратор\add_users.csv
$AsGroups = Import-csv -Path C:\Users\Администратор\Groups.csv
$AsMembers = Import-csv -Path C:\Users\Администратор\userInGroups.csv 
#$DelADUserfromGroup = Get-Content C:\Users\Администратор\DelUserfromGroups.txt
$DelADGroup = Get-Content C:\Users\Администратор\DelGroups.txt
#$pathToCSV = ',\userInGroups.csv'
#$csv = Import-Csv -path $pathToCSV -Delimeter ';'


#Loop through each row containing user details in the CSV file CREATE USER
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$Username 	= $User.username
	$Password 	= $User.password
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
	$OU 		= $User.ou #This field refers to the OU the user account is to be created in

    $Password = $User.Password


	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@winadpro.com" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
            
	}
	Write-Host -ForegroundColor Green "Users $($User.Username) created!"
}





#CREATE_GROUP

foreach($group in $AsGroups)
	{
		$create_group = New-ADGroup -Name $group.GroupName -groupScope $group.GroupScope -Path $group.OU 
		Write-Host -ForegroundColor DarkCyan "Group $($group.GroupName) created!"
	}



#DELETE_GROUP
foreach($delGroup in $DelADGroup)
	{
		$delGroup | % {Remove-ADGroup -Identity "$_" -Confirm:$false}
		Write-Host -ForegroundColor DarkRed "Group $($delGroup) deleted!"
	}

#ADD_Users_In_Group
		
	foreach($line in $AsMembers)
	{
		$userGroup = $line.Username -split ";"
		$groupsList = $line.Groupname
		foreach($user in $users){
		Add-ADGroupMember -Identity $groupsList -Members $userGroup
		}
	}



