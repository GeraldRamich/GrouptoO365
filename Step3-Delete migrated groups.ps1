#Simple script to clean up old DL that have been setting migrated to place holder group
#this is done as seperate step to ensure you have time to verify place holder groups.
$FilePath = "C:\DLExport\"
$OLDDG = Import-Csv $FilePath\distributiongroups_modified.csv
Write-output "Start running of Step3-Deleted Migrated Groups logging" >>$FilePath\Errorlogs.log
$ErrorActionPreference = ‘Stop’
Try
{
    Write-Verbose "Removing on premise Legacy DG $_.PrimarySmtpAddress" -Verbose
    $OLDDG | % {Remove-DistributionGroup -Identity $_.PrimarySmtpAddress -Confirm:$false} -ErrorAction Stop 
    Write-output "$(get-date) Success: Removed on premise Legacy DG $_.PrimarySmtpAddress" >>$FilePath\Errorlogs.log
}
Catch
{
    Write-Warning "Failed to Removing on premise Legacy DG $_.PrimarySmtpAddress - logging error"
    Write-output "$(get-date) Failure: Attempting to Removing on premise Legacy DG $_.PrimarySmtpAddress failed" >>$FilePath\Errorlogs.log
    $_ >>$FilePath\Errorlogs.log
}
#Optional
#Create a Mail enabled Object in a OU that is NOT sync via A AD Connect. The Target address will be the Alias@domain.onmicrosoft.com adddress of the corrsponding DL online. This allows
#Applications or on premise mailboxes to still send to the DL but we will not see duplicated in the O365 GAL. 
#Not part of script since the OU woudl have to be defined and the "Onmicrosoft,com" address is needed as well.