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
	@echo "############## RUN TEST in inetRouter"
	@vagrant ssh inetRouter -c "fping -q $(SERVERS)"
	@vagrant ssh inetRouter -c "nc -zv 192.168.0.2 8080"

						
	@echo "############## RUN TEST in centralServer"
	@vagrant ssh centralServer -c "fping -q $(SERVERS)"
	@vagrant ssh centralServer -c "mtr -n -r -c 1 ya.ru"
	@vagrant ssh centralServer -c "nc -zv 192.168.0.2 8080"
	@vagrant ssh centralServer -c "knock.sh 192.168.255.1 8881 7777 9991 && nc -zv 192.168.255.1 22" 
	@echo "############## RUN TEST in inetRouter  cat /proc/net/xt_recent/SSH*"
	@vagrant ssh inetRouter -c "cat /proc/net/xt_recent/SSH*"

	
	@echo "############## RUN TEST in inetRouter2"
	@vagrant ssh inetRouter2 -c "fping -q $(SERVERS)"
	@vagrant ssh inetRouter2 -c "nc -zv 192.168.0.2 8080"

	@echo "############## RUN TEST in localhost to 192.168.50.10"
	curl -I 192.168.50.10 
	@echo "Test ok" 