SERVERS=192.168.0.2 \
		192.168.0.1 \
		192.168.255.1 \
		192.168.255.2 \
		8.8.8.8 \
		192.168.255.5 \
		192.168.255.6 
limit::
	ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory -l $(L) provision.yaml

install:: up
	@ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision.yaml 
stop::
	@vagrant destroy -f
up::
	@vagrant up
test::
	@echo "############## RUN TEST  SYNC TRACE"
	@echo "## R2"
	@vagrant ssh r2 -c "ip route"
	@vagrant ssh r2 -c "mtr -n -r -c 1 1.1.1.30"

	@echo "##R3"
	@vagrant ssh r3 -c "ip route"
	@vagrant ssh r3 -c "mtr -n -r -c 1 1.1.1.20"
