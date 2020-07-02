Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  config.vm.box = "ubuntu/xenial64"
  config.vm.provision "shell", path: "provision/scripts/install.sh", args: "", privileged: false

  segment = '172.20.20'

  clusters = {
    :sfo => [
      { :type => "server", :ip => "#{segment}.11", :is_server => true, :ip_server => "" },
      { :type => "client", :ip => "#{segment}.12", :is_server => false, :ip_server => "#{segment}.11" }
    ],
    :nyc => [
      { :type => "server", :ip => "#{segment}.21", :is_server => true, :ip_server => "" },
      { :type => "client", :ip => "#{segment}.22", :is_server => false, :ip_server => "#{segment}.21" }
    ],
  }
  
  clusters.each do |cluster, data|
    data.each do |machine|
      config.vm.define "#{cluster}-consul-#{machine[:type]}" do |cs|
        cs.vm.hostname = "#{cluster}-consul-#{machine[:type]}"
        cs.vm.network "private_network", ip: "#{machine[:ip]}"
        cs.vm.provision "shell", path: "provision/scripts/init.hashi.sh", args: "#{cluster} #{machine[:ip]} #{machine[:is_server]} #{machine[:ip_server]}", privileged: false
        if machine[:is_server]
          cs.vm.provision "shell", path: "provision/scripts/install.dnsmasq.sh", privileged: false
        end

        cs.vm.provision "shell", privileged: false, inline: <<-EOF
          echo "Vagrant Box provisioned!"
        EOF
      end
    end
  end
end
