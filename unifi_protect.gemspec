# frozen_string_literal: true

require_relative 'lib/unifi_protect/version'

Gem::Specification.new do |spec|
  spec.name          = 'unifi_protect'
  spec.version       = UnifiProtect::VERSION
  spec.authors       = ['Jeremy Cole']
  spec.email         = ['jeremy@jcole.us']

  spec.summary       = 'UniFi Protect API'
  spec.description   = 'An unofficial implementation of the Ubiquiti UniFi Protect API in Ruby'
  spec.homepage      = 'http://github.com/jeremycole/unifi_protect'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = ''

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
