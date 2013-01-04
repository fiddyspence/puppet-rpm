# A "config.ru", for use with every Rack-compatible webserver.
# SSL needs to be handled outside this, though.

$0 = "master"

# If you want debugging, uncomment the following line:
# ARGV << "--debug"

ARGV += ["--rack"]
require "puppet/application/master"

class Puppet::Application::Master
  unless defined?(setup_original) then
    alias :setup_original :setup
  end

  def setup
    result = setup_original

    # This must run after the original setup method because we depend on it
    # completing all our setup steps to be able to call these next methods...
    if Puppet::SSL::CertificateAuthority.ca? then
      begin
        require "puppet/util/license"
        Puppet::Util::License.display_license_status
      rescue Exception => e
        Puppet.crit("Loading the license code in the master failed:\n#{e}")
        Puppet.crit("Something is very wrong with your install; please reinstall\n" +
                    "or otherwise contact Puppet Labs for support!")
        # ...and that is sufficient. --daniel 2011-01-18
      end
    end

    result
  end
end

run Puppet::Application[:master].run
