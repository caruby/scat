require 'rubygems'
require 'bundler/setup'
Bundler.require(:test, :development)

require 'capybara/cucumber'
require 'jinx/helpers/log'
require 'scat'

ENV['RACK_ENV'] = 'test'

Capybara.app = Scat::App

# Open the logger.
Jinx.logger('test/results/log/scat.log', :debug)

def app
  Scat::App
end
