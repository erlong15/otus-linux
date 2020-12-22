
install:: up
	@ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision.yaml 

install-ras:: up
	@ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision-ras.yaml 
stop::
	@vagrant destroy -f
up::
	@vagrant up

install-tap:: up
	@ansible-playbook -e vpn_mode=tap -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision-tun.yaml 

install-tun:: up 
	@ansible-playbook -e vpn_mode=tun -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision-tun.yaml 

openvpn-client-start::
	sudo openvpn --config template/client-01.ovpn
