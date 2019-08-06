#Last thing to do is add the SMTP, X500, and LegacyExchangeDN aliases in Exchange Online.
#add aliases
$FilePath = "C:\DLExport\"
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