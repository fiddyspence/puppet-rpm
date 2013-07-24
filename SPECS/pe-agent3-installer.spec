%define puppet_version 3.0.0
%define os_dist el
%define arch i386
%define release 1

# os_version defaults to 5 (el5) - to override this use...
# --define='use_os_version 6' as an argument to rpmbuild
%define os_version %{?use_os_version}%{?!use_os_version:6}

Summary: Installer for Puppet Enterprise Agent
Name: pe-puppet-agent-installer
Version: %{puppet_version}
Release: %{release}.%{os_dist}%{os_version}
Group: System/Tools
License: Restricted
URL: http://puppetlabs.com
Source: puppet-enterprise-%{puppet_version}-%{os_dist}-%{os_version}-%{arch}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-root

%description

WorldPay installer for Puppet Enterprise Agent


%prep
%{__rm} -rf %{buildroot}

%setup  -n puppet-enterprise-%{puppet_version}-%{os_dist}-%{os_version}-%{arch}

%install

mkdir -p %{buildroot}/opt/puppet
mkdir %{buildroot}/opt/puppet/.install
cp -r * %{buildroot}/opt/puppet/.install

%files
/opt/puppet

%post

cd /opt/puppet/.install

cat <<EOF > answers.txt
q_all_in_one_install=n
q_database_install=n
q_fail_on_unsuccessful_master_lookup=y
q_install=y
q_pe_database=n
q_puppet_cloud_install=n
q_puppet_enterpriseconsole_install=n
q_puppet_symlinks_install=y
q_puppetagent_certname=$(hostname -f)
q_puppetagent_install=y
q_puppetagent_server=puppet
q_puppetca_install=n
q_puppetdb_install=n
q_puppetmaster_install=n
q_run_updtvpkg=n
q_vendor_packages_install=n
EOF

./puppet-enterprise-installer -a answers.txt &

%clean

%{__rm} -rf %{buildroot}
