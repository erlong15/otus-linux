install:: 
	@ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision.yml
stop::
	@vagrant destroy -f
up::
	@vagrant up pxeserver

up-client::
	@vagrant up pxeclient