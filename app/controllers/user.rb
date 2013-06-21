# encoding: utf-8

WalletShark::App.controllers :user do

  get :index do
    @title = "Home"
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    @user = token.user
    @months = [1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12].drop_while { |x| x <= Time.now.month }.take 12
    ym = ([1,2,3,4,5,6,7,8,9,10,11,12].map { |x| [Time.now.year-1, x] } + [1,2,3,4,5,6,7,8,9,10,11,12].map { |x| [Time.now.year, x] }).drop_while { |x| x[1] <= Time.now.month }.take 12
    @data_spent = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    @ds_scale = 0
    @data_income = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    @di_scale = 0
    @data_overhead = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    @do_max = 0
    @do_min = 0
    @data_profit = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    @dp_max = 0
    @dp_min = 0
    ym.each_index do |i|
      @user.payment.all(:type => :payment).select { |p| p.ended_at && p.ended_at.year == ym[i][0] && p.ended_at.month == ym[i][1] }.each { |p| @data_spent[i] += p.pay_amount.to_f }
      if @data_spent[i] > @ds_scale
        @ds_scale = @data_spent[i]
      end

      @user.payment.all(:type => :inpour).select { |p| p.ended_at && p.ended_at.year == ym[i][0] && p.ended_at.month == ym[i][1] }.each { |p| @data_income[i] += p.pay_amount.to_f }
      @user.payment.all(:type => :transfer).select { |p| p.ended_at && p.ended_at.year == ym[i][0] && p.ended_at.month == ym[i][1] }.each { |p| @data_income[i] += p.pay_amount.to_f }
      if @data_income[i] > @di_scale
        @di_scale = @data_income[i]
      end

      @data_overhead[i] = @data_spent[i] - @data_income[i]
      if i == 0
        @do_max = @data_overhead[i]
      elsif @data_overhead[i] > @do_max
        @do_max = @data_overhead[i]
      end
      if i == 0
        @do_min = @data_overhead[i]
      elsif @data_overhead[i] < @do_min
        @do_min = @data_overhead[i]
      end

      @data_profit[i] = @data_income[i] - @data_spent[i]
      if i == 0
        @dp_max = @data_profit[i]
      elsif @data_profit[i] > @dp_max
        @dp_max = @data_profit[i]
      end
      if i == 0
        @dp_min = @data_overhead[i]
      elsif @data_overhead[i] < @dp_min
        @dp_min = @data_overhead[i]
      end

    end
    require 'digest'
    render 'user/home'
  end

  get :signup do
    @title = "Signup"
    render 'user/signup'
  end

  post :signup do
    @title = "Signup"
    @user = User.new
    if params[:login_pass] != params[:login_pass_repeat]
      @error = "登录密码不匹配"
    end
    if params[:payment_pass] != params[:payment_pass_repeat]
      @error = "注册密码不匹配"
    end
    if params[:username].include? "@"
      @error = "非法用户名"
    end
    @user.username = params[:username]
    @user.nickname = params[:nickname]
    @user.email = params[:email]
    @user.login_pass = params[:login_pass]
    @user.payment_pass = params[:payment_pass]
    @user.realname = params[:realname]
    @user.id_number = params[:id_number]
    @user.bind_phone = params[:bind_phone]
    @user.sec_question = params[:sec_question]
    @user.sec_answer = params[:sec_answer]
    if @error || !@user.save
      render 'user/signup'
    else
      if @user.bind_phone
        require 'net/http'
        uri = URI('https://api.46elks.com/a1/sms')
        Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
          request = Net::HTTP::Post.new uri.request_uri
          request.basic_auth 'u0a67748e28e4a4cdeaf1e6d7ceabbd0d', 'F65F02D246BF191C1E16CEE663F8734A'
          request.set_form_data({'from' => 'WalletShark', 'to' => @user.bind_phone, 'message' => 'Welcome to WalletShark'})
          response = http.request request
        end
      end
      email(:from => "walletshark@163.com", :to => @user.email, :subject => "Welcome to WalletShark!", :body=>"Thanks for registering WalletShark!")
      redirect '/user/'
    end
  end

  get :info, :with => :id do
    service_id = params[:service_id]
    if !service_id
      halt 401
    end
    service = ServiceProvider.first(:service_id => service_id)
    if service.service_secret != params[:service_secret]
      halt 401
    end
    user = User.first(:id => params[:id])
    if user
      return user.to_json(:exclude => [:id, :login_pass, :payment_pass, :sec_question, :sec_answer, :balance, :realname, :id_number])
    else
      return "Requested user not found"
    end
  end

  get :login do
    token = AuthToken.first(:token => session[:auth_token])
    if token
      user = token.user
      redirect_url = '/user/'
      if params[:redirect]
        if params[:token]
          backtoken = AuthToken.first(:token => params[:token])
        else
          backtoken = AuthToken.new
          service = ServiceProvider.get(1)
          backtoken.service_provider = service
          backtoken.expire_at = Time.now + 30*60
        end
        backtoken.user = user
        backtoken.status = :authed
        backtoken.used_at = Time.now
        backtoken.save
        if params[:redirect].start_with? "http"
          redirect_url = "#{params[:redirect]}?token=#{backtoken.token}&result=success"
        else
          redirect_url = "http://#{params[:redirect]}?token=#{backtoken.token}&result=success"
        end
      end
      redirect redirect_url
    end
    @title = "Login"
    @token_key = params[:token]
    @redirect_url = params[:redirect]
    render 'user/login'
  end

  post :login do
    if params[:login_id].include? "@"
      user = User.first(:email => params[:login_id])
    else
      user = User.first(:username => params[:login_id])
    end
    if !user
      @error = "无效用户"
      render 'user/login'
    end
    if user.login_pass == params[:login_pass]
      if params[:token] && params[:token].length > 0
        token = AuthToken.first(:token => params[:token])
        if token.status != :fresh
          halt 403, "Token used or expired."
        end
      else
        token = AuthToken.new
        service = ServiceProvider.get(1)
        token.service_provider = service
        token.expire_at = Time.now + 30*60
      end
      token.user = user
      token.status = :authed
      token.used_at = Time.now
      token.save
      session[:auth_token] = token.token
      if params[:redirect] && params[:redirect].length > 0
        if params[:redirect].include? "?"
          return_vals = "&token=#{token.token}&result=success"
        else
          return_vals = "?token=#{token.token}&result=success"
        end
        if params[:redirect].start_with? "http"
          redirect_url = "#{params[:redirect]}#{return_vals}"
        else
          redirect_url = "http://#{params[:redirect]}#{return_vals}"
        end
        redirect redirect_url
      else
        redirect '/user/'
      end
    else
      @error = "用户名或密码错误"
      @token_key = params[:token]
      @redirect_url = params[:redirect]
      render 'user/login'
    end
  end

  get :logout do
    token = AuthToken.first(:token => session[:auth_token])
    token.status = :dropped
    session.clear
    redirect back
  end

  get :deposit do
    @title = "Deposit"
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    @user = token.user
    render 'user/deposit'
  end

  post :ppcard_deposit do
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    user = token.user
    ppc = PrepaidCard.first(:identifier => params[:ppc_id])
    if ppc
      if ppc.password == params[:ppc_pass] && ppc.used_at == nil
        ppc.used_at = Time.now
        ppc.user = user
        ppc.save
        user.balance += ppc.value
        user.save
        pay = Payment.new
        pay.name = "WalletShark充值"
        pay.type = :inpour
        pay.recipient = "WalletShark"
        pay.pay_amount = ppc.value
        pay.status = :succeed
        pay.service_provider = ServiceProvider.first()
        pay.user = user
        pay.save
        pay.ended_at = Time.now
        pay.save
        redirect '/user/'
      end
    end
    @error = "Card ID or Password error"
    render 'user/deposit'
  end

  get :genresetpaypass do
    @title = "Reset Payment Password"
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    @user = token.user
    @token = ResetToken.new
    @token.type = :payment
    @token.expire_at = Time.now + 30*60
    @token.user = @user
    @token.save
    email(:from => "walletshark@163.com", :to => @user.email, :subject => "WalletShark: Reset your payment password", :body=> render('email/resetpass', :layout => :email))
    render 'user/checkemail'
  end

  post :genresetloginpass do
    @title = "Reset Login Password"
    token = AuthToken.first(:token => session[:auth_token])
    if token
      redirect '/user/'
    end
    @token = ResetToken.new
    @token.type = :login
    @token.expire_at = Time.now + 30*60
    @user = User.first(:email => params[:email])
    @token.user = @user
    @token.save
    email(:from => "walletshark@163.com", :to => @user.email, :subject => "WalletShark: Reset your login password", :body=> render('email/resetpass', :layout => :email))
    render 'user/checkemail'
  end

  get :resetpass do
    @reset_token = ResetToken.first(:token => params[:token])
    unless @reset_token
      return "Invalid token."
    end
    if @reset_token.used_at
      return "Invalid token."
    end
    if @reset_token.expire_at <=> Time.now < 0
      return "Invalid token."
    end
    if @reset_token.type == :login
      @title = "Reset Login Password"
      @type_name = "登录"
    else
      @title = "Reset Payment Password"
      @type_name = "支付"
    end
    token = AuthToken.first(:token => session[:auth_token])
    if token
      @user = token.user
    end
    render 'user/resetpass'
  end

  post :resetpass do
    @reset_token = ResetToken.first(:token => params[:token])
    @type_name = params[:type_name]
    unless @reset_token
      return "Invalid token."
    end
    if @reset_token.used_at
      return "Invalid token."
    end
    if @reset_token.expire_at <=> Time.now < 0
      return "Invalid token."
    end
    unless params[:newpass].length > 0
      @error = "密码不能为空"
      render 'user/resetpass'
    end
    unless params[:newpass] == params[:repeatnewpass]
      @error = "密码不匹配"
      render 'user/resetpass'
    end
    user = @reset_token.user
    if @reset_token.type == :login
      user.login_pass = params[:newpass]
    else
      user.payment_pass = params[:newpass]
    end
    @reset_token.used_at = Time.now
    @reset_token.save
    user.save
    token = AuthToken.first(:token => session[:auth_token])
    if token
      @user = token.user
    end
    render 'user/resetdone'
  end

  get :forget do
    @title = "Forget Password"
    render 'user/forget'
  end

  get :edit do
    @title = "Edit"
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    @user = token.user
    render 'user/edit'
  end

  post :edit do
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    @user = token.user
    if @user.login_pass == params[:login_pass]
      if params[:newNickname].length > 0 
        @user.nickname = params[:newNickname]
      end
      if params[:newEmail].length > 0 
        @user.email = params[:newEmail]
      end
      if params[:newBindPhone].length > 0 
        @user.bind_phone = params[:newBindPhone]
      end
      if params[:newSecQues].length > 0 
        @user.sec_question = params[:newSecQues]
      end
      if params[:newSecAnswer].length > 0 
        @user.sec_answer = params[:newSecAnswer]
      end
      if params[:newLoginPass].length > 0 && params[:newLoginPass] == params[:repeatLoginPass]
        @user.login_pass = params[:newLoginPass]
      end
      @user.save
      redirect '/user/'
    else
      @error = "旧登录密码错误"
      render 'user/edit'
    end
  end
  
end
