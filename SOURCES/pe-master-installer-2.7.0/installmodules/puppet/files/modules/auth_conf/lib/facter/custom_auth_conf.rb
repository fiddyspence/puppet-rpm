unmodified_shas = [
"b33f7dcc83f846618fdc61de3aee22d1ef5965e2", # 1.2.x auth.conf with console
"36a1814cc92369841fd21d0ff4b204c922508f16", # 2.0.x auth.conf with console upgraded from 1.2.x
"66cebfd351ade79878346076fd748e6d0a9337e5", # 2.0.x auth.conf with console
"96b345d2d9efb9f0089d1b77f3f35cdcf4211127", # 2.5.x and greater auth.conf with console
"b15f767343118f60672b630a5f6b2654464bb3c3", # 1.2.x auth.conf without console
"6a634811f8d4693383f7fd41eb8f9d081e2d5afe", # 2.0.x auth.conf without console upgraded from 1.2.x
"4e86bd053c741a4ea3b106dea6cb2abf5fa20603", # 2.0.x auth.conf without console
"ca487278ecf3f7b5ba7411b350e089007c7f47b7", # 2.5.x and greater auth.conf without console
]

Facter.add("custom_auth_conf") do
  setcode do
    auth_conf_prefix = Facter.value('puppetversion').include?('Puppet Enterprise') ? '/etc/puppetlabs' : '/etc'
    auth_conf_path = "#{auth_conf_prefix}/puppet/auth.conf"

    if File.exists? auth_conf_path
      contents = File.read("#{auth_conf_prefix}/puppet/auth.conf")

      # If the file is already managed by Puppet
      if contents.lines.first.include? '# THIS FILE IS MANAGED BY PUPPET'
        'false'
      else
        contents.gsub!(/(path \/facts\nauth yes\nmethod save\nallow )(.+?)\n/m,'\1')
        new_contents = contents.map do |line| line.strip end.join
        if unmodified_shas.include?(Digest::SHA1.hexdigest new_contents)
          'false'
        else
          'true'
        end
      end
    else
      'false'
    end
  end
end
