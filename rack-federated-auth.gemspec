# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "rack-federated-auth"
  gem.version       = "0.2.1"
  gem.authors       = ["Ryan Michael"]
  gem.email         = ["kerinin@gmail.com"]
  gem.description   = "Provides a simple authentication middleware to lock down Rack-based apps"
  gem.summary       = "Omniauth middleware"
  gem.homepage      = "http://github.com/otherinbox/rack-federated_auth"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'omniauth'
  gem.add_dependency 'sinatra'
  
  gem.add_development_dependency 'shoulda'
  gem.add_development_dependency 'rdoc', '~> 3.12'
  gem.add_development_dependency 'bundler', '~> 1.1.0'
end
