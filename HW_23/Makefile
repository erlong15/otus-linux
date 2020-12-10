
limit::
	ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory -l $(L) provision.yaml

install:: up
	@ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provisioning/playbook.yml 
stop::
	@vagrant destroy -f
up::
	@vagrant up
test::
	@echo "############## RUN TEST dig client"
	@echo "Run client dig +short www.newdns.lab @192.168.50.10"
	@vagrant ssh client -c "dig +short www.newdns.lab @192.168.50.10"
	@echo "Run client dig +short web1.dns.lab @192.168.50.10"
	@vagrant ssh client -c "dig +short web1.dns.lab @192.168.50.10"
	@echo "Run client dig +short web2.dns.lab @192.168.50.10"
	@vagrant ssh client -c "dig +short web2.dns.lab @192.168.50.10"

	@echo "############## RUN TEST dig client2"
	@echo "Run client2 dig +short www.newdns.lab @192.168.50.10"
	@vagrant ssh client2 -c "dig +short www.newdns.lab @192.168.50.10"
	@echo "Run client2 dig +short web1.dns.lab @192.168.50.10"
	@vagrant ssh client2 -c "dig +short web1.dns.lab @192.168.50.10"
	@echo "Run client2 dig +short web2.dns.lab @192.168.50.10"
	@vagrant ssh client2 -c "dig +short web2.dns.lab @192.168.50.10"


	@echo "############## RUN TEST dig client SLAVE"
	@echo "Run client dig +short www.newdns.lab @192.168.50.11"
	@vagrant ssh client -c "dig +short www.newdns.lab @192.168.50.11"
	@echo "Run client dig +short web1.dns.lab @192.168.50.11"
	@vagrant ssh client -c "dig +short web1.dns.lab @192.168.50.11"
	@echo "Run client dig +short web2.dns.lab @192.168.50.11"
	@vagrant ssh client -c "dig +short web2.dns.lab @192.168.50.11"

	@echo "############## RUN TEST dig client2 SLAVE"
	@echo "Run client2 dig +short www.newdns.lab @192.168.50.11"
	@vagrant ssh client2 -c "dig +short www.newdns.lab @192.168.50.11"
	@echo "Run client2 dig +short web1.dns.lab @192.168.50.11"
	@vagrant ssh client2 -c "dig +short web1.dns.lab @192.168.50.11"
	@echo "Run client2 dig +short web2.dns.lab @192.168.50.11"
	@vagrant ssh client2 -c "dig +short web2.dns.lab @192.168.50.11"