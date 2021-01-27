
limit::
	ansible-playbook --vault-password-file .vault_pass.txt -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory -l $(L) main.yaml

install:: up
	@ansible-playbook --vault-password-file .vault_pass.txt -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory main.yaml 
stop::
	@vagrant destroy -f
up:: 
	@vagrant up
