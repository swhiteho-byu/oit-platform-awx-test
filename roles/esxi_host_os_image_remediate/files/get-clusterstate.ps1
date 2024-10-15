param (
    [string]$vsphere_hostname,
    [string]$vsphere_username,
    [string]$vsphere_password,
    [string]$vsphere_cluster,
    [string]$inventory_hostname,
    [string]$new_host_profile
)

# Don't ask for confirmations
Set-Variable -Name ConfirmPreference -Value None

$filePath = "working_output.txt"
out-file -FilePath $filePath -InputObject $vsphere_hostname -Append
out-file -FilePath $filePath -InputObject $vsphere_username -Append
#out-file -FilePath $filePath -InputObject $vsphere_password -Append
out-file -FilePath $filePath -InputObject $vsphere_cluster -Append
out-file -FilePath $filePath -InputObject $inventory_hostname -Append
out-file -FilePath $filePath -InputObject $new_host_profile -Append



# Connect to the vSphere server
$connection = Connect-VIServer -Server "$vsphere_hostname" -User "$vsphere_username" -Password "$vsphere_password" 

#Set-Variable -Name "clusterstate" -Value (Test-LcmClusterCompliance -Cluster $vsphere_cluster)
$clusterstate = Test-LcmClusterCompliance -Cluster $vsphere_cluster


$clusterStateData = [string]@()

if ($clusterstate.status -like "Compliant"){
    $clusterStateData += [string]$clusterstate.status
    return $clusterStateData
}

if ($clusterstate.impact -like "NoImpact"){
    $clusterStateData += [string]$clusterstate.Impact
    return $clusterStateData
}

#$clusterstate.Impact #NoImpact = maintencemode not required...
#$clusterstate.NonCompliantHosts[0].VMHost
#$clusterstate.NonCompliantHosts[0].VMHost.Impact #Noimpact

#$clusterstate.impact #"RebootRequired" 
#$clusterstate.Noncomplianthosts.vmhost.name
#$clusterstate.Noncomplianthosts.impact "RebootRequired" 

if ($clusterstate.impact -like "RebootRequired"){
    $clusterStateData += [String]$clusterstate.Impact
        
    foreach ($vmhost in $clusterState.NonCompliantHosts){
        #write-host "Non compliant hosts: "
        #set-variable -Name "vmhostname" -Value($vmhost.vmhost.name.Split(".")[0])
        #Don't remove fqdn subdomain
        if ($vmhost.impact -like "RebootRequired"){
                set-variable -Name "vmhostname" -Value($vmhost.VMHost.name)
                $clusterStateData += "`n" 
                $clusterStateData += $vmhostname
                
        }
    }
}


return $clusterStateData
<#
# Get the host by inventory name
$esxi_host = Get-VMHost -Name "$inventory_hostname"
if (-not $esxi_host) {
    Write-Error "ESXi host '$inventory_hostname' not found."
    exit 1
}

# Log the retrieved host details
Write-Output "Retrieved ESXi host: $($esxi_host.Name)"

# Get and log the host profile
$hostProfile = Get-VMHostProfile -Name "$new_host_profile"
if (-not $hostProfile) {
    Write-Error "Host profile '$new_host_profile' not found."
    exit 1
}

Write-Output "Retrieved host profile: $($hostProfile.Name)"

# Apply the new host profile
try {
    Apply-VMHostProfile -Entity $esxi_host -Profile $hostProfile
    Write-Output "Applied host profile successfully."
} catch {
    Write-Error "Failed to apply host profile: $_"
    exit 1
}

# Disconnect from the vSphere server
Disconnect-VIServer -Server "$vsphere_hostname" -Confirm:$false





# param (
#     [string]$vsphere_hostname,
#     [string]$vsphere_username,
#     [string]$vsphere_password,
#     [string]$inventory_hostname,
#     [string]$new_host_profile
# )
# # Don't ask for confirmations
# Set-Variable -Name ConfirmPreference -Value None

# # Connect to the vSphere server
# Connect-VIServer -Server $vsphere_hostname -User $vsphere_username -Password $vsphere_password

# # Get the host by inventory name
# $esxi_host = Get-VMHost -Name $inventory_hostname

# # Apply the new host profile
# $hostProfile = Get-VMHostProfile -Name $new_host_profile
# Apply-VMHostProfile -Entity $esxi_host -Profile $hostProfile

# # Disconnect from the vSphere server
# Disconnect-VIServer -Server $vsphere_hostname
#>