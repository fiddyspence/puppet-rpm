Summary: An RPM to install pe-puppet and provide a default config
Name: pepuppetinstall
Version: 2.7.0
Release: 1
License: Puppet Labs Commercial Software License Agreement
BuildArch: noarch
Group: System Environment/Base
BuildRoot: /home/fids/
requires: pe-facter,pe-rubygem-stomp,pe-rubygem-hiera,pe-mcollective,pe-ruby-ri,pe-puppet-enterprise-release,pe-ruby,pe-ruby-irb,pe-rubygems,pe-mcollective-common,pe-puppet,pe-augeas-libs,pe-rubygem-hiera-puppet,pe-rubygem-stomp-doc,pe-ruby-ldap,pe-ruby-libs,pe-ruby-rdoc,pe-ruby-shadow,pe-augeas,pe-ruby-augeas

%description
An RPM to provide the deps for installing the pe-puppet agent

%prep
exit 0

%build
exit 0

%install
exit 0

%clean
exit 0

%files
%defattr(600,pe-puppet,pe-puppet)

%post 
/opt/puppet/bin/puppet resource file /etc/puppetlabs/puppet/manifests ensure=directory
cat > /etc/puppetlabs/puppet/manifests/agent.pp <<EOF
file { '/etc/puppetlabs/puppet/puppet.conf':
  ensure => present,
  owner  => 'pe-puppet',
  group => 'pe-puppet',
  mode => '0600',
  content => inline_template("[main]\n vardir = /var/opt/lib/pe-puppet \n    logdir = /var/log/pe-puppet \n    rundir = /var/run/pe-puppet \n    modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules \n    user = pe-puppet \n    group = pe-puppet \n    archive_files = true \n    archive_file_server = puppet \n \n[agent] \n    certname = <%= @fqdn -%> \n    server = puppet\n    report = true \n    classfile = $vardir/classes.txt \n    localconfig = $vardir/localconfig \n    graph = true\n"),
  notify => Service['pe-puppet'],
}

file { ['/etc/puppetlabs/facter','/etc/puppetlabs/facter/facts.d']:
  ensure => directory,
  owner => 'root',
  group => 'root',
  mode => '0755',
}

file { '/etc/puppetlabs/facter/facts.d/puppet_enterprise_installer.txt':
  ensure => file,
  owner => 'root',
  group => 'root',
  mode => '0644',
  content => "fact_stomp_port=61613\nfact_stomp_server=demomaster.puppet.demo\nfact_is_puppetagent=true\nfact_is_puppetmaster=false\nfact_is_puppetca=false\nfact_is_puppetconsole=false\n",
}  
service { 'pe-puppet':
  ensure => running,
  enable => true,
}
File <| |> -> Service <| |>
EOF
/opt/puppet/bin/puppet resource service pe-puppet ensure=stopped
/opt/puppet/bin/puppet resource file /var/opt/lib/pe-puppet ensure=absent recurse=true purge=true force=true
/opt/puppet/bin/puppet apply /etc/puppetlabs/puppet/manifests/agent.pp
for i in facter gem hiera pe-man puppet; do /opt/puppet/bin/puppet resource file /usr/local/bin/$i ensure=link target=/opt/puppet/bin/$i; done

