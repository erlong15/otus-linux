# Description

Script for "Package" lecture at OTUS

## Make


1. Show examples with clogtail and PostgreSQL sources

```bash
wget https://ftp.postgresql.org/pub/source/v10.6/postgresql-10.6.tar.gz
tar -xvf postgresql-10.6.tar.gz
cd postgresql-10.6.tar.gz
./configure --help
```

## RPM most friquency commands

```bash
rpm -q [pkg_name] # Query info
rpm -qa # Query all installed packages. Grep is your friend
rpm -qi [pkg_name]

```

## RPM Building with

1. Download and building clogtail for Alexandr Rumyantsev Repo

```bash
git clone https://github.com/thedolphin/clogtail
cd clogtail
less clogtail.spec
rpmbuild -bb clogtail.spec
clogtail
```

2. Download and building redis from sources

```bash
yumdownloader --source redis
rpm -ihv redis-3.2.12-2.el7.src.rpm
rpmbuild -ba rpmbuild/SPECS/redis.spec
yum-buildep redis -y
rpmbuild -ba rpmbuild/SPECS/redis.spec
tree -L 3 rmpbuild/
```

3. Build package with mock for CentOS 6

```bash
sudo usermod -a -G mock root
mock -r epel-6-x86_64 --rebuild rpmbuild/SRPMS/redis-3.2.12-2.el7.src.rpm
```

## YUM

### Кейсы

#### Дубликаты пакетов

yum search --showduplicates <package_name>
package-cleanup --dupes
package-cleanup --cleandupes
package-cleanup --problems

#### Установка из определенного репозитория

yum repolist
yum —disablerepo=”*” —enablerepo=”epel” install nginx
yum —disablerepo=”*” —enablerepo=”epel” update

### Create your own repo

```bash
yum install createrepo -y -q
createrepo /usr/share/nginx/html
cat << EOF > /etc/yum.repos.d/otus.repo
[otus]
name=Otus-Linux
baseurl=http://192.168.11.101/
enabled=1
gpgcheck=0
EOF
yum repolist enabled
yum search clogtail
```
