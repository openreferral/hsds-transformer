lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'hsds_transformer/version'

Gem::Specification.new do |s|
  s.name        = 'hsds_transformer'
  s.version     = HsdsTransformer::VERSION
  s.date        = '2019-10-06'
  s.summary     = 'Human Services Data Spec Transformer'
  s.description = 'Gem for transforming data files into HSDS formatted datapackage'
  s.authors     = ["Shelby Switzer"]
  s.email       = 'info@openreferral.org'
  s.files       = Dir['lib/**/*']
  s.require_paths = ['lib']
  s.homepage    =
      'https://openreferral.org'
  s.license       = 'MIT'

  s.add_development_dependency 'dotenv', '~> 2.6.0', '>= 2.6.0'
  s.add_development_dependency 'rspec', '~> 3.8.0', '>= 3.8.0'
  s.add_development_dependency 'rb-readline', '~> 0.5.5', '>= 0.5.5'
  s.add_development_dependency 'rack-test', '~> 1.1.0', '>= 1.1.0'
  s.add_development_dependency 'pry', '~> 0.12.2', '>= 0.12.2'

  s.add_runtime_dependency 'unf_ext', '~> 0.0.7.5', '>= 0.0.7.5'
  s.add_runtime_dependency 'rubyzip', '~> 2.0.0', '< 2.1.0'
  s.add_runtime_dependency 'zip-zip', '~> 0.3', '>= 0.3'
  s.add_runtime_dependency 'sinatra', '~> 2.0.5', '>= 2.0.5'
  s.add_runtime_dependency 'rest-client', '~> 2.0.2', '>= 2.0.2'
  s.add_runtime_dependency 'datapackage', '~> 1.1.1', '>= 1.1.1'
end