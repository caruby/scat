require 'rubygems'
require 'bundler/setup'
Bundler.require(:test, :development)
require 'scat'

module Scat::Test
  RESULTS = File.dirname(__FILE__) + '/../test/results'
end

# Open the logger.
logger(Scat::Test::RESULTS + '/log/scat.log', :debug => true)

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }
