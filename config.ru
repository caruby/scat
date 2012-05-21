require 'rubygems'
require 'bundler'
Bundler.require

require 'fileutils'
require 'sass/plugin/rack'
require 'redis'
require 'rack/session/redis'
require 'jinx/helpers/log'
require 'scat'

# the logger
use Rack::CommonLogger, Jinx.logger(:app => 'Scat', :debug => true)

# the cache
use Rack::Session::Redis

# the style-sheet parser
use Sass::Plugin::Rack

# start the application
run Scat::App

