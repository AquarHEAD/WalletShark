# encoding: utf-8

WalletShark::App.controllers :user do

  get :index do
    @title = "Home"
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
      render 'user/signup'
    end
    if params[:payment_pass] != params[:payment_pass_repeat]
      @error = "注册密码不匹配"
      render 'user/signup'
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
    if @user.save
      redirect '/user/'
    else
      render 'user/signup'
    end
  end

  get :deposit do
    @title = "Deposit"
    render 'user/deposit'
  end

  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   'Maps to url '/foo/#{params[:id]}''
  # end

  # get '/example' do
  #   'Hello world!'
  # end
  
end
