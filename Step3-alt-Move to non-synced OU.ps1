# Specify target OU. This is where users will be moved.
$TargetOU =  "OU=Test,DC=ramichonline,DC=com"
$FilePath = "C:\DLExport\"
# Specify CSV path. Import CSV file and assign it to a variable. 
$Imported_csv = Import-Csv -Path "$filepath\distributiongroups_modified.csv" 
Write-output "$(get-date) Start running of Step3-Moved to non-synced OU logging" >>$FilePath\Errorlogs.log
$ErrorActionPreference = ‘Stop’
$Imported_csv | ForEach-Object {
$distinguishedName=$_.distinguishedName
     Try
        {
            Write-Verbose "Moving on premise DG $distinguishedName to $TargetOU" -Verbose
            # Move user to target OU.
            Move-ADObject  -Identity $_.distinguishedName  -TargetPath $TargetOU -ErrorAction Stop 
            Write-output "$(get-date) Success: Move on premise DG $distinguishedName to $TargetOU" >>$FilePath\Errorlogs.log
        }
    Catch
        {
            Write-Warning "Failed to move on premise DG $distinguishedName to $TargetOU - logging error"
            Write-output "$(get-date) Failure: Attempting to move on premise DG $distinguishedName to $TargetOU failed" >>$FilePath\Errorlogs.log
            $_ >>$FilePath\Errorlogs.log
        }
   
 }