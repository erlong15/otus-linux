SERVERS=192.168.0.130 \
		192.168.0.50 \
		192.168.0.18 \
		192.168.0.66 \
		192.168.0.34 \
		192.168.0.2 \
		192.168.255.6 \
		192.168.255.10 \
		192.168.2.2 \
		192.168.2.66 \
		192.168.2.130 \
		192.168.2.194 \
		192.168.1.2 \
		192.168.1.130 \
		192.168.1.194 \
		8.8.8.8 


install:: up
	@ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory provision.yaml 
stop::
	@vagrant destroy -f
up::
	@vagrant up
test::
	@echo "############## RUN TEST in inetRouter"
	@vagrant ssh inetRouter -c "fping -q $(SERVERS)"
	

	@echo "############## RUN TEST in office2Server"
	@vagrant ssh office2Server -c "fping -q $(SERVERS)"					
	@vagrant ssh office2Server -c "mtr -n -r -c 1 ya.ru"

	@echo "############## RUN TEST in office1Server"
	@vagrant ssh office1Server -c "fping -q $(SERVERS)"
	@vagrant ssh office1Server -c "mtr -n -r -c 1 ya.ru"
						
	@echo "############## RUN TEST in centralServer"
	@vagrant ssh centralServer -c "fping -q $(SERVERS)"
	@vagrant ssh centralServer -c "mtr -n -r -c 1 ya.ru"
				
	@echo "Test ok" 