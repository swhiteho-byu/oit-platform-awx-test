param (
    [string]$vsphere_hostname,
    [string]$vsphere_username,
    [string]$vsphere_password,
    [string]$inventory_hostname
)

# Don't ask for confirmations
Set-Variable -Name ConfirmPreference -Value None

# Connect to the vSphere server
Connect-VIServer -Server "$vsphere_hostname" -User "$vsphere_username" -Password "$vsphere_password"
write-host $vsphere_hostname
write-host $vsphere_username
write-host $vsphere_password
write-host $inventory_hostname


# Get the host by inventory name
$esxi_host = Get-VMHost -Name "$inventory_hostname"
if (-not $esxi_host) {
    Write-Error "ESXi host '$inventory_hostname' not found."
    exit 1
}

# Log the retrieved host details
Write-Output "Retrieved ESXi host: $($esxi_host.Name)"


# Apply the new host profile
try {
    Invoke-VMHostProfile -Entity $esxi_host
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