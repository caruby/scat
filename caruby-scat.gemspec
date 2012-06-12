require 'date'
require File.dirname(__FILE__) + '/lib/scat/version'

Gem::Specification.new do |s|
  s.name          = 'caruby-scat'
  s.summary       = 'Simple caTissue web application'
  s.description   = s.summary + '. See the home page for more information.'
  s.version       = Scat::VERSION
  s.date          = Date.today
  s.author        = "OHSU"
  s.email         = 'caruby.org@gmail.com'
  s.homepage      = 'http://caruby.rubyforge.org/casmall.html'
  s.require_path  = 'lib'
  s.bindir        = 'bin'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files spec`.split("\n")
  s.executables   = `git ls-files bin`.split("\n").map { |f| File.basename(f) }
  s.add_runtime_dependency     'sinatra'
  s.add_runtime_dependency     'rack'
  s.add_runtime_dependency     'haml'
  s.add_runtime_dependency     'sass'
  s.add_runtime_dependency     'sinatra'
  s.add_runtime_dependency     'sinatra-authorization'
  s.add_runtime_dependency     'redis'
  s.add_runtime_dependency     'redis-store'
  s.add_runtime_dependency     'jruby-openssl'
  s.add_runtime_dependency     'caruby-tissue', '>= 2.1.3'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rake'
  s.has_rdoc      = 'yard'
  s.license       = 'MIT'
end
