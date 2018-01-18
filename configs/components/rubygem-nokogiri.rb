component "rubygem-nokogiri" do |pkg, settings, platform|
  pkg.version "1.6.8"
  if platform.is_huaweios?
    # This tarball was generated by doing a puppet-agent build without nokogiri but
    # including its dependencies (mini_portile2), installing it on the target, and
    # installing the nokogiri gem using our gem command. The added files from
    # :gem_home were then tar'ed up and packed into this container tarball.
    pkg.url "#{settings[:buildsources_url]}/nokogiri-precompiled-huaweios-#{pkg.get_version}-patch1-for-ruby-#{settings[:ruby_version]}.tar.gz"
    pkg.md5sum "b5ba7041673b4c313dc8e0071b5b09ce"
  else
    pkg.url "https://rubygems.org/downloads/nokogiri-#{pkg.get_version}.gem"
    pkg.mirror "#{settings[:buildsources_url]}/nokogiri-#{pkg.get_version}.gem"
    pkg.md5sum "51402a536f389bfcef0ff1600b8acff5"
  end

  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  pkg.build_requires "rubygem-mini_portile2"
  pkg.build_requires "rubygem-pkg-config"

  if platform.is_huaweios?
    # This is a hack to ensure the nokogiri gem is installed after all other
    # gems, as once the cross-compiled extensions for nokogiri are installed,
    # any later gem operations will trigger rebuilding the extensions for the
    # build host platform, and things then explode horrifically.
    pkg.build_requires "rubygem-net-netconf"
    pkg.build_requires "rubygem-deep-merge"

    # The "gem install nokogiri" method of installing the gem won't work for
    # cross-compiled platforms, as we have no way of passing in the rbconfig
    # that specifies which compiler and build flags to use. So instead we use
    # a tarball of binaries done from the target arch environment.
    pkg.install do
      ["tar xvf nokogiri_files.tar -C #{settings[:gem_home]}"]
    end
  else
    # Standard build process for non cross-compiled platforms to ensure we build
    # against our vendored libxml2 and libxslt
    pkg.install do
      [
        "#{settings[:gem_install]} nokogiri-#{pkg.get_version}.gem -- --use-system-libraries --with-xml2-lib=/opt/puppetlabs/puppet/lib --with-xml2-include=/opt/puppetlabs/puppet/include/libxml2 --with-xslt-lib=/opt/puppetlabs/puppet/lib --with-xslt-include=/opt/puppetlabs/puppet/include/libxslt"
      ]
    end
  end
end
