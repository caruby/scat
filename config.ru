require 'rubygems'
require 'bundler'
Bundler.require

require 'sass/plugin/rack'
require 'redis'
require 'rack/session/redis'
require 'jinx/helpers/log'
require 'scat'

# the logger
use Rack::CommonLogger, Jinx.logger('/var/log/scat.log', :debug)

# the cache
use Rack::Session::Redis

# the style-sheet parser
use Sass::Plugin::Rack

# start the application
run Scat::App

