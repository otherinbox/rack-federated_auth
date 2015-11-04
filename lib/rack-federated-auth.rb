require 'sinatra/base'

module RackFederatedAuth
  class Authentication < Sinatra::Base
    attr_accessor :auth_scope
    attr_accessor :email_filter
    attr_accessor :failure_message

    attr_accessor :auth_prefix
    attr_accessor :auth_url
    attr_accessor :success_url
    attr_accessor :failure_url
    attr_accessor :public_path_regexes

    # Set up federated authentication
    #
    # auth_scope is the session key which will be used to check if the user has authenticated. Allows basic role-based authentication
    # email_filter is a regex which a user's email must match to be authorized
    # failure_message is the text which will be shown to users after failed auth - use it to help them authenticate correctly
    # auth_prefix will be prepended to the OmniAuth urls (callbacks, etc).
    # auth_url determines which auth strategy will be used - see OmniAuth's docs for more details
    # success_url is the url the user will be redirected to after successful authentication
    # failure_url for failed authentication (or emails that don't match email_filter)
    #
    def initialize(app)
      @auth_scope = "authorized"
      @email_filter = /.*/
      @failure_message = "Authentication failed.  Click <a href='#{@auth_url}'>here</a> to try again"

      @auth_prefix = "/auth"
      @auth_url = nil
      @success_url = '/'
      @failure_url = nil
      @public_path_regexes = []

      yield self if block_given?

      @auth_url ||= "#{@auth_prefix}/google_oauth2"
      @failure_url ||= "#{@auth_prefix}/failure"

      super(app)
    end

    # Make sure users are authenticated
    #
    # NOTE: This should really be aware of auth_prefix
    before /^(?!\/(auth))/ do
      redirect @auth_url unless authenticated?
    end

    # Handle federated authentication callbacks
    #
    # This expects to be passed the authenticated user's email address. OmniAuth
    # should normalize most of that stuff.
    #
    get "/auth/:service/callback" do
      authenticate!
    end
    put "/auth/:service/callback" do
      authenticate!
    end
    post "/auth/:service/callback" do
      authenticate!
    end

    get '/auth/failure' do
      "<html><body>#{@failure_message}</body></html>"
    end

    private

    def authenticate!
      puts "New #{params[:service]} auth: #{request.env['omniauth.auth']}"
      begin
        if request.env['omniauth.auth']['info']['email'].match(@email_filter)
          puts "email matches filter, redirecting to #{@success_url}"
          puts "oauth-test fed-auth session: #{request.session_options[:id]}"
          session[@auth_scope] = true
          session['auth_email'] = request.env['omniauth.auth']['info']['email']
          redirect @success_url
        else
          puts "email doesn't match filter, redirecting to #{@failure_url}"
          redirect @failure_url
        end
      rescue
        puts "Auth failure :("
        session[@auth_scope] = false
        session.delete('auth_email')
        redirect @failure_url
      end
    end

    def authenticated?
      public_path_regexes.any? { |regex| request.path =~ regex } || (!session[@auth_scope].nil? && session[@auth_scope])
    end
  end
end
