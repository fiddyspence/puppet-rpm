Summary: An RPM to install pe-puppet and provide a default config
Name: pe-agent-installer
Version: 2.7.0
Release: 1
License: Puppet Labs Commercial Software License Agreement
Source: pe-installer-%{version}.tar.gz
BuildArch: noarch
Group: System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-root
requires: pe-facter,pe-rubygem-stomp,pe-rubygem-hiera,pe-mcollective,pe-ruby-ri,pe-puppet-enterprise-release,pe-ruby,pe-ruby-irb,pe-rubygems,pe-mcollective-common,pe-puppet,pe-augeas-libs,pe-rubygem-hiera-puppet,pe-rubygem-stomp-doc,pe-ruby-ldap,pe-ruby-libs,pe-ruby-rdoc,pe-ruby-shadow,pe-augeas,pe-ruby-augeas

%description
An RPM to provide the deps for installing the pe-puppet agent

%prep

/bin/rm -rf %{buildroot}

%setup -q -n pe-installer-%{version}

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
/opt/puppet/bin/puppet apply --modulepath /etc/puppetlabs/puppet/modules /etc/puppetlabs/puppet/manifests/install.pp


