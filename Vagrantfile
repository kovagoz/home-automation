# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  [ 80, 8001, 8002, 8003 ].each do |port|
    config.vm.network :forwarded_port, guest: port, host: port
  end
end
