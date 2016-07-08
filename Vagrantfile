Vagrant.configure(2) do |config|
  required_plugins = %w(vagrant-omnibus)

  # install required plugins and restart if necessary
  plugins_to_install = required_plugins.reject { |plugin| Vagrant.has_plugin? plugin }
  unless plugins_to_install.empty?
    puts "Installing plugins: #{plugins_to_install.join(' ')}"
    if system "vagrant plugin install #{plugins_to_install.join(' ')}"
      exec "vagrant #{ARGV.join(' ')}"
    else
      abort 'Installation of one or more plugins has failed. Aborting.'
    end
  end

  config.vm.box = 'opentable/win-2012r2-standard-amd64-nocm'

  config.vm.network 'forwarded_port', guest: 11122, host: 11122
  config.vm.network 'forwarded_port', guest: 3306, host: 33306
  config.vm.network 'forwarded_port', guest: 3389, host: 3389

  config.vm.provider 'virtualbox' do |vb|
    vb.memory = 2048
    vb.cpus = 4
  end

  config.vm.provision 'shell', inline: <<EOT
cd /vagrant
if ( !(Test-Path ".chef") ) {
  echo "Please run 'berks vendor .chef' before provisioning"
  exit
}
chef-solo -c chef_solo.rb -j chef-solo.json -l debug
EOT

  config.omnibus.chef_version = :latest
  config.vm.communicator = 'winrm'
  config.vm.guest = :windows
end
