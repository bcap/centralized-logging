# -*- mode: ruby -*-

# maquinas e suas configs
machines = {
  "elasticsearch-1" => {:ip => "192.168.100.61", :memory => 512, :cpus => 1},
  "elasticsearch-2" => {:ip => "192.168.100.62", :memory => 512, :cpus => 1},
  "elasticsearch-3" => {:ip => "192.168.100.63", :memory => 512, :cpus => 1},
  "logstash-1" => {:ip => "192.168.100.71", :memory => 512, :cpus => 1},
  "logstash-2" => {:ip => "192.168.100.72", :memory => 512, :cpus => 1},
}

# cria arquivo de hosts baseado na config
File.open("hosts", 'w') do |file|
  file.write("127.0.0.1 localhost\n")
  machines.each do |name, data| file.write("#{data[:ip]} #{name}\n") end
end

# execucao da config
Vagrant.configure("2") do |config|

  config.vm.box = "centos-6.4"

  config.vm.synced_folder "/", "/host"

  config.vm.provision :puppet do |puppet|
    puppet.module_path = "puppet/modules"
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "main.pp"
    #puppet.options = "--verbose --debug"
  end

  machines.each do |name, data|
    config.vm.define name do |spec_config|
      spec_config.vm.hostname = name
      spec_config.vm.network :private_network, ip: data[:ip]
      #spec_config.vm.network :public_network
      spec_config.vm.provider :virtualbox do |vb|
        vb.gui = false
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--memory", data[:memory]]
        vb.customize ["modifyvm", :id, "--cpus",   data[:cpus]]
      end
    end
  end
end
