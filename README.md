# O365-Powershell---Set-Calendar-Permissions-via-AD-Security-Group

####   365 Powershell Script - Setting Calendar Permissions via Security Group for Office 365 Tenant
####   Script loops through all users in the security group of your choice and checks to see if each user has an email address of your choice as a permission on their calendar. If it already does, it skips that user. If it does not find it, it adds it in. If it finds it and the permission is different from the Permissions of your choosing, it sets it back to the Permissions of your choosing.
####   Typical scenario for doing this is you want all users in one security group (Fulltime Staff) to see each others LimitedDetails rather than the Default AvailabilityOnly, without letting the entire agency see their LimitedDetails in the case you have Contractors/Consultants.
####   All logs for changed permissions live in Path of your choosing
####   Anyone in the 'excluded' security group of your choosing is excluded from the search and change
####   Write outs are commented out and you can remove or uncomment to see expected results when testing.
####   In order to run this as a scheduled task you would need more code to connect to the Tenant as well as a saved key containing a Service Account password.
####   Script written by Chris Barcala 2019

![365script](https://user-images.githubusercontent.com/54015205/68553152-7d191500-03d3-11ea-99a7-fb1e2a1a3621.png)
