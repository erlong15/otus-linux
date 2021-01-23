import os
import pytest
from testinfra.utils.ansible_runner import AnsibleRunner

testinfra_hosts = ["ansible://clients"]


def test_client_sample_file(host):
    sample = host.file("/root/sample.txt")
    assert sample.is_file


@pytest.mark.parametrize('server', AnsibleRunner(os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('borgbackup_servers'))
def test_client_diff(host, server):
    command = host.run("diff -s /root/sample.txt /root/restore/%s/root/sample.txt" % server)
    assert command.rc == 0
    assert "Files /root/sample.txt and /root/restore/%s/root/sample.txt are identical" % server in command.stdout


@pytest.mark.parametrize('server', AnsibleRunner(os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('borgbackup_servers'))
def test_client_verify(host, server):
    vcommand = host.run("/root/restore.sh verify")
    assert vcommand.rc == 0
    assert vcommand.stdout.rstrip("verifying on %s" % server)
