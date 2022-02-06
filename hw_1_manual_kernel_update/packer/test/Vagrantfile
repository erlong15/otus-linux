# Describe VMs
MACHINES = {
  # VM name "kernel update"
  :"kernel-update" => {
              # VM box
              :box_name => "centos-7-5",
              # VM CPU count
              :cpus => 2,
              # VM RAM size (Mb)
              :memory => 1024,
              # networks
              :net => [],
              # forwarded ports
              :forwarded_port => []
            }
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    # Disable shared folders
    config.vm.synced_folder ".", "/vagrant", disabled: true
    # Apply VM config
    config.vm.define boxname do |box|
      # Set VM base box and hostname
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxname.to_s
      # Additional network config if present
      if boxconfig.key?(:net)
        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end
      end
      # Port-forward config if present
      if boxconfig.key?(:forwarded_port)
        boxconfig[:forwarded_port].each do |port|
          box.vm.network "forwarded_port", port
        end
      end
      # VM resources config
      box.vm.provider "virtualbox" do |v|
        # Set VM RAM size and CPU count
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
      end
    end
  end
end
