from ansible.module_utils.basic import AnsibleModule
from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import ssl
from time import sleep

# Confirms the alarm state, changing it if neessesary, 
# then returns whether or not it had to change 
def enable_disable_alarm(si, module):
    changed = False
    content = si.RetrieveContent()
    alarmMgr = content.alarmManager

    for entity in content.rootFolder.childEntity:
        if isinstance(entity, vim.Datacenter):
            for cluster in entity.hostFolder.childEntity:
                for host in cluster.host:
                    if host.name == module.params['hostname']:
                        if alarmMgr.AreAlarmActionsEnabled(host):
                            if module.params['state'] == 'disabled':
                                alarmMgr.EnableAlarmActions(host, False)
                                changed = True
                        else:
                            if module.params['state'] == 'enabled':
                                alarmMgr.EnableAlarmActions(host, True)
                                changed = True
    return changed

# Confirm the state changed how it needed to
def confirm_alarm_state(si, module):
    content = si.RetrieveContent()
    alarmMgr = content.alarmManager
    correct_state = False

    for entity in content.rootFolder.childEntity:
        if isinstance(entity, vim.Datacenter):
            for cluster in entity.hostFolder.childEntity:
                for host in cluster.host:
                    if host.name == module.params['hostname']:
                        if alarmMgr.AreAlarmActionsEnabled(host):
                            if module.params['state'] == 'enabled':
                                correct_state = True
                        else:
                            if module.params['state'] == 'disabled':
                                correct_state = True
    return correct_state

def main():
    timeout_counter = 10
  
    module = AnsibleModule(
        argument_spec=dict(
            vcenter_hostname=dict(type='str', required=True),
            vcenter_username=dict(type='str', required=True),
            vcenter_password=dict(type='str', required=True, no_log=True),
            hostname=dict(type='str', required=True),  # Add host_name parameter
            state=dict(type='str', choices=['enabled', 'disabled'], required=True),
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

    changed = enable_disable_alarm(si, module)
    
    # Check to make sure the state actualy changed
    for i in range(timeout_counter):
        if confirm_alarm_state(si, module): break
        if i >= timeout_counter and confirm_alarm_state(si, module): 
            module.fail_json(debug=debuglist, msg=f"Host {host_name} alarm change could not be completed, then timed out after {timeout_counter} seconds")
        sleep(1)
    
    # Disconnect from the vCenter server
    Disconnect(si)

    # Return the result
    module.exit_json(changed=changed)

if __name__ == '__main__':
    main()
