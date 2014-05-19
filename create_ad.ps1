Import-module ActiveDirectory

# Crude Random Password Generator 
Function GeneratePassword
{
    # How many Characters Minimum?
    $Length=15
    # Create a password choosing everying from Character 34 to 127
    1..$Length | foreach{ $Password+=([char]((Get-Random 93)+34))}
    # Convert to a Secure String
    $Password=Convertto-SecureString $Password -asplaintext -force
    Return $Password
}

Function GET-GroupInfo()
{
    Param($City,$Division)
    $GroupName=$City.replace(" ","")+"-"+$Division.replace(" ","")
    $GroupDescription="$Division in $City Access Group"
    # Return the Results (This is a feature new to version 3)
    [pscustomobject]@{Name=$Groupname;Description=$GroupDescription}
}

# Define OU at Base of AD for Offices
$BaseOU="Marvel Small"
#$BaseOU="Marvel Medium"
#$BaseOU="Marvel Large"
# Provide List of Office Names
$CityOU="Avengers Mansion","Rikers Island","Stark Tower","Sanctum Sanctorum","Ravencroft","Asgard"
# Provide List of Divisions Per Office
$DivisionOU="IT","Sales","Marketing","HR","Architecture","Operations","Development","Strategy","Finance","Administration","Security","Logistics","Customer Services","Research & Development","Market Development","Business Development","Management","Engineering","Infrastructure"
# DistinguishedName of Domain Root
$Domain="DC=test,DC=domain"
# Whatever the name of the $BaseOU Combined with Domain
$CompanyPath="OU=$BaseOU,"+$Domain
# UPN Extension to the Domain
$UPN="@test.domain"
# Create BaseOU for Offices
NEW-ADOrganizationalUnit -name $BaseOU -path $Domain

# Gather through list of Cities
Foreach ($City in $CityOU) 
{
    # Create OU for City
    NEW-ADOrganizationalUnit -path $CompanyPath -name $City
    # Gather through list of Divisions
    Foreach($Division in $DivisionOU)
    {
        # Create Division within City
        NEW-ADOrganizationalUnit -path "OU=$City,$CompanyPath" -name $Division
        # Create Group within Division and Description
        $Groupdata=GET-Groupinfo –City $City –Division $Division
        $GroupName=$Groupdata.Name
        $GroupDescription=$Groupdata.Description
        NEW-ADGroup -name $GroupName -GroupScope Global -Description $GroupDescription -Path "OU=$Division,OU=$City,$CompanyPath"
    }
}
# Pull together list of CSV raw data supplied from Generator
# 
$all_names=Get-Content C:\Script\marvel_names.txt
# Generate 150 Random Users from pulled Raw data
For ($x=0;$x -lt 500;$x++)
{
       $name=GET-Random $all_names
       $bits=$name.split(" ")
       $Firstname=$bits[0]
       $Lastname=$bits[1]
       $Displayname=$name
       # Pick a Random City
       $City=GET-RANDOM $Cityou
       #Pick a Random Division
       $Division=GET-RANDOM $DivisionOU
       $LoginID=$Firstname.substring(0,1)+$Lastname
       $UserPN=$LoginID+$UPN
       $Sam=$LoginID.padright(20).substring(0,20).trim()
       # Define their path in Active Directory
       $ADPath="OU=$Division,OU=$City,$CompanyPath"
       # Create the user in Active Directory
       New-ADUser -GivenName $Firstname -Surname $Lastname -DisplayName $Displayname -UserPrincipalName $UserPN -Division $Division -City $City -Path $ADPath -name $Displayname -SamAccountName $Sam -AccountPassword (GENERATEPASSWORD)
       # Add User to appropriate Security Group
       $Groupname=(GET-GroupInfo –city $City –division $Division).Name
       ADD-ADGroupmember $Groupname -members $Sam
       # Enable the account for access
       ENABLE-ADAccount $Sam
} 
