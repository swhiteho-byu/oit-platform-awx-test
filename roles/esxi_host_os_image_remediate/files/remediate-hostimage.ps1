param (
    [string]$vsphere_hostname,
    [string]$vsphere_username,
    [string]$vsphere_password,
    [string]$vsphere_cluster,
    [string]$hostname
)

#Main

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



$clusterId = (Get-view -ViewType ClusterComputeResource | Where-Object { $_.Name -match $vsphere_cluster }).MoRef -replace 'ClusterComputeResource-', ''
$vmHosts = Get-View -ViewType HostSystem | Where-Object { $_.Parent -match $clusterId }
$esxClusterSoftwareService = Get-CisService -Name com.vmware.esx.settings.clusters.software

foreach($vmHost in $vmHosts){
    if($vmhost.name -like $hostname){
        $vmhostview = $vmHost
        break
    }
}

Set-VMHost -VMHost $vmhostview.Name -State Maintenance -Confirm:$false

$hostId = $vmHostView.MoRef -replace 'HostSystem-', ''
$spec = $esxClusterSoftwareService.Help.'apply$task'.spec.Create()
$spec.accept_eula = $true
$spec.hosts = @($hostId)

#$esxClusterSoftwareService.'apply$task'($clusterId, $spec) 

Set-VMHost -VMHost $vmHostview.Name -State Connected -Confirm:$false
