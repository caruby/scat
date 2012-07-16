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
  s.homepage      = 'https://github.com/caruby/scat'
  s.require_path  = 'lib'
  s.bindir        = 'bin'
  s.files         = `git ls-files`.split("\n") << 'ext/redis-server'
  s.test_files    = `git ls-files features spec test`.split("\n")
  s.executables   = `git ls-files bin`.split("\n").map { |f| File.basename(f) }
  s.add_runtime_dependency     'bundler'
  s.add_runtime_dependency     'rack'
  s.add_runtime_dependency     'sinatra'
  s.add_runtime_dependency     'haml'
  s.add_runtime_dependency     'redis'
  s.add_runtime_dependency     'redis-store'
  s.add_runtime_dependency     'jruby-openssl'
  s.add_runtime_dependency     'caruby-small'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rake'
  s.has_rdoc      = 'yard'
  s.license       = 'MIT'
end
