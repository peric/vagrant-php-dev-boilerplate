Vagrant.configure("2") do |config|
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.vm.network :private_network, ip: "192.168.56.101"
    config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--name", "vagrant-php-dev-boilerplate-box"]
  end

  config.vm.synced_folder "../master-thesis/flasknose", "/var/www/webapp", id: "vagrant-root"
  config.vm.synced_folder "../master-thesis/flasknose/exports", "/var/www/webapp/exports", {:mount_options => ['dmode=777','fmode=777'], :owner => "www-data", :group => "www-data"}
  config.vm.synced_folder "../master-thesis/flasknose/scripts", "/var/www/webapp/scripts", {:mount_options => ['dmode=777','fmode=777'], :owner => "www-data", :group => "www-data"}
  config.vm.provision :shell, :path => "bootstrap.sh"
end
