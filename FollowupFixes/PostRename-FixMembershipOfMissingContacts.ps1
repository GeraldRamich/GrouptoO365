#Update memebership of group. This is modied to add members missing after the Groupos have been renamed.
#Expect a lot of "Already Exist Failures"
$FilePath = "C:\DLExport\"
Import-Csv $FilePath\distributiongroups-and-members_modified.csv | ForEach-Object{
$RecipientTypeDetails=$_.GroupType
$GroupSMTP=$_.GroupSMTP
$MemberSMTP=$_.MemberSMTP

    if ($RecipientTypeDetails -eq "MailUniversalSecurityGroup")
        {
            Try
                {
                    Write-Output "Adding $MemberSMTP to USG $GroupSMTP"
                    Add-DistributionGroupMember -Identity $GroupSMTP -Member $MemberSMTP -BypassSecurityGroupManagerCheck -ErrorAction Stop 
                    Write-Verbose "No Errors, added $MemberSMTP to USG $GroupSMTP"
                    Write-output "$(get-date) Success: No Errors, added $MemberSMTP to USG $GroupSMTP" >>$FilePath\Errorlogs.log
                }
            Catch
                {
                    Write-Warning "Failed to Add $MemberSMTP to USG $GroupSMTP - logging error. Expect a lot of Already Exist Failures"
                    Write-output "$(get-date) Failure: Attempting to $MemberSMTP to USG $GroupSMTP failed" >>$FilePath\Errorlogs.log
                    $_ >>$FilePath\Errorlogs.log
                }
        }
        
    
    if ($RecipientTypeDetails -eq "MailUniversalDistributionGroup")
        {

            Try
                {
                    Write-Output "Adding $MemberSMTP to UDG $GroupSMTP"
                    Add-DistributionGroupMember -Identity $GroupSMTP -Member $MemberSMTP -ErrorAction Stop 
                    Write-Verbose "No Errors, added $MemberSMTP to UDG $GroupSMTP"
                    Write-output "$(get-date) Success: No Errors, added $MemberSMTP to UDG $GroupSMTP" >>$FilePath\Errorlogs.log
                }
            Catch
                {
                    Write-Warning "Failed to Add $MemberSMTP to UDG $GroupSMTP - logging error. Expect a lot of Already Exist Failures"
                    Write-output "$(get-date) Failure: Attempting to Add $MemberSMTP to UDG $GroupSMTP failed" >>$FilePath\Errorlogs.log
                    $_ >>$FilePath\Errorlogs.log
                } 
        }

    if ($RecipientTypeDetails -eq "RoomList")
        {
            Write-Output "Adding $MemberSMTP to Room List $GroupSMTP"
            Add-DistributionGroupMember -Identity $GroupSMTP -Member $MemberSMTP -ErrorAction Stop 
                                   Try
                {
                    Write-Output "Adding $MemberSMTP to Room List $GroupSMTP"
                    Add-DistributionGroupMember -Identity $GroupSMTP -Member $MemberSMTP -ErrorAction Stop 
                    Write-Verbose "No Errors, added $MemberSMTP to Room List $GroupSMTP"
                    Write-output "$(get-date) Success: No Errors, added $MemberSMTP to Room List $GroupSMTP" >>$FilePath\Errorlogs.log
                }
            Catch
                {
                    Write-Warning "Failed to Add $MemberSMTP to Room List $GroupSMTP - logging error. Expect a lot of Already Exist Failures"
                    Write-output "$(get-date) Failure: Attempting to Add $MemberSMTP to Room List $GroupSMTP failed" >>$FilePath\Errorlogs.log
                    $_ >>$FilePath\Errorlogs.log
                }
        }
}