# encoding: utf-8

WalletShark::App.controllers :user do

  get :index do
    @title = "Home"
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    @user = token.user
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
      email(:from => "walletshark@163.com", :to => @user.email, :subject => "Welcome to WalletShark!", :body=>"Thanks for registering WalletShark!")
      redirect '/user/'
    end
  end

  get :login do
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
      if params[:token].length > 0
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
      if params[:redirect].length > 0
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
      if ppc.password == params[:ppc_pass]
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

  get :resetloginpass do
    @title = "Reset Login Password"
    token = AuthToken.first(:token => session[:auth_token])
    unless token
      redirect '/user/login/'
    end
    @user = token.user
    render 'user/resetloginpass'
  end

  get :resetpaypass do
    # should generate new resettoken here
  end

  get :forget do
    @title = "Forget Password"
    render 'user/forget'
  end
  
end
