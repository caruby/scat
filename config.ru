require 'rubygems'
require 'bundler'
Bundler.require

require 'fileutils'
require 'redis'
require 'jinx/helpers/log'
require 'scat'

# the logger
use Rack::CommonLogger, Jinx.logger(:app => 'Scat', :debug => true)

# start the application
run Scat::App

