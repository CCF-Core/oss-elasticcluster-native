# -*- mode: ruby -*-
# vi: set ft=ruby :

# REFERENCES::
#  https://github.com/adrienthebo/vagrant-hosts
#  https://atlas.hashicorp.com/boxes/search?utf8=%E2%9C%93&sort=&provider=&q=centos7

require 'yaml'
require 'fileutils'

def noinit_err
  puts "Not initialized"
  exit!
end

# It's not really required. This shouldn't be fatal
unless Vagrant.has_plugin?("vagrant-hosts")
  puts 'The "vagrant-hosts" plugin is required!  Run "vagrant plugin install vagrant-hosts"'
end

VAGRANTFILE_API_VERSION = 2
# !! GREAT for debugging, when "Warning: Connection timeout. Retrying..." !!
VM_CONSOLE = false

hosts_file = File.join(Dir.pwd, "vagrant-hosts.yml")

while !File.exist? hosts_file do
  parent_dir = File.dirname(File.dirname hosts_file)
  hosts_file = File.join(parent_dir, File.basename(hosts_file))
end

noinit_err if !File.exist? hosts_file

hosts = YAML.load_file(hosts_file)["hosts"]
noinit_err  if hosts.length == 0

# vagrant_files = "vg-files.yml"
# noinit_err  if !File.exist? vagrant_files

# vgfiles = YAML.load_file(vagrant_files)["vgfiles"]
# noinit_err  if vgfiles.length == 0

$vagrant_sudoers = <<SCRIPT
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/vagrant
SCRIPT


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
  config.ssh.private_key_path = [ "~/.vagrant.d/insecure_private_key" ]
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.synced_folder ".", "/home/vagrant/oss-elasticcluster-native"

  # update VBox guest-additions, when booting this VM
  config.vbguest.auto_update = true
  # do not download the guest-additions iso-file
  config.vbguest.no_remote = true

  hosts.each do |hostname, host|
    config.vm.define hostname do |h|
      h.vm.host_name = host['hostname']
      h.vm.box = "centos/7"
      h.vm.network :private_network, :ip => host['ip']
      h.vm.network :forwarded_port, id: "ssh", guest: 22, host: host['ssh_port'], auto_correct: false
#      h.vm.network :forwarded_port, id: "8300UDP", guest: 8300, host: 8300, auto_correct: false, protocol: "udp"
#      h.vm.network :forwarded_port, id: "8300TCP", guest: 8300, host: 8300, auto_correct: false, protocol: "tcp"
#      h.vm.network :forwarded_port, id: "8301UDP", guest: 8301, host: 8301, auto_correct: false, protocol: "udp"
#      h.vm.network :forwarded_port, id: "8301TCP", guest: 8301, host: 8301, auto_correct: false, protocol: "tcp"


      unless host['forwards'] == nil
        host['forwards'].each do |f|
          h.vm.network :forwarded_port, guest: f['guest'],
                                        host: f['host'],
                                        auto_correct: false
        end
      end

      # h.vm.boot_timeout = 150  # default: 300 seconds

      h.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", host['mem'], '--cpus', host['cpus']]
        vb.gui = VM_CONSOLE  # -- default, false  -- headless mode
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      end
    end

    config.vm.provision "shell", inline:<<-eof
      sudo yum install -y net-tools; [[ "$(/sbin/ifconfig eth1 | grep -e 'inet [^ ]*' | awk '{print $2}')" == "#{host['ip']}" ]] \
      && (iptables -t nat -L PREROUTING | grep #{host['ip']}\
        || iptables -t nat -A PREROUTING -p tcp -d $(/sbin/ifconfig eth0 | grep -e 'inet [^ ]*' | awk '{print $2}')\
         --dport 9200 -j DNAT --to-destination #{host['ip']}) || true
      eof

    config.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/site.yml"
        ansible.inventory_path = "ansible/environments/dev/inventory.yml"
        #ansible.verbose = "vvv"
        #ansible.tags='consul'
    end
  end
end
