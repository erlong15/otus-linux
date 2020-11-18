# Borg backup role - Molecule testing

## Requirements


Ansible 2.4 or higher  
Molecule 2.17.0 or higher

Docker host (local or remote through shell environment)

## Available tests run on all scenarios

All scenarios run the same tests by default defined in generic_tests. If a test applies to a certain group only, group filtering is done through testinfra with the ansible:// url.
Eg:
```
testinfra_hosts = ["ansible://borgbackup_servers"]
```

### all

[generic\_files/tests/test_all.py](generic_files/tests/test_all.py)

Verify the borg-binary is present


### client

Testinfra: [generic\_files/tests/test_client.py](generic_files/tests/test_client.py)  
Verifies if all the required parameters are present on the client to perform a backup. It verifies an already existing backup has run and if it has succeeded.

Testinfra: [generic\_files/tests/test_client_restore.py](generic_files/tests/test_client_restore.py)  
Verifies if the restore functionality works correctly.

### server

Testinfra: [generic\_files/tests/test_server.py](generic_files/tests/test_server.py)  
Verifies if all server-related configurations are in place and if the backup is working from a server perspective.


## Available test-scenarios

### clients

This tests spins up supported platforms and verifies the basic functionality of both server and client with the generic_tests on a number of platforms and linux distributions.

```
borgbackup_appendonly:
borgbackup_servers:
borgbackup_include:
borgbackup_passphrase:
```

### multiple

Testing whether backing up to multiple targets works properly.

```
borgbackup_servers:
```

### extra_opts

Testinfra: [generic\_files/tests/test_server.py](generic_files/tests/test_server.py)

Verify if both pre and post commands are configured at backup time and are run.  


```
borgbackup_pre_commands:
borgbackup_post_commands:
```

Verify if both inclusion and exclusion of folders is working as expected

```
borgbackup_include:
borgbackup_exclude:
```

### lamp

Testinfra: [generic\_files/tests/test_lamp.py](generic_files/tests/test_lamp.py)
Verify a basic lamp setup meaning making sure /var/www/ and automysqlbackup is configured properly and backed up.  
As an extra preparation, apache2 and automysqlbackup are installed for verification.

```
backup_pre_commands: needs to be extended with automysqlbackup
borgbackup_include: need to contain both /var/www and /var/lib/automysqlbackup
```

### mgt

Testinfra: [generic\_files/tests/test_mgt.py](generic_files/tests/test_mgt.py)  
Testing whether the management-station functionality works and all clients are listed.

```
borgbackup_management:
borgbackup_management_user:
borgbackup_management_sshkey:
```

## restore

A restore is tested by default in every scenario by the use of the side-effect playbook. [generic\_files/side_effect.yml](generic_files/side_effect.yml)
