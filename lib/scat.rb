require 'rubygems'
require 'sinatra'
require 'haml'
require 'catissue'
require 'scat/authorization'
require 'scat/autocomplete'
require 'scat/specimen_edit'

module Scat
  # The standard Scat application error.
  class Error < RuntimeError; end
   
  class App < Sinatra::Base
    include Authorization, Autocomplete
    
    if development? then
      # Don't generate fancy HTML for stack traces.
      disable :show_exceptions
      # Allow errors to get out of the app so Cucumber can display them.
      enable :raise_errors
    end
      
    # The authorization page name.
    set :authorization_realm, 'Please enter your username and caTissue password'
    
    enable :sessions    
    
    # Displays the specimen form.
    get '/' do
      haml :home
    end
    
    # Saves the specimen specified in the specimen form.
    post '/' do
      protect! { SpecimenEdit.instance.save(params.merge(:user => current_user)) }
      redirect back
    end

    # Displays the CVs for the given attribute which match the entered term prefix.
    get '/autocomplete/*' do |cva|
      protect! { autocomplete(cva, params[:term]) }
    end
    
    # Sets the status field to the error message.
    error do
      request.params[:status] = env['sinatra.error'].message
      redirect back
    end
  end
end
