############################################################### 
# removeprotectionagainstaccidentaldeletion_OUs_v1.0.ps1 
# input : n/a 
# output : none (logs) 
# Version 1.0 
# Changelog : n/a 
# MALEK Ahmed - 20 / 12 / 2012 
################### 
 
################## 
#--------Config 
################## 
$searchbase = "DC=AVA,DC=TEST,DC=DOMAIN" 
         
################## 
#--------Main   
################## 
#Remove Protection of Organizational units against accidental deletion 
import-module activedirectory 
Get-ADOrganizationalUnit -searchbase $searchbase -filter * -Properties ProtectedFromAccidentalDeletion | where {$_.ProtectedFromAccidentalDeletion -eq $true} | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false