#Clean up of the 3 exported files must be done prior, and files need to be renamed (See CleanUp.Docx for detailed instructions)

#distributiongroups_modified.csv
#The file requires you to Create "NEW" Values. Here are a list of values NEWName, NEWAlias, NEWDisplayName, NEWPrimarySmtpAddress
# Requires User Path, it must be cleaned up for “ManagedBy“, “AcceptMessagesOnlyFrom”, “AcceptMessagesOnlyFromDLMembers”, and “AcceptMessagesOnlyFromSendersOrMembers” columns (e.g.: contoso.local/User Accounts/USA/FTEmployees/Ryan Jackson; contoso.local/User Accounts/JPN/FTEmployees/Dave Rowe —should become–> Ryan Jackson;Dave Rowe)
#Save the csv file as distributiongroups_modified.csv

#distributiongroups-SMTPproxy_modified.csv
#Clean file from export 2 (SMTP Proxy/ALIAS file, distributiongroups-SMTPproxy.csv)
#Let’s remove everything except alternate smtp and x500, this includes removing Primary SMTP address. We’ll need to add a few columns and use macros to help us find what we’re looking for

#distributiongroups-and-members_modified.csv
##The file requires you to Create "NEW" Values. Here are a list of values NEWGroup,NEWGroupSMTP

#Note: if you excluded mail-enabled security groups from distributiongroups_modified.csv, you might consider also removing from this file too. 
#Otherwise you’ll see errors when trying to add members to groups that don’t exist.  Filter columns, and in “GroupType” select rows with “MailUniversalSecurityGroup” and hit delete key.


#This is to be done with Exchange Online PowerShell
#Create Place Holder Group
$FilePath = "C:\DLExport\"
Write-output "$(get-date) Start running of Step2- Creating TEMP Groups with NEW names" >>$FilePath\Errorlogs.log


