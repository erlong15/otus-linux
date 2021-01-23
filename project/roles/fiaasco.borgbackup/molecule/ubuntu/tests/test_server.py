import os
import pytest
from testinfra.utils.ansible_runner import AnsibleRunner

testinfra_hosts = ["ansible://borgbackup_servers"]


def test_server_client_parent_dir(host):
    parentdir = host.file("/var/backup/repos")
    assert parentdir.is_directory


@pytest.mark.parametrize('client', AnsibleRunner(os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all:!borgbackup_servers'))
def test_server_client_dir(host, client):
    clientdir = host.file("/var/backup/repos/%s" % client)
    assert clientdir.is_directory


@pytest.mark.parametrize('client', AnsibleRunner(os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all:!borgbackup_servers'))
def test_server_client_ssh_conf(host, client):
    sshconf = host.file("/var/backup/.ssh/authorized_keys")
    assert sshconf.is_file
    assert sshconf.contains("%s;borg serve" % client)
