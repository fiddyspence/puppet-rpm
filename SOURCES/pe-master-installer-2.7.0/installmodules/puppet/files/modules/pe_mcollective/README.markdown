# pe_mcollective #

This module is specifically designed to manage the MCollective server
authentication RSA keys for use with Puppet Enterprise.  There are no end-user
facing pieces to this module.

Please see the documentation header for the pe\_mcollective class for more
information.

## Adding Tests

Please see the [rspec-puppet](https://github.com/rodjek/rspec-puppet) project
for information on writing tests.  A basic test that validates the class is
declared in the catalog is provided in the file `spec/classes/*_spec.rb`.
`rspec-puppet` automatically uses the top level description as the name of a
module to include in the catalog.  Resources may be validated in the catalog
using:

 * `contain_class('myclass')`
 * `contain_service('sshd')`
 * `contain_file('/etc/puppet')`
 * `contain_package('puppet')`
 * And so forth for other Puppet resources.

### Running

To run all the rspec tests in the module, use the `spec` rake task.

`# rake spec`

## Note on identity

This version of the pe\_mcollective module configure mcollective to use the
puppet agent's node name as configured by the [node\_name\_value](http://docs.puppetlabs.com/references/2.7.9/configuration.html#nodenamevalue).
Previously, the module used MCollective's default behavior of using the 
hostname of the node for the identity as it pertains to MCollective.

## Java Heap Size

The Java heap size may be tuned by setting the `activemq_heap_mb` class
parameter.  The value should be a string number representing the number of
megabytes to allocate.

In order to support the Puppet Dashboard, this setting may be set as a Node
parameter or as a Fact.  If the class parameter is not set the value will be
looked up in top scope.  If it is not defined in top scope it will default to
512 MB.
