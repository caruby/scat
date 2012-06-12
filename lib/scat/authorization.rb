require 'sinatra/authorization'

module Scat
  module Authorization
    include Sinatra::Authorization
    # Runs the given block in an HTTP basic authorization context.
    # The session status is set to the result of performing the given block.
    #
    # @yield perform the caTissue operation and return a status message
    def protect!(&block)
      login_required
      session[:status] = perform!(session[:email], session[:password], &block)
    end

    # @return [CaTissue::User] the user who is submitting this edit
    # @raise [ArgumentError] if there is no such caTissue user
    def current_user
      # The caTissue login name is the user's email address.
      email = session[:email]
      raise ScatError.new("The caTissue login is not available in this web session.") unless email
      # the current caTissue User
      user = CaTissue::User.new(:email_address => email)
      # the cached caTissue User id
      user_id = session[:user_id]
      if user_id then
        user.identifier = user_id
      else
        # Fetch the User and cache the id.
        raise ScatError.new("User not found: #{user.email_address}") unless user.find
        session[:user_id] = user.identifier
      end
      user
    end
      
    # Fix +Sinatra::Authorization.authorization_realm+ per the
    # (https://github.com/sr/sinatra-authorization)[https://github.com/sr/sinatra-authorization]
    # patch.
    def authorization_realm
      settings.authorization_realm
    end
    
    private
    
    # Obtains the HTML Basic authorization username and password.
    # Formats the caTissue login name as _username_+@+_domain_,
    # where _domain_ is the domain portion of the system +hostname+.
    #
    # @param [String] the caTissue login name, with or without the +@+_domain_ suffix
    # @param [String] the caTissue password
    # @return [Boolean] the authorization result
    def authorize(username, password)
      email = session[:email] = infer_email_address(username)
      session[:password] = password
      # Try to start a session.
      begin
        CaTissue::Database.current.open(email, password) {}
        logger.debug { "Scat captured the caTissue login name #{email} and password." }
        true
      rescue Exception => e
        logger.debug { "Scat caTissue login #{email.qp} with password #{password.qp} is invalid." }
        session[:status] = "caTissue login was unsuccessful - #{e.message}"
        false 
      end
    end
    
    # Runs the given caTissue operation block with the given caTissue credentials.
    #
    # @yield (see #protect!)
    # @return [String, nil] the status message
    def perform!(email, password, &block)
      login_required
      CaTissue::Database.current.open(email, password, &block)
    end
    
    # @param [String] the username, with or without the +@+_domain_ suffix
    # @param [String] the email address
    def infer_email_address(username)
      if username.index('@') then
        username
      else
        # The email domain is the last two components of the hostname, e.g.
        # the prod01.cluster.galena.edu domain is galena.edu. 
        domain = `hostname`.chomp[/[^.]+\.[^.]+$/]
        domain.empty? ? username : [username, domain].join('@')
      end
    end
  end
end
