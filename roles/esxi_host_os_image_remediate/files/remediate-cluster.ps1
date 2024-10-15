param (
    [string]$vsphere_hostname,
    [string]$vsphere_username,
    [string]$vsphere_password,
    [string]$vsphere_cluster
)

# Don't ask for confirmations
Set-Variable -Name ConfirmPreference -Value None

<#
$filePath = "working_output.txt"
out-file -FilePath $filePath -InputObject $vsphere_hostname -Append
out-file -FilePath $filePath -InputObject $vsphere_username -Append
#out-file -FilePath $filePath -InputObject $vsphere_password -Append
out-file -FilePath $filePath -InputObject $vsphere_cluster -Append
out-file -FilePath $filePath -InputObject $new_host_profile -Append
#>

# Connect to the vSphere server
$connection = Connect-VIServer -Server "$vsphere_hostname" -User "$vsphere_username" -Password "$vsphere_password" 
$connection2 = Connect-CIServer -Server "$vsphere_hostname" -User "$vsphere_username" -Password "$vsphere_password" 

#Remediate hosts in maintenance mode
Set-Cluster -Cluster $vsphere_cluster -Remediate -AcceptEULA -confirm:$False
#Write-Output "Don't remediate yet... just testing"
#Remediate host profile
