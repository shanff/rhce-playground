# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "sl7"

  # config.vm.box_check_update = false
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
 

  $master = ['master']
  $nodes = ['node1', 'node2']
  $all = $master + $nodes
  domain = 'rhce.local'

  $all.each do |box|
    config.vm.define "#{box}" do |node| 
    node.vm.hostname = "#{box}.#{domain}"

    #node.vm.network :private_network, 
    #:management_network_mode => "veryisolated",
    #:management_network_address => "192.168.122.0/24",
    #:management_network_name => "rhce-management",
    #:libvirt__forward_mode => "veryisolated",
    #:libvirt__dhcp_start => "192.168.122.2", 
    #:libvirt__dhcp_stop => "192.168.122.254",
    #:libvirt__network_name => "rhce-management" 

    if $nodes.include? box

      #node.vm.network :private_network, 
      #:libvirt__netmask => "255.255.255.0",
      #:libvirt__network_address => "172.16.1.0", 
      #:libvirt__dhcp_enabled => true, 
      #:libvirt__dhcp_start => "172.16.1.128", 
      #:libvirt__dhcp_stop => "172.16.1.254", 
      #:libvirt__ipv6_address => "fd00:1001:abcd::/64",
      #:libvirt__forward_mode => "veryisolated", 
      #:libvirt__network_name => "rhce-default" 

      # Private network using virtual network switching
      node.vm.network :private_network, 
        :libvirt__dhcp_enabled => false, 
        :libvirt__ipv6_address => "fd00:2001:abcd::/64",
        :libvirt__forward_mode => "veryisolated",
        :libvirt__network_name => "rhce-data1" 

      node.vm.network :private_network, 
        :libvirt__dhcp_enabled => false, 
        :libvirt__ipv6_address => "fd00:2002:abcd::/64",
        :libvirt__forward_mode => "veryisolated",
        :libvirt__network_name => "rhce-data2"
    else
      ## master IP
      # node.vm.network :private_network, 
      #  :ip => "172.16.1.100",
      #  :libvirt__netmask => "255.255.255.0",
      #  :libvirt__network_address => "172.16.1.0", 
      #  :libvirt__dhcp_enabled => true, 
      #  :libvirt__dhcp_start => "172.16.1.128", 
      #  :libvirt__dhcp_stop => "172.16.1.254", 
      #  :libvirt__ipv6_address => "fd00:1001:abcd::/64",
      #  :libvirt__forward_mode => "veryisolated", 
      #  :libvirt__network_name => "rhce-default" 
    end

    if $master.include? box
	node.vm.provider :libvirt do |domain|
	    # Need to update to avoid this error during IPA installation:
	    # ...
	    # [10/29]: requesting RA certificate from CA
	    # [error] RuntimeError: Certificate issuance failed (CA_UNREACHABLE)
  	    domain.memory = 1024
	end
  	node.vm.synced_folder './', '/vagrant', type: 'nfs', nfs_udp: false 
  	node.vm.provision "shell", path: "files/Provisionfile-master.sh"
	node.trigger.after :up do
		  run_remote  "sudo /usr/bin/mount -a"
	end
    else
        node.vm.synced_folder './', '/vagrant', disabled: true
  	node.vm.provision "shell", path: "files/Provisionfile-node.sh"
    end

  end
 end


end
