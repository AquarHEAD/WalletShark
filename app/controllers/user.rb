# encoding: utf-8

WalletShark::App.controllers :user do

  get :index do
    @title = "Home"
    token = AuthToken.first(:token => session[:auth_token])
    @user = token.user
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
    if @error || @user.save
      redirect '/user/'
    else
      render 'user/signup'
    end
  end

  get :login do
    @title = "Login"
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
      token = AuthToken.new
      service = ServiceProvider.get(1)
      token.service_provider = service
      token.user = user
      token.status = :authed
      token.used_at = Time.now
      token.expire_at = Time.now + 30*60
      token.save
      session[:auth_token] = token.token
      redirect 'user/'
    else
      @error = "用户名或密码错误"
      render 'user/login'
    end
    
  end

  get :deposit do
    @title = "Deposit"
    render 'user/deposit'
  end
  
end
