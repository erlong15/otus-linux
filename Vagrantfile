# -*- mode: ruby -*-
# vi: set ft=ruby :
MACHINES = {
   # VM name "kernel-update"
  :"CentoS-Elrepo" => {
              # VM box
              :box_name => "centos-7-5",
              # VM CPU count
              :cpus => 2,
              # VM RAM size (Mb)
              :memory => 768,
              # networks
              :net => [],
              # forwarded ports
              :forwarded_port => []
            }
}
Vagrant.configure("2") do |config|
    MACHINES.each do |boxname, boxconfig|
    # Disable shared folders
    config.vm.synced_folder ".", "/vagrant", disabled: false

    config.vm.box = "centos-7-5"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
   config.vm.synced_folder "./share", "/home/vagrant/share"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
end