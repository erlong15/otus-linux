import os
import pytest
from testinfra.utils.ansible_runner import AnsibleRunner

testinfra_hosts = ["ansible://clients"]


def test_log(host):
    logfile = host.file("/var/log/borg-backup.log")
    assert logfile.contains("Backup succeeded")
    assert logfile.user == "root"
    assert logfile.group == "root"


# to do read inventory variable : export BORG_PASSPHRASE="{{ borgbackup_passphrase }}"
def test_passphrase(host):
    pfile = host.file("/root/.borg.passphrase")
    assert pfile.contains("BORG_PASSPHRASE=")
    assert pfile.user == "root"
    assert pfile.group == "root"


@pytest.mark.parametrize('server', AnsibleRunner(os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('borgbackup_servers'))
def test_sshconfig(host, server):
    sshconf = host.file("/root/.ssh/config")
    assert sshconf.contains(" ANSIBLE MANAGED BLOCK %s " % server)
    assert sshconf.contains("Host %s" % server)
    assert sshconf.user == "root"
    assert sshconf.group == "root"


def test_scriptfile(host):
    script = host.file("/usr/local/bin/borg-backup")
    assert script.user == "root"
    assert script.group == "root"
    assert script.mode == 0o744


@pytest.mark.parametrize('server', AnsibleRunner(os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('borgbackup_servers'))
def test_list_backups(host, server):
    command = host.run("bash /usr/local/bin/borg-backup list")
    assert command.rc == 0
    assert command.stderr == ''
    assert "Archives on %s :\n2" % server in command.stdout
