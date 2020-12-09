
limit::
	ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory -l $(L) provision.yaml

install:: up
	@ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision.yaml 
stop::
	@vagrant destroy -f
up::
	@vagrant up
test::
	@echo "############## RUN PING TEST VLAN ISOLATED"
	@echo "Run testClient1"
	@vagrant ssh testClient1 -c "fping -q 10.10.10.1 10.10.10.254"
	@echo "Run testClient2"
	@vagrant ssh testClient2 -c "fping -q 10.10.10.1 10.10.10.254"

	@echo "############## RUN PING TEST  teaming"
	@echo "Run centralRouter"
	@vagrant ssh centralRouter -c "fping -q 192.168.255.1 192.168.255.2"
	@echo "Run inetRouter"
	@vagrant ssh inetRouter -c "fping -q 192.168.255.1 192.168.255.2"

	@echo "############## RUN  TEST STOP interface  teaming"
	@echo "Run centralRouter eth1 down -> ping -> eth1 up -> eth2 down - ping -> eth2 up  "
	@vagrant ssh centralRouter -c "sudo ip link set dev eth1 down && \
									fping -q 192.168.255.1 192.168.255.2 && \
									sudo ip link set dev eth1 up && \
									sudo ip link set dev eth2 down && \
									fping -q 192.168.255.1 192.168.255.2 && \
									sudo ip link set dev eth2 up "
	@echo "Run inetRouter eth1 down -> ping -> eth1 up -> eth2 down - ping -> eth2 up"
	@vagrant ssh inetRouter -c "sudo ip link set dev eth1 down && \
									fping -q 192.168.255.1 192.168.255.2 && \
									sudo ip link set dev eth1 up && \
									sudo ip link set dev eth2 down && \
									fping -q 192.168.255.1 192.168.255.2 && \
									sudo ip link set dev eth2 up "