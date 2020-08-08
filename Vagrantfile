Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  config.vm.box = "pitakill/hashi-machine"
  config.ssh.password = "vagrant"

  segment = '172.20.20'

  clusters = {
    :sfo => [
      {
        :type => "server",
        :ip => "#{segment}.11",
        :is_server => true,
        :ip_server => "",
        :domain => "sfo",
        :grafana => false
      },
      {
        :type => "client",
        :ip => "#{segment}.12",
        :is_server => false,
        :ip_server => "#{segment}.11",
        :domain => "sfo-client",
        :grafana => true
      }
    ],
    :nyc => [
      {
        :type => "server",
        :ip => "#{segment}.21",
        :is_server => true,
        :ip_server => "",
        :domain => "nyc",
        :grafana => false
      },
      { 
        :type => "client",
        :ip => "#{segment}.22",
        :is_server => false,
        :ip_server => "#{segment}.21",
        :domain => "nyc-client",
        :grafana => false
      }
    ],
  }
  
  clusters.each do |cluster, data|
    data.each do |machine|
      config.vm.define "#{cluster}-consul-#{machine[:type]}" do |cs|
        cs.vm.hostname = "#{cluster}-consul-#{machine[:type]}"
        cs.vm.network "private_network", ip: "#{machine[:ip]}"
        cs.vm.provision "shell", path: "provision/scripts/init.hashi.sh", args: "#{cluster} #{machine[:ip]} #{machine[:is_server]} #{machine[:domain]} #{machine[:ip_server]}", privileged: false
        cs.vm.provision "shell", path: "provision/scripts/setup.dns.sh", args: "#{machine[:ip]}", privileged: false

        if machine[:grafana]
          cs.vm.network :forwarded_port, guest: 3999, guest_ip: "10.0.2.15", host: 3999,  host_ip: "0.0.0.0"
        end

        cs.vm.provision "shell", privileged: false, inline: <<-EOF
          echo "Vagrant Box provisioned!"
        EOF
      end
    end
  end
end
