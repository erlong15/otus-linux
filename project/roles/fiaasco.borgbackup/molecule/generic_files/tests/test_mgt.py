import os
import pytest
from testinfra.utils.ansible_runner import AnsibleRunner

testinfra_hosts = ["ansible://borgbackup_management"]


# to do read inventory variable : export BORG_PASSPHRASE="{{ borgbackup_passphrase }}"
@pytest.mark.parametrize('client', AnsibleRunner(os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('clients'))
def test_prune_script(host, client):
    prune = host.file("/root/prune.sh")
    assert prune.user == "root"
    assert prune.group == "root"
    assert prune.mode == 0o700
    assert prune.contains("borg prune -v")
    assert prune.contains("export BORG_PASSPHRASE=")
    assert prune.contains("Host: %s" % client)
    assert prune.contains(":/var/backup/repos/%s" % client)
