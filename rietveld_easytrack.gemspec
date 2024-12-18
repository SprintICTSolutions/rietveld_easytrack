# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rietveld_easytrack/version'

Gem::Specification.new do |spec|
  spec.name          = "rietveld_easytrack"
  spec.version       = RietveldEasytrack::VERSION
  spec.authors       = ["Rick Lucassen", "Mark Lucassen"]
  spec.email         = ["support@agropro.nl"]

  spec.summary       = %q{Gem for communication with the Rietveld Easytrack software.}
  spec.homepage      = "http://agropro.nl"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "hash_validator"
  spec.add_dependency "net-sftp"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
