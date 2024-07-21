##########################################################################################
#                                                                                          #
#  TITLE:        SilverstoneActiveUsersReport.ps1                                          #
#  VERSION:      v.1.1                                                                     #
#  DATE:         9/07/2024                                                                 #
#  AUTHOR:       Haydn Pocklington (CorpCloud)                                             #
#  CLIENT:       SilverStone Recruitment                                                   #
#  DESCRIPTION:  Sets up a Scheduled Task on a Server to run a reoccuring report           #
#			     at a selectable number of days before the end-of-month of all the         #
#                currently active users in the SilverStone MS O365 Tenancy and save        #
#                that months results before emailing them to a SilverStone email account.  #
#                                                                                          #
##########################################################################################
 
 
### VARIABLES ###
 
$daysBeforeEndOfMonth  = 5
$to                    = "extadmin@sstone.com.au"
# $cc                  = "support@corpcloud.com.au"
 
 
### CODE ###
 
# Import Module to connect to SilverStone O365 Tenancy               
Import-Module ExchangeOnlineManagement
 
# Set the SilverStone Email Sender
$adminUser = "extadmin@sstone.com.au"
$adminPass = "#5ilver5tone#24" | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUser, $adminPass
 
# Connect to SilverStone O365 Tenancy
Connect-ExchangeOnline -UserPrincipalName $adminUser -Credential $credential
 
# Get the list of all active SilverStone O365 Users
$activeUsers = Get-User -ResultSize Unlimited | Where-Object { $_.UserPrincipalName -ne $null }
 
# Set up the SilverStone active user report and email
$daysBeforeEndOfMonth = 5
$endOfMonth = (Get-Date).AddMonths(1).AddDays(-((Get-Date).AddMonths(1).Day))
$reportDate = $endOfMonth.AddDays(-$daysBeforeEndOfMonth)
$report = $activeUsers | Select-Object DisplayName, UserPrincipalName, WhenCreated | ConvertTo-Html -Fragment
$subject = "Active Users Report - $(Get-Date -Format 'dd-MM-YYYY')"
$body = "Please find the attached active users report for this month.<br><br>$report"
$attachmentPath = "C:\Reports\ActiveUsersReport_$(Get-Date -Format 'dd-MM-YYYY').html"
$report | Out-File -FilePath $attachmentPath
# Alternatively the SmtpServer can be set to "smtp.office365.com" if the SilverStone MX does not work
Send-MailMessage -To $to -Cc $cc -Subject $subject -Body $body -BodyAsHtml -SmtpServer "sstone-com-au.mail.protection.outlook.com" -From $adminUser -Attachments $attachmentPath
 
# Set up the SilverStone active user report reoccuring schedule
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$PSScriptRoot\SilverstoneActiveUsersReport.ps1`""
$trigger = New-ScheduledTaskTrigger -At $reportDate -Once
$principal = New-ScheduledTaskPrincipal -UserId $adminUser -LogonType Password -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "SilverStone-MonthlyActiveUsersReport"
 
# Disconnect from SilverStone O365 Tenancy
Disconnect-ExchangeOnline -Confirm:$false