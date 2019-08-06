#After you’ve validated the old distribution groups are no longer visible in Exchange Online, we can now unhide the new ones and remove “NEW” from the names. We’ll use the file (distributiongroups_modified.csv) to complete this task.
$FilePath = "C:\DLExport\"
$RENAMEDG = Import-Csv $FilePath\distributiongroups_modified.csv
$ErrorActionPreference = ‘Stop’
Write-output "$(get-date) Start running of Step 4- Rename and Unhiding" >>$FilePath\Errorlogs.log
$RENAMEDG | ForEach-Object {
    $NEWName = $($_.NEWName -replace '\s','')[0..63] -join "" # remove spaces first, then truncate to first 64 characters
    $Name=$_.Name
    $Alias=$_.Alias
    $DisplayName=$_.DisplayName
    $PrimarySmtpAddress=$_.PrimarySmtpAddress
    
    Write-Output ""
    Write-Output "working on Group: $Name"
    Write-Output ""
    Write-Output "$(get-date) Starting with Rename Step 1"  >>$FilePath\Errorlogs.log
   try 
    {
        Write-Verbose "Checking for Existing Cloud Name" -Verbose
        Set-DistributionGroup -Identity $NEWName -Name $Name -Alias $Alias -DisplayName $DisplayName -PrimarySmtpAddress $PrimarySmtpAddress -HiddenFromAddressListsEnabled $false -ErrorAction Stop 
        Write-Verbose "Renamed $NEWName to $Name" -Verbose
        Write-output "$(get-date) Success: Rename $NEWName to $Name completed" >>$FilePath\Errorlogs.log
        
    }
    Catch 
    {
        Write-Warning "Failed to rename $NEWName to $Name - logging error"
        Write-output "$(get-date) Failure: Attempting to rename $NEWName to $Name failed" >>$FilePath\Errorlogs.log
        $_ >>$FilePath\Errorlogs.log

    }
}
    Write-Output "Completed with Rename Step 1"
    Write-Output "$(get-date) Completed with Rename Step 1"  >>$FilePath\Errorlogs.log

#    Since the previous step just moves “NEWPrimarySmtpAddress” into an alternate smtp alias, we can now remove it. We’ll use the file (distributiongroups_modified.csv) to complete this task.
$RemoveNEWGrouptSMTP = Import-Csv $FilePath\distributiongroups_modified.csv

Write-Output "Starting Step 2 - Removing Existing Cloud Name Proxy Address"
Write-Output "$(get-date) Starting Step 2 - Removing Existing Cloud Name Proxy Address"  >>$FilePath\Errorlogs.log
Try
{
    Write-Verbose "Removing Existing Cloud Name Proxy Address" -Verbose
    $RemoveNEWGrouptSMTP | % {Set-DistributionGroup -Identity $_.PrimarySmtpAddress -EmailAddresses @{remove=$_.NEWPrimarySmtpAddress}} -ErrorAction Stop 
    Write-output "$(get-date) Success: Remove Proxy $_.NEWPrimarySmtpAddress from $_.PrimarySmtpAddress" >>$FilePath\Errorlogs.log
}
Catch
    {
        Write-Warning "Failed to Remove $_.NEWPrimarySmtpAddress - logging error"
        Write-output "$(get-date) Failure: Attempting to remove Proxy $_.NEWPrimarySmtpAddress failed from $_.PrimarySmtpAddress" >>$FilePath\Errorlogs.log
        $_ >>$FilePath\Errorlogs.log

    }
Write-Output " Finish Step 2"
Write-Output "$(get-date) Finished Step 2 - Removing Existing Cloud Name Proxy Address"  >>$FilePath\Errorlogs.log

#Last thing to do is add the SMTP, X500, and LegacyExchangeDN aliases in Exchange Online.
#add aliases

$ALIASES = Import-Csv $FilePath\distributiongroups-SMTPproxy_modified.csv
Write-Output "Start step 3 - Add SMTP Proxies"
Write-Output "$(get-date) Starting Step 3 - Add SMTP Proxies"  >>$FilePath\Errorlogs.log
Try
{
    Write-Verbose "Adding X500 and SMTP Proxy addresses" -Verbose
    $ALIASES | % {Set-DistributionGroup -Identity $_.PrimarySmtpAddress -EmailAddresses @{Add=$_.FULLADDRESS} -ErrorAction Stop } 
    Write-output "$(get-date) Success: Add Proxy $_.FULLADDRESS to $_.NEWPrimarySmtpAddress" >>$FilePath\Errorlogs.log
}
Catch
{
    Write-Warning "Failed to Add Proxy $_.FULLADDRESS to $_.NEWPrimarySmtpAddress - logging error"
    Write-output "$(get-date) Failure: Attempting to Add Proxy to $_.NEWPrimarySmtpAddress failed" >>$FilePath\Errorlogs.log
    $_ >>$FilePath\Errorlogs.log
}
Write-Output "Complete step 3 - Adding X500 and SMTP Proxy addresses"
Write-output "Complete step 3 - Adding X500 and SMTP Proxy addresses" >>$FilePath\Errorlogs.log
#add LegacyExchangeDN as x500
Import-Csv $FilePath\distributiongroups_modified.csv | ForEach-Object{
$smtp=$_.PrimarySmtpAddress
$LegacyExchangeDN="x500:"+$_.LegacyExchangeDN
$NEWPrimarySmtpAddress=$_.NEWPrimarySmtpAddress
Write-Output "Start step 4"
Write-output "Start step 4 - add LegacyExchangeDN as x500" >>$FilePath\Errorlogs.log
Try
{
    Write-Verbose "Adding Exchange LegacyDN Proxy address" -Verbose
    Set-DistributionGroup $smtp -EmailAddresses @{Add=$LegacyExchangeDN} -ErrorAction Stop 
    Write-output "$(get-date) Success: Add Exchange LegacyDN Proxy $LegacyExchangeDN to $NEWPrimarySmtpAddress" >>$FilePath\Errorlogs.log
}
Catch
{
    Write-Warning "Failed to Add Exchange LegacyDN Proxy to $_.NEWPrimarySmtpAddress - logging error"
    Write-output "$(get-date) Failure: Attempting to Add Exchange LegacyDN Proxy $LegacyExchangeDN to $NEWPrimarySmtpAddress failed" >>$FilePath\Errorlogs.log
    $_ >>$FilePath\Errorlogs.log
}
Write-Output "Complete step 4"
Write-output "Complete step 4 - add LegacyExchangeDN as x500" >>$FilePath\Errorlogs.log
}
