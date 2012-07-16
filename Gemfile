source :rubygems
gemspec

group :development do
  gem 'ruby-debug'
  # Uncomment the following lines if there are local gem changes. Change the path option
  # to your workspace location. Commit the changed Gemfile and Gemfile.lock to a git branch
  # named 'local' rather than to the master branch. Do not check in the local change.
  #gem 'caruby-core', :path => File.dirname(__FILE__) + '/../core'
  #gem 'caruby-tissue', :path => File.dirname(__FILE__) + '/../tissue'
  #gem 'caruby-small', :path => File.dirname(__FILE__) + '/../small'
  #gem 'jinx', :path => File.dirname(__FILE__) + '/../../jinx/core'
  #gem 'jinx-json', :path => File.dirname(__FILE__) + '/../../jinx/json'
  gem 'caruby-scat', :path => File.dirname(__FILE__), :require => 'scat'
end

group :test do
  gem 'rspec', '>= 2.6'
  gem 'sinatra', '=1.2.6' # TODO - retry with 1.3 when it is available
  gem 'shotgun'
  gem 'cucumber'
  gem 'capybara'
  gem 'launchy'
  gem 'rack-test', :require => 'rack/test'
end
