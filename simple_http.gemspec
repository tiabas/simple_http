# -*- encoding: utf-8 -*-
require File.expand_path('../lib/simple_http/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kevin Mutyaba"]
  gem.email         = ["tiabasnk@gmail.com"]
  gem.description   = %q{A Net::HTTP wrapper}
  gem.summary       = %q{Simple HTTP wrapper for Ruby}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "simple_http"
  gem.require_paths = ["lib"]
  gem.version       = SimpleHttp::Version
  gem.licenses      = ['MIT']

  gem.add_dependency 'addressable'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov', '~> 0.7.1'
  gem.add_development_dependency 'webmock', '~> 1.9.0'

  gem.cert_chain    = ['certs/tiabas_public.pem']
  gem.signing_key   = File.expand_path("~/.gem/certs/private_key.pem") if $0 =~ /gem\z/
end
