require 'sinatra'

module RackFederatedAuth
  class Authentication < Sinatra::Base
    attr_accessor :auth_url
    attr_accessor :email_filter
    attr_accessor :failure_message

    def initialize(app)
      @auth_url = "/auth/google_oauth2"
      @email_filter = /.*/
      @failure_message = "Authentication failed.  Click <a href='#{@auth_url}'>here</a> to try again"

      yield self if block_given?

      super(app)
    end

    def authenticated?
      !session['authorized'].nil? and session['authorized']
    end

    before /^(?!\/(auth))/ do
      redirect @auth_url unless authenticated?
    end

    get "/auth/:service/callback" do
      puts "New #{params[:service]} auth: #{request.env['omniauth.auth']}"
      begin
        if request.env['omniauth.auth']['info']['email'].match(@email_filter)
          puts "email matches filter"
          session['authorized'] = true 
          redirect '/'
        else
          puts "email doesn't match filter"
          redirect '/auth/failure'
        end
      rescue
        puts "Auth failure :("
        session['authorized'] = false
        redirect '/auth/failure'
      end
    end

    get '/auth/failure' do
      "<html><body>#{@failure_message}</body></html>"
    end
  end
end
