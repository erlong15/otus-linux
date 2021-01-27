
limit::
	ansible-playbook --ask-vault-pass -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory -l $(L) main.yaml

install:: up
	@ansible-playbook --ask-vault-pass -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory main.yaml 
stop::
	@vagrant destroy -f
up:: 
	@vagrant up
