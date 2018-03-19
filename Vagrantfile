# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

#    config.vm.box = "hashicorp/precise32"
    config.vm.box = "private/xenial64"
    config.librarian_puppet.puppetfile_dir = "librarian"

    config.vm.provider :aws do |aws, override|
        aws.access_key_id = "<ACCESS KEY ID>"
        aws.secret_access_key = "<SECRET ACCESS KEY>"
        aws.keypair_name = "devops"
        aws.ami = "ami-bb9bd7d7"
        aws.instance_type = 't2.micro'
        aws.region = 'sa-east-1'
        aws.user_data = File.read("bootstrap.sh")
        aws.subnet_id = "<SUBNET ID>"
        aws.elastic_ip = true
        override.vm.box = "dummy"
        override.ssh.username = "ubuntu"
        override.ssh.private_key_path = "~/devops.pem"
    end

    config.vm.define :ci do |build_config|
        build_config.vm.hostname = "ci"
        build_config.vm.network :private_network, :ip => "192.168.33.16"
        build_config.vm.provider "virtualbox" do |vb|
            vb.memory   = "2048"
            vb.cpus     = "2"
        end
        build_config.vm.provision "puppet" do |puppet|
          puppet.module_path = ["modules", "librarian/modules"]
          puppet.manifest_file = "ci.pp"
        end
        build_config.vm.provider :aws do |aws|
            aws.private_ip_address = "192.168.33.16"
            aws.tags = { 'Name' => 'CI' }
        end
    end

    config.vm.define :monitor do |monitor_config|
        monitor_config.vm.hostname = "monitor"
        monitor_config.vm.network :private_network, :ip => "192.168.33.14"
        monitor_config.vm.provider "virtualbox" do |vb|
            vb.memory   = "512"
        end
        monitor_config.vm.provision "puppet" do |puppet|
            puppet.module_path = ["modules", "librarian/modules"]
            puppet.manifest_file = "monitor.pp"
        end
    end

    config.vm.define :db do |db_config|
        db_config.vm.hostname = "db"
        db_config.vm.network :private_network, :ip => "192.168.33.10"
        
        db_config.vm.provision "puppet" do |puppet|
          puppet.module_path = ["modules", "librarian/modules"]
          puppet.manifest_file = "db.pp"
        end

        db_config.vm.provider :aws do |aws|
            aws.private_ip_address = "192.168.33.10"
            aws.tags = { 'Name' => 'DB' }
        end
    end

    config.vm.define :web do |web_config|
        web_config.vm.hostname = "web"
        web_config.vm.network :private_network, :ip => "192.168.33.12"

        web_config.vm.provider "virtualbox" do |vb|
            vb.memory   = "1024"
            vb.cpus     = "2"
        end
        web_config.vm.provision "puppet" do |puppet|
            puppet.module_path = ["modules", "librarian/modules"]
            puppet.manifest_file = "web.pp"
        end
        web_config.vm.provider :aws do |aws|
            aws.private_ip_address = "192.168.33.12"
            aws.tags = { 'Name' => 'Web' }
        end
    end

end
