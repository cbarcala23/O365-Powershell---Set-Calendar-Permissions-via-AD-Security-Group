﻿####   365 Powershell Script - Setting Calendar Permissions via Security Group for Office 365 Tenant
####   Script loops through all users in the security group of your choice and checks to see if each user has an email address of your choice as a permission on their calendar. If it already does, it skips that user. If it does not find it, it adds it in. If it finds it and the permission is different from the Permissions of your choosing, it sets it back to the Permissions of your choosing.
####   Typical scenario for doing this is you want all users in one security group (Fulltime Staff) to see each others LimitedDetails rather than the Default AvailabilityOnly, without letting the entire agency see their LimitedDetails in the case you have Contractors/Consultants.
####   All logs for changed permissions live in Path of your choosing
####   Anyone in the 'excluded' security group of your choosing is excluded from the search and change
####   Write outs are commented out and you can remove or uncomment to see expected results when testing.
####   In order to run this as a scheduled task you would need more code to connect to the Tenant as well as a saved key containing a Service Account password.
####   Script written by Chris Barcala 2019

###Email to the address of your choosing that the script is starting. The process takes X amount of time depending on the amount of users you have. I set this script up to run daily on a Server so the email notifications help know the time it takes from start to finish.
$emailTo = @('youremail@email.com')
Send-MailMessage -Body "Generated By:</b><br>This content goes in the body of the email" -BodyAsHtml -From anyemailaddress@email.com -To $emailTo -Subject "Calendar Script START" -SmtpServer relayemailaddress

###Store group members in variables below. Change these to the security groups of your choosing and the calperm to the permission of your choosing.
$groupmembers = get-distributiongroupmember -Identity securitygrouptoscan@email.com -ResultSize Unlimited
$exclusions = get-distributiongroupmember -Identity securitygrouptoexclude@email.com -ResultSize Unlimited
###The permission you want to give the user for the securitygrouptoscan@email.com above (LimitedDetails, AvailabilityOnly, FullDetails)
$calperm = "LimitedDetails"

####Setup Timestamp for filename
$CurrentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('MM-dd-yyyy_hh-mm-ss')

###ST Staff NESTING LOOP WITH FLAGS. Loop through all users in securitygrouptoscan, then loop within securitygrouptoexclude to match users and see if they are excluded. Set flag to 1 if yes. If the flag is set to 1 it skips any logic for that user and leaves it alone.
foreach ($user in $groupmembers) {

    ##Set flag to zero as default. it captures whether or not a user is in the excluded security group. if set to 1, no work is performed on that user
    $flag = 0

    ##Go through each user in the excluded group and compare to the user in the securitygrouptoscan above. if found, set flag to 1, otherwise exit with flag as zero
    foreach ($user_excluded in $exclusions) {

        if ($user_excluded -match $user) {

            $flag = 1
            ##Write-host "$user found and flag set to $flag. Nothing being done with this user" -ForegroundColor DarkYellow

        }
    }

    ##If flag was set to 1, that means the user is excluded and no work should be done. if flag is still 0, then the user is not excluded, set the permissions
    if ($flag -eq 1) {

        ##write-host "Set nothing for $user" -ForegroundColor Cyan

    }elseif ($flag -ne 1) {

        ##store access rights for given user in loop, to find if the user has the calendar permissions already or not
        $accessrights = Get-Mailboxfolderpermission -identity ${user}:\calendar -User securitygrouptoscan@email.com
        $permission = $accessrights.AccessRights
        ##write out for testing
        ##Write-Host "Accessrights for $user are $permission" -ForegroundColor Yellow

        ##if the access rights variable is null, add the calendar permissions
        if ($permission -eq $null) {

            Add-Mailboxfolderpermission -Identity ${user}:\calendar -User securitygrouptoscan@email.com -AccessRights $calperm
            ##Write-Host "Permission Added for $user" -ForegroundColor Green
            $user | Export-CSV C:\pathyouchoose\365PermissionsADDED_BACK_staff_$CurrentDate.csv -Append -NoTypeInformation

        ##else if the access right was changed from LimitedDetails to AvailabilityOnly, set again
        }elseif ($permission -eq 'AvailabilityOnly') {

            ##Write-Host "$user changed access rights to $permission, lets set it to LimitedDetails again" -ForegroundColor Green
            Set-Mailboxfolderpermission -Identity ${user}:\calendar -User securitygrouptoscan@email.com -AccessRights $calperm
            $user | Export-CSV D:\pathyouchoose\365PermissionsCHANGED_staff_$CurrentDate.csv -Append -NoTypeInformation

        ##else it means the user either has limiteddetails already or more permissions, do not perform any modifications
        }else {

        ##Write-Host "$user either has LimitedDetails or FullDetails so do not set again" -ForegroundColor Green

        }
    }
}

###Email notification that script has finished
$emailTo = @('youremail@email.com')
Send-MailMessage -Body "Generated By:</b><br>This content goes in the body of the email" -BodyAsHtml -From anyemailaddress@email.com -To $emailTo -Subject "Calendar Script END" -SmtpServer relayemailaddress

###Close the session to 365
Remove-PSSession $session