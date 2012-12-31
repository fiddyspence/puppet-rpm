Summary: An RPM to install pe-puppetmaster and provide a default config
Name: pe-master-installer
Version: 2.7.0
Release: 1
License: Puppet Labs Commercial Software License Agreement
Source: pe-master-installer-%{version}.tar.gz
BuildArch: noarch
Group: System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-root
requires: pe-ruby-libs,pe-ruby-irb,pe-rubygem-rake,pe-rubygem-activerecord,pe-augeas-libs,pe-httpd-passenger,pe-rubygem-tilt,pe-console,pe-activemq,pe-mcollective,pe-rubygem-json,pe-memcached,pe-puppet-enterprise-release,pe-ruby,pe-facter,pe-ruby-rdoc,pe-rubygem-stomp,pe-mcollective-common,pe-rubygem-activesupport,pe-ruby-shadow,pe-rubygem-hiera,pe-tanukiwrapper,pe-httpd,pe-puppet-dashboard,pe-rubygem-dalli,pe-rubygem-sinatra,pe-console-auth,pe-certificate-manager,pe-mod_ssl,pe-augeas,pe-puppet-server,pe-mcollective-client,pe-ruby-augeas,pe-ruby-ldap,pe-libevent,pe-ruby-mysql,pe-rubygems,pe-rubygem-rack,pe-puppet,pe-httpd-tools,pe-rubygem-ar-extensions,pe-live-management,pe-puppet-dashboard-baseline,pe-rubygem-hiera-puppet,pe-rubygem-stomp-doc,pe-ruby-ri

%description
An RPM to provide the deps for installing the pe-puppet master

%prep

/bin/rm -rf %{buildroot}

%setup -q -n pe-master-installer-%{version}

%install

mkdir -p %{buildroot}/etc/puppetlabs/puppet/installmodules
mkdir -p %{buildroot}/etc/puppetlabs/puppet/installmanifests
cp -r installmodules/* %{buildroot}/etc/puppetlabs/puppet/installmodules
cp -r installmanifests/install.pp %{buildroot}/etc/puppetlabs/puppet/installmanifests/install.pp

%clean

%files
%defattr(600,pe-puppet,pe-puppet)
%config /etc/puppetlabs/puppet/installmodules
%config /etc/puppetlabs/puppet/installmanifests

%post 
/opt/puppet/bin/puppet resource service pe-puppet ensure=stopped
/opt/puppet/bin/puppet resource service pe-httpd ensure=stopped
/opt/puppet/bin/puppet resource service pe-activemq ensure=stopped
/opt/puppet/bin/puppet resource service pe-mcollective ensure=stopped
/opt/puppet/bin/puppet resource service pe-memcached ensure=stopped
/opt/puppet/bin/puppet resource service pe-puppet-dashboard-workers ensure=stopped

# perform some initial setup
/opt/puppet/bin/puppet apply --modulepath /etc/puppetlabs/puppet/installmodules:/opt/puppet/share/puppet/modules --no-report -v --exec 'class { puppet: }'

#did this with a dirty exec hack in the puppet::requestmanager class to try and keep our entry point to a single class
#/opt/puppet/bin/puppet apply --no-report --modulepath /opt/puppet/share/puppet/modules -v --exec 'class { request_manager: }'

