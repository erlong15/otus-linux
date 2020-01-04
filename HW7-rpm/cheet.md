# Make

```bash
./configure # Run configurator
./configure --help
make # Run building process
make clean # Remove all builded files
make install # Install compiled programm
make uninstall # Uninstall previously installed programm
```

# RPM

## Basics

```bash
rpm -q pckg_name # Show is packages installed
rpm -qi pckg_name # Show package metadata
rpm -i *.rpm # Install RPM file
rpm -e pckg_name # Delete package
rpm -ql pckg_name # List package files
rpm -q --scripts pckg_name # List package scriptlets
rpm -qR pckg_name # Show package dependacies
rpm -qf file # Show package that own file
rpm2cpio rmp_file | cpio -idmv # Unpack .rmp file
```

## Build own package

```bash
rpmdev-setuptree
rpmbuild -bb otus.spec # RPM buld
rpmbuild -bs otus.spec # SRPM build
rpmbuild -ba otus.spec # RPM+SRPM build
```

# MOCK

```bash
mock -r epel-7-x86_64 --rebuild ~/rpmbuild/SRPMS/clogtail-0.3.0-2.fc28.src.rpm
```

# YUM

## Basics

```bash
yum search # Search package in repos
yum list all # Show all installed and available packages
yum list installed # Show only installed packages
yum list installed "yum-*" # With regexp
yum info # Show information about package
yum grouplist # Show package groups
yum groupinfo Development Tools # Show info about certain group
yum groupinstall Development Tools # Install package group
yum install # Install package
update
downgrade
check-update
yum remove # Remove package
yum groupremove # Remove package group 
provides
shell
```
## History

```bash
yum history list # Show yum history
yum history package-list glob_expression # Show history by glob_expression
yum history info 9 # Show about transaction
yum history undo 9 # Undo certain transaction
```

## Repos

```bash
yum repolist all # Show all available repos
yum repolist enabled # Show only enabled repos
yum-config-manager -add-repo URL
yum-config-manager --enable reponame
yum-config-manager --disable reponame
```

# DOCKER

## Basic

```bash
docker ps -a
docker logs
docker top
docker stats --all
docker inspect 
docker diff
docker system df
docker exec -it cnt_name /bin/sh
docker rm $(docker )
```

## Images

```bash
docker images
docker import # Create image from tarballt
docker build
docker commit # Create image from container
docker rmi
```

## Registry & Repo

```bash
docker login
docker logout
docker search
docker pull # Pull image from registry
docker push # Push imate to registry
```

## Prune

```bash
docker system prune
docker volume prune
docker network prune
docker container prune
docker image prune
```

## Hints & Tips

```bash
docker kill $(docker ps -q) # Kill all running containers
docker rm -f  $(docker ps -qa) # Delete all containers
docker rm -v $(docker ps -a -q -f status=exited) # Delete only stopped containers
docker rmi $(docker images -q) # Delete all images
```
