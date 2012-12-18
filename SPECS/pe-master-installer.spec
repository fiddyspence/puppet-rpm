Summary: An RPM to install pe-puppetmaster and provide a default config
Name: pe-master-installer
Version: 2.7.0
Release: 1
License: Puppet Labs Commercial Software License Agreement
Source: pe-installer-%{version}.tar.gz
BuildArch: noarch
Group: System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-root
requires: pe-ruby-libs,pe-ruby-irb,pe-rubygem-rake,pe-rubygem-activerecord,pe-augeas-libs,pe-httpd-passenger,pe-rubygem-tilt,pe-console,pe-activemq,pe-mcollective,pe-rubygem-json,pe-memcached,pe-puppet-enterprise-release,pe-ruby,pe-facter,pe-ruby-rdoc,pe-rubygem-stomp,pe-mcollective-common,pe-rubygem-activesupport,pe-ruby-shadow,pe-rubygem-hiera,pe-tanukiwrapper,pe-httpd,pe-puppet-dashboard,pe-rubygem-dalli,pe-rubygem-sinatra,pe-console-auth,pe-certificate-manager,pe-mod_ssl,pe-augeas,pe-puppet-server,pe-mcollective-client,pe-ruby-augeas,pe-ruby-ldap,pe-libevent,pe-ruby-mysql,pe-rubygems,pe-rubygem-rack,pe-puppet,pe-httpd-tools,pe-rubygem-ar-extensions,pe-live-management,pe-puppet-dashboard-baseline,pe-rubygem-hiera-puppet,pe-rubygem-stomp-doc,pe-ruby-ri,mysql-server

%description
An RPM to provide the deps for installing the pe-puppet master

%prep

/bin/rm -rf %{buildroot}

%setup -q -n pe-masterinstaller-%{version}

%install

mkdir -p %{buildroot}/etc/puppetlabs/puppet/modules
mkdir -p %{buildroot}/etc/puppetlabs/puppet/manifests
cp -r modules/* %{buildroot}/etc/puppetlabs/puppet/modules
cp -r manifests/install.pp %{buildroot}/etc/puppetlabs/puppet/manifests/install.pp

%clean

%files
%defattr(600,pe-puppet,pe-puppet)
%config /etc/puppetlabs/puppet/modules
%config /etc/puppetlabs/puppet/manifests

%post 
/opt/puppet/bin/puppet resource service pe-puppet ensure=stopped
/opt/puppet/bin/puppet resource service pe-httpd ensure=stopped
/opt/puppet/bin/puppet resource service pe-activemq ensure=stopped
/opt/puppet/bin/puppet resource service pe-mcollective ensure=stopped
/opt/puppet/bin/puppet resource service pe-memcached ensure=stopped
/opt/puppet/bin/puppet resource service pe-puppet-dashboard-workers ensure=stopped
/opt/puppet/bin/puppet apply --modulepath /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules /etc/puppetlabs/puppet/manifests/masterinstall.pp

