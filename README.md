scheduled-reboot
=========

A simple wrapper role for the [scheduled-reboot](https://github.com/kfiresmith/scheduled-reboot) tool.  

Scheduled-reboot provides a method to control scheduled rebooting of systems that can optionally:

 * Run package upgrades immediately prior to shutdown
 * Run pre-reboot scripts
 * Run recovery scripts in response to any pre-reboot task failures
 * Run post-reboot scripts
 * Log everything
 * Email when problems are encountered

Requirements
------------

- Ansible 2+
- [scheduled-reboot](https://github.com/kfiresmith/scheduled-reboot) package. You must host this yourself, it's not on a public PPA


Role Variables
--------------

**Note:** Some variables are mandatory and should be set in group_vars. Other vars will simply no-op if unset.

### Reboot schedule

Set the system reboot schedule time, in cron notation. Default: unset

`reboot_schedule: '50 5 * * *'`

### Mail-to addresses

A **space-separated** list of recipients to send email to when problems occur. Default: 'root'

`scheduled_reboot_mailto: root kodiak@work.org`

### Email when scheduled-reboot is disabled

Send a notification email at script exection time when scheduled-reboot is disabled. Mandatory. Default: unset

### Cron job state

Ensure `scheduled-reboot` cron job is present or absent. Default: absent

`scheduled_reboot_cronjob_state: absent`

### Scheduled-reboot package state

Package state for 'scheduled-reboot' package. [absent, latest, present] Default: present

`scheduled_reboot_package_state: present`

### Post-reboot oneshot service enabled

Should post-reboot systemd one-shot service be enabled? [true|false] Default: true
Controls the one-shot service that runs post-boot user scripts.

`scheduled_reboot_post_reboot_service_enabled: true`

### Package Upgrade 

Run package upgrades immediately prior to reboot [true|false] Default: false

`scheduled_reboot_upgrade_at_shutdown: false`

Example Playbook
----------------


    - hosts: servers
      roles:
         - scheduled-reboot
      vars:
        reboot_schedule: '50 5 * * *'
        scheduled_reboot_cronjob_state: present
        scheduled_reboot_email_when_disabled: true
        scheduled_reboot_mailto: root kodiak@work.org
        scheduled_reboot_package_state: present
        scheduled_reboot_post_reboot_service_enabled: true
        scheduled_reboot_scheduled_reboots_disabled: false
        scheduled_reboot_upgrade_at_shutdown: true

License
-------
MIT

Author Information
------------------
This role was created in 2021 by [Kodiak Firesmith][github], an ops guy at [Woods Hole Oceanographic Institution][whoi].
Aside from [GitHub][github], I'm most active on [LinkedIn][linkedin].

[whoi]: https://whoi.edu
[github]: https://github.com/kfiresmith
[linkedin]: https://www.linkedin.com/in/kodiak-firesmith-b6059434/
[logwatch]: https://sourceforge.net/projects/logwatch/