Import-Csv $FilePath\distributiongroups_modified.csv | ForEach-Object{
    $ErrorActionPreference = Stop
    $RecipientTypeDetails=$_.RecipientTypeDetails
    $Name = $($_.NEWName -replace '\s','')[0..63] -join "" # remove spaces first, then truncate to first 64 characters
    $Alias = $($_.NEWAlias -replace '\s','')[0..63] -join "" # remove spaces first, then truncate to first 64 characters
    $DisplayName=$_.NEWDisplayName
    $smtp=$_.NEWPrimarySmtpAddress
    $RequireSenderAuthenticationEnabled=[System.Convert]::ToBoolean($_.RequireSenderAuthenticationEnabled)
    $join=$_.MemberJoinRestriction
    $depart=$_.MemberDepartRestriction
    $ManagedBy=$_.ManagedBy -split ';'
    $AcceptMessagesOnlyFrom=$_.AcceptMessagesOnlyFrom -split ';'
    $AcceptMessagesOnlyFromDLMembers=$_.AcceptMessagesOnlyFromDLMembers -split ';'
    $AcceptMessagesOnlyFromSendersOrMembers=$_.AcceptMessagesOnlyFromSendersOrMembers -split ';'
    
    Write-Output ""
    Write-Output "working on Group: $Name"
    Write-Output ""
    
    if ($RecipientTypeDetails -eq "MailUniversalSecurityGroup")
        {
        if ($ManagedBy)
            {
            Try
                {
                    
                    New-DistributionGroup -Type security -Name $Name -Alias $Alias -DisplayName $DisplayName -PrimarySmtpAddress $smtp -RequireSenderAuthenticationEnabled $RequireSenderAuthenticationEnabled -MemberJoinRestriction $join -MemberDepartRestriction $depart -ManagedBy $ManagedBy -ErrorAction Stop 
                    #Start-Sleep -s 10
                    #Set-DistributionGroup -Identity $Name -HiddenFromAddressListsEnabled $true
                    Write-Output "Manage by True - SG"
                    Write-output "$(get-date) Success: Created USG $Name succeeded includes ManagedBy $ManagedBy" >>$FilePath\Errorlogs.log
                }
            Catch
                {
                    Write-Warning "Failed Created Group $Name - logging error"
                    Write-output "$(get-date) Failure: Failed to Created USG $Name failed inlcuded ManagedBy $ManagedBy" >>$FilePath\Errorlogs.log
                    $_ >>$FilePath\Errorlogs.log
                }
            }
        Else
            {
            Try
                {
                    New-DistributionGroup -Type security -Name $Name -Alias $Alias -DisplayName $DisplayName -PrimarySmtpAddress $smtp -RequireSenderAuthenticationEnabled $RequireSenderAuthenticationEnabled -MemberJoinRestriction $join -MemberDepartRestriction $depart -ErrorAction Stop 
                    #Start-Sleep -s 10
                    #Set-DistributionGroup -Identity $Name -HiddenFromAddressListsEnabled $true
                    Write-Output "Manage by False -SG"
                    Write-output "$(get-date) Success: Created USG $Name succeeded no ManagedBy" >>$FilePath\Errorlogs.log
                }
            Catch
                {
                        Write-Warning "Failed Created Group $Name - logging error"
                        Write-output "$(get-date) Failure: Failed Created USG $Name failed no ManagedBy" >>$FilePath\Errorlogs.log
                        $_ >>$FilePath\Errorlogs.log
                    }
            }
        }

    if ($RecipientTypeDetails -eq "MailUniversalDistributionGroup")
        {
        if ($ManagedBy)
            {
            Try
                {
                    New-DistributionGroup -Name $Name -Alias $Alias -DisplayName $DisplayName -PrimarySmtpAddress $smtp -RequireSenderAuthenticationEnabled $RequireSenderAuthenticationEnabled -MemberJoinRestriction $join -MemberDepartRestriction $depart -ManagedBy $ManagedBy -ErrorAction Stop 
                    #Start-Sleep -s 10
                    #Set-DistributionGroup -Identity $Name -HiddenFromAddressListsEnabled $true
                    Write-Output "Manage by True -UDG"
                    Write-output "$(get-date) Success: Created UDG $Name succeeded includes ManagedBy $ManagedBy" >>$FilePath\Errorlogs.log
                }
            Catch
                {
                    Write-Warning "Failed Created Group $Name - logging error"
                    Write-output "$(get-date) Failure: Failed Created UDG $Name failed includes ManagedBy $ManagedBy" >>$FilePath\Errorlogs.log
                    $_ >>$FilePath\Errorlogs.log
                }

            }
        Else
            {
            Try
                {
                    New-DistributionGroup -Name $Name -Alias $Alias -DisplayName $DisplayName -PrimarySmtpAddress $smtp -RequireSenderAuthenticationEnabled $RequireSenderAuthenticationEnabled -MemberJoinRestriction $join -MemberDepartRestriction $depart -ErrorAction Stop 
                    #Start-Sleep -s 10
                    #Set-DistributionGroup -Identity $Name -HiddenFromAddressListsEnabled $true
                    Write-Output "Manage by False -UDG"
                    Write-output "$(get-date) Success: Created UDG $Name succeeded no ManagedBy" >>$FilePath\Errorlogs.log
                }
            Catch
                {
                    Write-Warning "Failed Created Group $Name - logging error"
                    Write-output "$(get-date) Failure: Failed Created UDG $Name failed no ManagedBy" >>$FilePath\Errorlogs.log
                    $_ >>$FilePath\Errorlogs.log
                }

            }
        }

    if ($RecipientTypeDetails -eq "RoomList")
        {
        if ($ManagedBy)
            {
            Try
                {
                    New-DistributionGroup -RoomList -Name $Name -Alias $Alias -DisplayName $DisplayName -PrimarySmtpAddress $smtp -RequireSenderAuthenticationEnabled $RequireSenderAuthenticationEnabled -MemberJoinRestriction $join -MemberDepartRestriction $depart -ManagedBy $ManagedBy -ErrorAction Stop 
                    #Start-Sleep -s 10
                    #Set-DistributionGroup -Identity $Name -HiddenFromAddressListsEnabled $true
                    Write-Output "Manage by True -RL"
                    Write-output "$(get-date) Success: Created Room List $Name succeeded includes ManagedBy $ManagedBy" >>$FilePath\Errorlogs.log
                }
            Catch
                {
                    Write-Warning "Failed Created Group $Name - logging error"
                    Write-output "$(get-date) Failure: Failed Created Room List $Name failed includes ManagedBy $ManagedBy" >>$FilePath\Errorlogs.log
                    $_ >>$FilePath\Errorlogs.log
                }

            }
        Else
            {
            Try
                {
                    New-DistributionGroup -RoomList -Name $Name -Alias $Alias -DisplayName $DisplayName -PrimarySmtpAddress $smtp -RequireSenderAuthenticationEnabled $RequireSenderAuthenticationEnabled -MemberJoinRestriction $join -MemberDepartRestriction $depart -ErrorAction Stop 
                    #Start-Sleep -s 10
                    #Set-DistributionGroup -Identity $Name -HiddenFromAddressListsEnabled $true
                    Write-Output "Manage by False -RL"
                    Write-output "$(get-date) Success: Created Room List $Name succeeded no ManagedBy" >>$FilePath\Errorlogs.log
                }
            Catch
                {
                    Write-Warning "Failed Created Group $Name - logging error"
                    Write-output "$(get-date) Failure: Failed Created Room List $Name failed includes no ManagedBy" >>$FilePath\Errorlogs.log
                    $_ >>$FilePath\Errorlogs.log
                }

            }
        }
    

    if ($AcceptMessagesOnlyFrom) 
    {
        Try
        {
            Set-DistributionGroup -Identity $Name -AcceptMessagesOnlyFrom $AcceptMessagesOnlyFrom -ErrorAction Stop 
            Write-output "$(get-date) Success: Adding AcceptMessagesOnlyFrom $AcceptMessagesOnlyFrom to $Name succeeded" >>$FilePath\Errorlogs.log
        }
        Catch
        {
            Write-Warning "Failed Adding AcceptMessagesOnlyFrom $AcceptMessagesOnlyFrom to $Name - logging error"
            Write-output "$(get-date) Failure: Adding AcceptMessagesOnlyFrom $AcceptMessagesOnlyFrom to $Name failed" >>$FilePath\Errorlogs.log
            $_ >>$FilePath\Errorlogs.log
        }
    }
    if ($AcceptMessagesOnlyFromDLMembers)
     {
        Try
        {
            Set-DistributionGroup -Identity $Name -AcceptMessagesOnlyFromDLMembers $AcceptMessagesOnlyFromDLMembers -ErrorAction Stop 
            Write-output "$(get-date) Success: Adding AcceptMessagesOnlyFrom $AcceptMessagesOnlyFromDLMembers to $Name succeeded" >>$FilePath\Errorlogs.log
        }
        Catch
        {
            Write-Warning "Failed Adding AcceptMessagesOnlyFrom $AcceptMessagesOnlyFromDLMembers to $Name - logging error"
            Write-output "$(get-date) Failure: Adding AcceptMessagesOnlyFrom $AcceptMessagesOnlyFromDLMembers to $Name failed" >>$FilePath\Errorlogs.log
            $_ >>$FilePath\Errorlogs.log
        }
     
     }
    if ($AcceptMessagesOnlyFromSendersOrMembers)
     {
        Try
        {
            Set-DistributionGroup -Identity $Name -AcceptMessagesOnlyFromSendersOrMembers $AcceptMessagesOnlyFromSendersOrMembers -ErrorAction Stop 
            Write-output "$(get-date) Success: Adding AcceptMessagesOnlyFrom $AcceptMessagesOnlyFromSendersOrMembers to $Name succeeded" >>$FilePath\Errorlogs.log
        }
        Catch
        {
            Write-Warning "Failed Adding AcceptMessagesOnlyFrom $AcceptMessagesOnlyFromSendersOrMembers to $Name - logging error"
            Write-output "$(get-date) Failure: Adding AcceptMessagesOnlyFrom $AcceptMessagesOnlyFromSendersOrMembers to $Name failed" >>$FilePath\Errorlogs.log
            $_ >>$FilePath\Errorlogs.log
        }
     
     }
  }

  # Placeing the hidden loop seperate to avoid the Start-Sleep delay for 10 seconds. 
  # Up side is the script is WAY faster
  # Down Side the DL created are "not hidden" right away. This may cause the DL to be exposed for a period of time.
  Import-Csv $FilePath\distributiongroups_modified.csv | ForEach-Object{
    $Name = $($_.NEWName -replace '\s','')[0..63] -join "" # remove spaces first, then truncate to first 64 characters
    Write-Output ""
    Write-Output "Hiding Group: $Name"
    Write-Output ""
    Try
        {
            Set-DistributionGroup -Identity $Name -HiddenFromAddressListsEnabled $true -ErrorAction Stop 
            Write-output "$(get-date) Success: Hide $Name succeeded" >>$FilePath\Errorlogs.log
        }
    Catch
        {
            Write-Warning "Failed to Hide $Name - logging error"
            Write-output "$(get-date) Failure: Attempting to Hide $Name failed" >>$FilePath\Errorlogs.log
            $_ >>$FilePath\Errorlogs.log
        }
  }



#Update memebership of place holder.
Import-Csv $FilePath\distributiongroups-and-members_modified.csv | ForEach-Object{
$RecipientTypeDetails=$_.GroupType
$GroupSMTP=$_.NEWGroupSMTP
$MemberSMTP=$_.NEWMemberSMTP

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
                    Write-Warning "Failed to Add $MemberSMTP to USG $GroupSMTP- logging error"
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
                    Write-Warning "Failed to Add $MemberSMTP to UDG $GroupSMTP - logging error"
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
                    Write-Warning "Failed to Add $MemberSMTP to Room List $GroupSMTP - logging error"
                    Write-output "$(get-date) Failure: Attempting to Add $MemberSMTP to Room List $GroupSMTP failed" >>$FilePath\Errorlogs.log
                    $_ >>$FilePath\Errorlogs.log
                }
        }
}