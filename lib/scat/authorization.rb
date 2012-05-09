require 'sinatra/authorization'

module Scat
  module Authorization
    include Sinatra::Authorization
    # Runs the given block in an HTTP basic authorization context.
    #
    # @yield the caTissue operation
    def protect!(&block)
      @status = nil
      login_required
      begin
        CaTissue::Database.current.open(session[:email], session[:password], &block)
      rescue
        session[:status] = $!
      end
    end

    # @return [CaTissue::User] the user who is submitting this edit
    # @raise [ArgumentError] if there is no such caTissue user
    def current_user
      email = @login.first
      user = CaTissue::User.new(:email_address => email)
      user_id = @cache.get(:user, login)
      if user_id then
        user.identifier = user_id
      else
        raise ArgumentError.new("User not found: #{user.email_address}") unless user.find
        @cache.set(:user, login, user.identifier)
      end
      user
    end
    
    private
    
    # Obtains the HTML Basic authorization username and password.
    # Formats the caTissue login name as _username_+@+_domain_,
    # where _domain_ is the domain portion of the system +hostname+.
    #
    # @return [(String, String)] the caTissue login name and password
    def authorize(username, password)
      domain = `hostname`[/\w+\.\w+$/]
      session[:email] = [username, domain].join('@')
      session[:password] = password
      logger.debug { "Scat captured caTissue login name #{@email} and password." }
      true
    end
  end
end
