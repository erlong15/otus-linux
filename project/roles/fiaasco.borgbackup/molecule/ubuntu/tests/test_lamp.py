testinfra_hosts = ["ansible://lamp"]


def test_lamp_default(host):
    script = host.file("/usr/local/bin/borg-backup")
    assert script.contains("/usr/sbin/automysqlbackup")
    assert script.contains("/var/lib/automysqlbackup")
    assert script.contains("/var/www")
    assert script.user == "root"
    assert script.group == "root"


def test_lamp_automysqlbackup(host):
    backup_dir = host.file("/var/lib/automysqlbackup/daily")
    assert backup_dir.exists
    assert backup_dir.is_directory
