
## Getting puppetlabs-auth_conf acceptance tests running with pe-dev-env ##

First we have to set up the directory that git repositories are cloned into.

Run the following in your _master_ VM:

    mkdir /opt/puppet-git-repos/
    puppet module install ripienaar-concat

After doing that, use the following as an example for running the actual tests. The commands are run from the directory of
a clone of [puppet_acceptance](https://github.com/puppetlabs/puppet-acceptance). Note that you may have to change the IP
specified in `$MODULE_PATH/acceptance/integration.cfg` if it is not the default `pe-dev-env` IP (33.33.33.10).

    export MODULE_PATH=../modules/puppetlabs-auth_conf

    ./systest.rb --type pe \
    --debug \
    --no-install \
    --keyfile ~/.vagrant.d/insecure_private_key \
    --config $MODULE_PATH/acceptance/integration.cfg \
    --tests $MODULE_PATH/acceptance/tests/ \
    --setup-dir $MODULE_PATH/acceptance/setup/ \
    --helper $MODULE_PATH/acceptance/helper.rb \
    --module scp://`cd $MODULE_PATH; pwd`/

Depending on how your environment is set up, you may need to have a "known" `auth.conf` installed. This file should already
exist if you install from a package, but if you need a copy you can get it from https://raw.github.com/puppetlabs/puppetlabs-auth_conf/master/spec/fixtures/unit/facter/custom_auth_conf/unmodified/auth-master-2.5.0.conf.

Note that these acceptance tests have not been tried as part of the larger acceptance testing infrastructure/CI,
they've only been run on a local VM. YMMV.