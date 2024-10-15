from ansible.module_utils.basic import AnsibleModule
from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import ssl

def main():

    module = AnsibleModule(
        argument_spec=dict(
            vcenter_hostname=dict(type='str', required=True),
            vcenter_username=dict(type='str', required=True),
            vcenter_password=dict(type='str', required=True, no_log=True),
            hostname=dict(type='str', required=True),  # Add host_name parameter
        ),
        supports_check_mode=True,  # Add this line to indicate that your module supports check mode (for using 'until', 'retries', and 'delay' with this module)
    )

    context = ssl.SSLContext(ssl.PROTOCOL_SSLv23)
    context.verify_mode = ssl.CERT_NONE

    si = SmartConnect(
        host=module.params['vcenter_hostname'],
        user=module.params['vcenter_username'],
        pwd=module.params['vcenter_password'],
        sslContext=context
    )

    # Get the host_name parameter
    host_name = module.params['hostname']

    # Get the content
    content = si.RetrieveContent()

    # Get the host
    host = None
    for entity in content.viewManager.CreateContainerView(content.rootFolder, [vim.HostSystem], True).view:
        if entity.name == host_name:
            host = entity
            break

    if host is None:
        module.fail_json(msg=f"Host {host_name} not found")

    # Get the cluster of the host
    cluster = host.parent

    # Get the cluster name
    cluster_name = cluster.name if isinstance(cluster, vim.ClusterComputeResource) else None
    
    # Get all the hosts in the cluster
    hosts = cluster.host

    # Set the RAM usage threshold
    ram_usage_threshold = 0.2

    # List to store hosts with high RAM usage
    ram_hosts_output = []

    # Check each host
    for host in hosts:
        # Get the host's name
        host_name = host.name

        # Get the host's RAM usage
        ram_usage = host.summary.quickStats.overallMemoryUsage / (host.summary.hardware.memorySize / (2 ** 20))

        # Add all hosts to the output list
        ram_hosts_output.append({'name': host_name, 'ram_percent': ram_usage})

    # Disconnect from the vCenter server
    Disconnect(si)
    
    # Prepare the result
    result = {
        'changed': False,
        'hosts': ram_hosts_output
    }

    # Return the result
    module.exit_json(**result)

if __name__ == '__main__':
    main()
