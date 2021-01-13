
limit::
	ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory -l $(L) provision.yaml

install:: ansible-freeipa up
	@ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision.yaml 
stop::
	@vagrant destroy -f
up:: 
	@vagrant up

ansible-freeipa:
	git clone --branch v0.3.1 git@github.com:freeipa/ansible-freeipa.git