# encoding: utf-8

module WalletShark
  class App < Padrino::Application
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers

    enable :sessions

    set :session_secret, "WalletShark"

    set :delivery_method, :smtp => {
      :address=> "smtp.163.com",
      :port => 25,
      :user_name => "walletshark@163.com",
      :password => "wshark",
      :authentication => :plain,
      :enable_starttls_auto => true
    }

    ##
    # Caching support
    #
    # register Padrino::Cache
    # enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
    # set :cache, Padrino::Cache::Store::Memory.new(50)
    # set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_app/locales)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    layout  :default            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    get :welcome, :map => '/' do
      @title = "Welcome"
      token = AuthToken.first(:token => session[:auth_token])
      if token
        @user = token.user
        redirect '/user/'
      end
      render 'index'
    end

    get :genppcard, :map => '/genppcard/?' do
      service_id = params[:service_id]
      if !service_id
        halt 401
      end
      service = ServiceProvider.first(:service_id => service_id)
      if service.service_secret != params[:service_secret]
        halt 401
      end
      count = 10
      value = 100.00
      if params[:count]
        count = params[:count].to_i
      end
      if params[:value]
        value = params[:value].to_f
      end
      expire_time = 60*60*24*365
      if params[:expire_time]
        value = params[:expire_time].to_i
      end
      pass = "123"
      if params[:pass]
        value = params[:pass]
      end
      require 'digest'
      cards = Array.new()
      count.times do
        ppc = PrepaidCard.new
        ppc.identifier = Digest::SHA1.hexdigest([Time.now, rand].join)[0,10]
        ppc.password = pass
        ppc.value = value
        ppc.expire_at = Time.now + expire_time
        if ppc.save
          cards.push(ppc)
        end
      end
      return "[#{cards.map{|x| x.to_json(:exclude => [:id, :password, :user_id])}.join(',')}]"
    end

    error 401 do
      return "Unauthorized"
    end

    get :icon, :map => '/favicon.ico' do
      redirect '/favicon.png?v=2'
    end

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 505 do
    #     render 'errors/505'
    #   end
    #
  end
end
