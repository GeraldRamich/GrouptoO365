#This is On premise Exchange Powershell
$FilePath = "C:\DLExport\"
Write-output "$(get-date) Start running of Step1 - Creating Export of Groups" >>$FilePath\Errorlogs.log
$ErrorActionPreference = ‘Stop’

#Get all groups into temp variable

        Try
        {
            $groups = Get-DistributionGroup -ResultSize Unlimited -IgnoreDefaultScope -ErrorAction Stop 
            Write-output "$(get-date) Success: Get Groups succeeded" >>$FilePath\Errorlogs.log
        }
        Catch
        {
            Write-Warning "Failed to Get Groups - logging error"
            Write-output "$(get-date) Failure: Failed to Get Groups" >>$FilePath\Errorlogs.log
            $_ >>$FilePath\Errorlogs.log
        }


#Export 1) ON-PREM export all distribution groups and a few settings
      Try
        {
            $groups | Select-Object RecipientTypeDetails,Name,Alias,DisplayName,PrimarySmtpAddress,@{name="SMTPDomain";expression={$_.PrimarySmtpAddress.Domain}},MemberJoinRestriction,MemberDepartRestriction,RequireSenderAuthenticationEnabled,@{Name="ManagedBy";Expression={$_.ManagedBy -join “;”}},@{name=”AcceptMessagesOnlyFrom”;expression={$_.AcceptMessagesOnlyFrom -join “;”}},@{name=”AcceptMessagesOnlyFromDLMembers”;expression={$_.AcceptMessagesOnlyFromDLMembers -join “;”}},@{name=”AcceptMessagesOnlyFromSendersOrMembers”;expression={$_.AcceptMessagesOnlyFromSendersOrMembers -join “;”}},@{name=”ModeratedBy”;expression={$_.ModeratedBy -join “;”}},@{name=”BypassModerationFromSendersOrMembers”;expression={$_.BypassModerationFromSendersOrMembers -join “;”}},@{Name="GrantSendOnBehalfTo";Expression={$_.GrantSendOnBehalfTo -join “;”}},ModerationEnabled,SendModerationNotifications,LegacyExchangeDN,@{Name="EmailAddresses";Expression={$_.EmailAddresses -join “;”}},DistinguishedName  | Export-Csv $FilePath\distributiongroups.csv -NoTypeInformation -ErrorAction Stop 
            Write-output "$(get-date) Success: Export Groups to $FilePath\distributiongroups.csv succeeded" >>$FilePath\Errorlogs.log
        }
        Catch
        {
            Write-Warning "Failed to Get Groups - logging error"
            Write-output "$(get-date) Failure: Failed to Get Groups" >>$FilePath\Errorlogs.log
            $_ >>$FilePath\Errorlogs.log
        }
#Export 2) ON-PREM export distribution groups’ smtp aliases

      Try
        {
            $groups | Select-Object RecipientTypeDetails,PrimarySmtpAddress -ExpandProperty emailaddresses | select RecipientTypeDetails,PrimarySmtpAddress, @{name="TYPE";expression={$_}} | Export-Csv $FilePath\distributiongroups-SMTPproxy.csv -NoTypeInformation -ErrorAction Stop 
            Write-output "$(get-date) Success: Export Groups' SMTP Proxies to $FilePath\distributiongroups-SMTPproxy.csv succeeded" >>$FilePath\Errorlogs.log
        }
        Catch
        {
            Write-Warning "Failed to Export Groups' SMTP Proxies to $FilePath\distributiongroups-SMTPproxy.csv - logging error"
            Write-output "$(get-date) Failure: Failed to Export Groups' SMTP Proxies to $FilePath\distributiongroups-SMTPproxy.csv" >>$FilePath\Errorlogs.log
            $_ >>$FilePath\Errorlogs.log
        }
#Export 3) ON-PREM export all distribution groups and members (and member type)

      Try
        {
            $groups |% {$guid=$_.Guid;$GroupType=$_.RecipientTypeDetails;$Name=$_.Name;$SMTP=$_.PrimarySmtpAddress ;Get-DistributionGroupMember -Identity $guid.ToString() -ResultSize Unlimited | Select-Object @{name=”GroupType”;expression={$GroupType}},@{name=”Group”;expression={$name}},@{name=”GroupSMTP”;expression={$SMTP}},@{name="PrimarySMTPDomain";expression={$SMTP.Domain}},@{Label="Member";Expression={$_.Name}},@{Label="MemberSMTP";Expression={$_.PrimarySmtpAddress}},@{Label="MemberType";Expression={$_.RecipientTypeDetails}}} | Export-Csv $FilePath\distributiongroups-and-members.csv -NoTypeInformation -ErrorAction Stop 
            Write-output "$(get-date) Success: Export Groups' Members to $FilePath\distributiongroups-and-members.csv succeeded" >>$FilePath\Errorlogs.log
        }
        Catch
        {
            Write-Warning "Failed to Export Groups' Members to $FilePath\distributiongroups-and-members.csv  - logging error"
            Write-output "$(get-date) Failure: Failed to Export Groups' Members to $FilePath\distributiongroups-and-members.csv " >>$FilePath\Errorlogs.log
            $_ >>$FilePath\Errorlogs.log
        }
# You will need to do some clean up on the exported data
#See Cleanup.Doc