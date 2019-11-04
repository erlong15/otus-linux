Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"

  
    config.vm.synced_folder "./share", "/home/vagrant/share"

     # config.vm.name "centoss"
   config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
    end
  
   # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
 
end
