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
- [scheduled-reboot](https://github.com/kfiresmith/scheduled-reboot) package. You must host this yourself, it's not on a public PPA or Yum/DNF repo.

Supported platforms
--------------------

- Ubuntu: xenial, bionic, focal, jammy, noble, resolute (installs the `.deb` via `apt`)
- Enterprise Linux (RHEL, Rocky Linux, etc.): 8, 9, 10 (installs the `.rpm` via `dnf`)

The role dispatches on `ansible_facts['os_family']` (`Debian` or `RedHat`), so any Debian- or RHEL-family distribution with the `scheduled-reboot` package available should work, not just the specific versions listed above.


Role Variables
--------------

**Note:** Some variables are mandatory and should be set in group_vars. Other vars will simply no-op if unset.

### Reboot schedule

Set the system reboot schedule time, in cron notation. Default: unset

```yaml
reboot_schedule: '50 5 * * *'
```

### Reboot schedule (systemd timer)

The role prefers a systemd timer over cron. Set `reboot_schedule_timer` to a
[systemd `OnCalendar=`](https://www.freedesktop.org/software/systemd/man/systemd.time.html#Calendar%20Events)
expression to have the role install and enable a `scheduled-reboot.timer` /
`scheduled-reboot.service` unit pair instead of a cron job. Default: unset

```yaml
reboot_schedule_timer: '*-*-* 05:50:00'
```

Behavior:

- If `reboot_schedule_timer` is set to a non-empty value, the role installs and
  enables the systemd timer/service units and removes any existing
  `scheduled-reboot` cron job — the timer always takes precedence over cron.
- If `reboot_schedule_timer` is unset (or empty), the role falls back to cron.
  If a systemd timer was previously installed by this role, it is stopped,
  disabled, and removed, and (if `reboot_schedule` and
  `scheduled_reboot_cronjob_state: present` are set) the cron job is
  (re)installed in its place.
- This makes it safe to transition a host from cron to the systemd timer (set
  `reboot_schedule_timer`) or back from the timer to cron (unset
  `reboot_schedule_timer`, keep `reboot_schedule` populated) just by changing
  variables and re-running the role.

### Mail-to addresses

A **space-separated** list of recipients to send email to when problems occur. Default: 'root'

```yaml
scheduled_reboot_mailto: root kodiak@work.org
```

### Email when scheduled-reboot is disabled

Send a notification email at script exection time when scheduled-reboot is disabled. Mandatory. Default: unset
```yaml
scheduled_reboot_email_when_disabled: true
```

### Cron job state

Ensure `scheduled-reboot` cron job is present or absent. Default: absent

```yaml
scheduled_reboot_cronjob_state: absent
```

### Scheduled-reboot package state

Package state for 'scheduled-reboot' package. [absent, latest, present] Default: present

```yaml
scheduled_reboot_package_state: present
```

### Post-reboot oneshot service enabled

Should post-reboot systemd one-shot service be enabled? [true|false] Default: true
Controls the one-shot service that runs post-boot user scripts.

```yaml
scheduled_reboot_post_reboot_service_enabled: true
```

### Package Upgrade 

Run package upgrades immediately prior to reboot [true|false] Default: false

```yaml
scheduled_reboot_upgrade_at_shutdown: false
```

Example Playbook
----------------


    - hosts: servers
      roles:
         - scheduled-reboot
      vars:
        reboot_schedule: '50 5 * * *'
        reboot_schedule_timer: '*-*-* 05:50:00'
        scheduled_reboot_cronjob_state: present
        scheduled_reboot_email_when_disabled: true
        scheduled_reboot_mailto: root kodiak@work.org
        scheduled_reboot_package_state: present
        scheduled_reboot_post_reboot_service_enabled: true
        scheduled_reboot_scheduled_reboots_disabled: false
        scheduled_reboot_upgrade_at_shutdown: true

Testing
-------

This role has a [Molecule](https://ansible.readthedocs.io/projects/molecule/) test
suite using the Docker driver, exercising real systemd inside `geerlingguy/docker-*-ansible`
containers across Ubuntu 20.04, 22.04, 24.04, 26.04 and Rocky Linux 8, 9, 10.

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install molecule molecule-plugins[docker] ansible-core
ansible-galaxy collection install community.docker ansible.posix

molecule test -s default         # systemd timer scheduling path
molecule test -s cron-fallback   # cron path + cron<->timer transitions
```

Since the real `scheduled-reboot` package isn't hosted anywhere molecule can
reach, `molecule/resources/tasks/stub-package.yml` builds and installs a
minimal stand-in `.deb`/`.rpm` (same package name, a `post-reboot.service`
unit, and an `/etc/default/scheduled-reboot` file) so the role's own install
task is exercised as a real no-op, not skipped.

The docker containers need `privileged: true`, `security_opts: [apparmor=unconfined, seccomp=unconfined]`,
and a read-write `/sys/fs/cgroup` bind mount for systemd to boot as PID 1 --
without these, the containers exit immediately.

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
