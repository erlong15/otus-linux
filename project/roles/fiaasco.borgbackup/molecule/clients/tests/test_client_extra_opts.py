testinfra_hosts = ["ansible://extra_opts"]


def test_include_exclude(host):
    script = host.file("/usr/local/bin/borg-backup")
    assert script.contains("/var/cache")
    assert script.contains("--exclude '/var/cache/apt'")
    assert script.user == "root"
    assert script.group == "root"


def test_pre_post_commands(host):
    script = host.file("/usr/local/bin/borg-backup")
    assert script.contains("dpkg --get-selection")
    assert script.contains("apt list")
    assert script.user == "root"
    assert script.group == "root"
