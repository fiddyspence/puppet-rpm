Summary: An RPM to install pe-puppet and provide a default config
Name: pepuppetinstall
Version: 1.0.0
Release: 1
License: GPL
BuildArch: noarch
Group: System Environment/Base
BuildRoot: /usr/src/redhat/SOURCES/%{name}-buildroot
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
%config(noreplace) /etc/puppetlabs/puppet/pe-puppet.conf
/etc/puppetlabs/facter/facts.d/puppet_enterprise_installer.txt

%post
sed s/CERTNAME/$(hostname)/ /etc/puppetlabs/puppet/pepuppet.conf > /etc/puppetlabs/puppet/puppet.conf
