Summary: An RPM to install pe-puppet and provide a default config
Name: pepuppetinstall
Version: 2.7.0
Release: 1
License: Puppetlabs Commercial Software Agreement
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
