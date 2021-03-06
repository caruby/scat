require 'sinatra'
require 'haml'
require 'catissue'
require 'casmall/authorization'
require 'scat/autocomplete'
require 'scat/edit'

module Scat
  # The standard Scat application error.
  class ScatError < RuntimeError; end
   
  class App < Sinatra::Base
    include CaSmall::Authorization, Autocomplete

    set :root, File.dirname(__FILE__) + '/..'
    
    if development? then
      # Don't generate fancy HTML for stack traces.
      disable :show_exceptions
      # Allow errors to get out of the app so Cucumber can display them.
      enable :raise_errors
    end
      
    # The authorization page name.
    set :authorization_realm, 'Please enter your username and caTissue password'
    
    enable :sessions
    
    # Displays the edit form.
    get '/' do
      haml :edit
    end
    
    # Saves the specimen specified in the specimen form.
    post '/' do
      # Save the specimen.
      protect! { Edit.instance.save(params.merge(:user => current_user), session) }
      # Return to the edit form.
      redirect back
    end

    # Displays the CVs for the given property attribute which match the given input
    # value term.
    get '/autocomplete/*' do |pa|
      protect! { autocomplete(pa.to_sym, params[:term]) }
    end
        
    # Sets the status field to the error message.
    error do
      e = env['sinatra.error']
      logger.error(e)
      request.params[:status] = e.message
      redirect back
    end
  end
end
